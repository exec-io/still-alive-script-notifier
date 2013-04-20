module ScriptNotifier
  module Services
    class Base

      def self.deliver!(notifications)
        notifications['notifications'].each_with_index do |notification, idx|
          case notification['type']
          when 'sms'
            result = Service::Sms.new(notifications, idx).deliver!
            notifications['notifications'][idx].merge!(result)
          when 'email'
            result = Service::Email.new(notifications, idx).deliver!
            notifications['notifications'][idx].merge!(result)
          when 'twitter'
            result = Service::Twitter.new(notifications, idx).deliver!
            notifications['notifications'][idx].merge!(result)
          else
            ScriptNotifier.log("#{Time.now}: Don't have a #{notification['type']} service to use")
            result = {'success' => false, 'sent_at' => Time.now, 'error' => "Can not process #{notification['type']} alerts at this time"}
            notifications['notifications'][idx].merge!(result)
          end
        end
        message

      end

      def initialize(message)

      end

      def deliver!
        raise NotImplementedError
      end
    end
  end
end
