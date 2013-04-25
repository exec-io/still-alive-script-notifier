module ScriptNotifier
  module Services
    class Sms < Services::Base

      def deliver!(notification)

        address = notification['address']
        begin
          ScriptNotifier::Providers::MessageMedia::Provider.send_alert_text_message!(address, message)
          return_values = { :success => true, :timestamp => Time.now.utc.iso8601 }

        rescue Providers::MessageMedia::InvalidRecipientError
          SystemNotifier.alert_mobile_incorrect(address).deliver
          error = {
                    :message => "ERROR: we could not deliver to #{address}, please check the number and update your settings.",
                    :type => 'InvalidRecipient'
                  }
          return_values = { :success => false, :error => error }
        rescue => e
          ScriptNotifier.rescue_action_and_report(e, message)
        end

        return_values
      end

    end
  end
end