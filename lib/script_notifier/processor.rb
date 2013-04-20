# encoding: utf-8
module ScriptNotifier

  class Processor

    attr_reader :context, :notice_queue, :result_queue, :running

    def run!
      ScriptNotifier.log("#{Time.now}: Setting up queues")
      setup_queues!

      ScriptNotifier.log("#{Time.now}: Ready to receive notification messages")

      @running = true
      while running? do
        process!
        sleep(1)
      end

      shut_down!
      ScriptNotifier.log("#{Time.now}: Received Shutdown")
    end

    def running?
      !!@running
    end

    def stop_running!
      @running = false
    end

    private

    def setup_queues!
      ScriptNotifier.log("#{Time.now}: Setting up queues")
      @context = ZMQ::Context.new(1)

      # Socket to receive notifications messages on
      @notice_queue = context.socket(ZMQ::PULL)
      notice_queue.bind(ScriptNotifier::Base.notice_queue_uri)

      # Socket to send notification result back to
      @result_queue = context.socket(ZMQ::PUSH)
      result_queue.bind(ScriptNotifier::Base.result_queue_uri)
    end

    def process!
      $0 = "script_notifier - Ready to receive notifications since #{Time.now.to_i}"
      notifications = get_next_notification

      # Error in getting a message, return and halt execution
      return nil if notifications.blank?

      $0 = "script_notifier - Received notice - processing since #{Time.now.to_i}"
      result = route(notifications)

      $0 = "script_notifier - Sending notice result - processing since #{Time.now.to_i}"
      send_result(result)
    end

    def get_next_notification
      json = receive_message_from_queue
      JSON.parse(json)
    rescue => ex
      ScriptNotifier.log "#{Time.now}: Error processing message #{json} got exception #{ex}"
      nil
    end

    def receive_message_from_queue(message_string = '')
      notice_queue.recv_string(message_string)
      message_string
    end

    def send_result(message)
      ScriptNotifier.log("#{Time.now}: Sending result of notice #{message.inspect}")
      send_message_to_queue(message.to_json)
    rescue => ex
      ScriptNotifier.log "#{Time.now}: Error sending notice result #{message} got exception #{ex}"
    end

    def send_message_to_queue(message_string)
      result_queue.send_string(message_string)
    end

    def route(notifications)
      router = ScriptNotifier::Router.new(notifications)
      router.deliver!
    end

    def shut_down!
      notification_queue.setsockopt(ZMQ::LINGER, 0)
      notification_queue.close
      context.terminate
    end

  end
end
