module ScriptNotifier
  module Services
    class Sms < Services::Base

      def deliver!(notification)

        address = notification['address']
        begin
          ScriptNotifier::Providers::MessageMedia::Service.send_alert_text_message!(address, message)
          return_values = { :success => true, :timestamp => Time.now.utc.iso8601 }

        rescue MessageMedia::InvalidRecipientError
          SystemNotifier.alert_mobile_incorrect(@collaborator.user, @address).deliver
          return_values = { :success => false, :error => 'ERROR' }

        rescue => e
          rescue_action_and_report(e)
        end

        return_values
      end

    end
  end
end