# encoding: utf-8
module ScriptNotifier

  class Router

    def initialize(message)
      @message = message
      extract_notifications
    end

    def deliver!
      @notifications.each_with_index do |notification, index|
        result = send_notification(notification)
        @notifications[index].merge!(result)
      end
      @script_data.merge({'notifications' => @notifications})
    end

    private

    def extract_notifications
      @notifications = @message['notifications']
      @script_data = @message.reject { |k,v| k == 'notifications' }
    end

    def send_notification(notification)
      case notification['type']
      when 'sms'
        Services::Sms.new(@script_data, notification).deliver!
      when 'email'
        Services::Email.new(@script_data, notification).deliver!
      when 'twitter'
        Services::Twitter.new(@script_data, notification).deliver!
      else
        ScriptNotifier.log("#{Time.now}: Don't have a #{notification['type']} service to use")
        {'success' => false, 'sent_at' => Time.now.utc.iso8601, 'error' => "Can not process \"#{notification['type']}\" alerts at this time"}
      end
    end

  end
end
