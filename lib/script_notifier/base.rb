# encoding: utf-8
module ScriptNotifier
  require "net/http"
  require "uri"
  require 'active_support/core_ext/class/attribute_accessors'

  class Base

    cattr_reader :context, :notification_queue

    # Gather Config
    def self.setup_config(config_yml = nil)
      config_yml ||= File.join(File.expand_path('../', __FILE__), '../../config/', 'config.yml')
      config = YAML::load(File.read(config_yml))

      StillAliveService.setup_config(config)
    end

    @@running = true

    def self.running?
      @@running
    end

    def self.stop_running!
      @@running = false
    end

    def self.setup_queues(opts = {})
      ScriptNotifier.log('Setting up queues')
      @@context = ZMQ::Context.new(1)

      notification_queue_uri = (opts[:notification_queue_uri] || "tcp://127.0.0.1:6000")

      # Socket to receive results messages on
      @@notification_queue = context.socket(ZMQ::PULL)
      notification_queue.bind(notification_queue_uri)
    end

    def self.run!
      ScriptNotifier.log("Ready to receive requests #{Time.now}")
      message = ''

      while running? do
        process!
      end

      shut_down!
      ScriptNotifier.log("Received Shutdown at #{Time.now}")
    end

    def self.process!
      $0 = "script_notifier - Ready to receive notifications since #{Time.now.to_i}"
      message = get_next_notification_message
      $0 = "script_notifier - received message - processing since #{Time.now.to_i}"
      process_notification(message)
    end

    def self.get_next_notification_message
      message = ''
      notification_queue.recv_string(message)
      message
    end

    def self.process_notification(message_string)
      message = JSON.parse(message_string)

      StillAliveService.new.process(message)
    rescue => ex
      ScriptNotifier.log "Error processing message #{ex}"
    end

    def self.shut_down!
      notification_queue.setsockopt(ZMQ::LINGER, 0)
      notification_queue.close
      context.terminate
    end

  end
end
