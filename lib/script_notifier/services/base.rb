module ScriptNotifier
  module Services
    class Base

      def self.deliver!(message)
        script_data, notifications = extract(message)
        route!(script_data, notifications)
      end

      def self.extract(message)
        notifications = message['notifications']
        script_data = message.reject { |k,v| k == 'notifications' }
        return [script_data, notifications]
      end

      def self.route!(script_data, notifications)
        notifications.each_with_index do |notification, index|
          case notification['type']
          when 'sms'
            result = Service::Sms.new(script_data, notification).deliver!
          when 'email'
            result = Service::Email.new(script_data, notification).deliver!
          when 'twitter'
            result = Service::Twitter.new(script_data, notification).deliver!
          else
            ScriptNotifier.log("#{Time.now}: Don't have a #{notification['type']} service to use")
            result = {'success' => false, 'sent_at' => Time.now, 'error' => "Can not process #{notification['type']} alerts at this time"}
          end
          notifications[index].merge!(result)
        end

        notifications
      end

      def initialize(message)

      end

      def deliver!
        raise NotImplementedError
      end
    end
  end
end
