# encoding: utf-8
module ScriptNotifier
  require "net/http"
  require "uri"
  require 'active_support/core_ext/class/attribute_accessors'

  class Router

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
      ScriptNotifier.log("#{Time.now}: Setting up queues")
      @@context = ZMQ::Context.new(1)

      notification_queue_uri = (opts[:notification_queue_uri] || "tcp://127.0.0.1:6000")

      # Socket to receive results messages on
      @@notification_queue = context.socket(ZMQ::PULL)
      notification_queue.bind(notification_queue_uri)
    end

    def self.run!
      ScriptNotifier.log("#{Time.now}: Ready to receive requests")

      while running? do
        process!
      end

      shut_down!
      ScriptNotifier.log("#{Time.now}: Received Shutdown")
    end

    def self.process!
      $0 = "script_notifier - Ready to receive notifications since #{Time.now.to_i}"
      message = get_next_notification_message
      $0 = "script_notifier - received message - processing since #{Time.now.to_i}"
      message = process_notification(message)
      send_results(message)
    end

    def self.get_next_notification_message
      message = ''
      notification_queue.recv_string(message)
      message
    end

    def self.process_notification(message_string)
      message = JSON.parse(message_string)

      ScriptNotifier.log("#{Time.now}: Got message #{message.inspect}")

      send_notifications(message)
    rescue => ex
      ScriptNotifier.log "#{Time.now}: Error processing message #{message} got exception #{ex}"
    end

    def self.send_results(message)
      
    end

    def self.send_notifications(message)
      message['notifications'].each_with_index do |notification, idx|
        case notification['type']
        when 'sms'
          result = Service::Sms.new(message)
          message['notifications'][idx].merge!(result)
        when 'email'
          Service::Email.new(message)
          message['notifications'][idx].merge!(result)
        when 'twitter'
          Service::Twitter.new(message)
          message['notifications'][idx].merge!(result)
        else
          ScriptNotifier.log("#{Time.now}: Don't have a #{notification['type']} service to use")
          result = {'success' => false, 'sent_at' => Time.now, 'error' => "Could not process #{notification['type']} alerts at this time"}
          message['notifications'][idx].merge!(result)
        end
      end
      message
    end

    def self.shut_down!
      notification_queue.setsockopt(ZMQ::LINGER, 0)
      notification_queue.close
      context.terminate
    end

  end
end
