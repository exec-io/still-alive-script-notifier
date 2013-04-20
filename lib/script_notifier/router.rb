# encoding: utf-8
module ScriptNotifier

  class Router

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
      message = get_next_notification_message

      # Error in getting a message, return and half execution
      return nil if message.blank?

      $0 = "script_notifier - Received notice - processing since #{Time.now.to_i}"
      message = process_notification(message)

      $0 = "script_notifier - Sending notice result - processing since #{Time.now.to_i}"
      send_results(message)
    end

    def get_next_notification_message
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

    def send_results(message)
      ScriptNotifier.log("#{Time.now}: Sending result of notice #{message.inspect}")
      send_message_to_queue(message.to_json)
    rescue => ex
      ScriptNotifier.log "#{Time.now}: Error sending notice result #{message} got exception #{ex}"
    end

    def send_message_to_queue(message_string)
      result_queue.send_string(message_string)
    end

    def process_notification(message)
      message['notifications'].each_with_index do |notification, idx|
        case notification['type']
        when 'sms'
          result = Service::Sms.new(message).deliver!
          message['notifications'][idx].merge!(result)
        when 'email'
          result = Service::Email.new(message).deliver!
          message['notifications'][idx].merge!(result)
        when 'twitter'
          result = Service::Twitter.new(message).deliver!
          message['notifications'][idx].merge!(result)
        else
          ScriptNotifier.log("#{Time.now}: Don't have a #{notification['type']} service to use")
          result = {'success' => false, 'sent_at' => Time.now, 'error' => "Can not process #{notification['type']} alerts at this time"}
          message['notifications'][idx].merge!(result)
        end
      end
      message
    end

    def shut_down!
      notification_queue.setsockopt(ZMQ::LINGER, 0)
      notification_queue.close
      context.terminate
    end

  end
end
