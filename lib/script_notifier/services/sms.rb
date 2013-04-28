module ScriptNotifier
  module Services
    class Sms

      attr_reader :address
      include Services::Base

      def deliver!
        @address = payload['address']

        begin
          if success
            message = "StillAlive PASS: Your script #{script_name} for site #{site_name} is now passing"
          else
            message = "StillAlive FAIL: '#{failure_message}' on script #{script_name} for site #{site_name}"
          end

          ScriptNotifier::Providers::MessageMedia::Provider.send_alert_text_message!(address, message)
          return_values = { :success => true, :timestamp => Time.now.utc.iso8601 }

        rescue Providers::MessageMedia::InvalidRecipientError
          error = {
                    :message => "ERROR: we could not deliver to #{address}, please check the number and update your settings.",
                    :type => 'InvalidRecipient'
                  }
          return_values = { :success => false, :timestamp => Time.now.utc.iso8601, :error => error }
        rescue => e
          error = {
                    :message => "ERROR: we could not deliver to #{address} due to an internal error.",
                    :type => e.class.to_s
                  }
          return_values = { :success => false, :timestamp => Time.now.utc.iso8601, :error => error }

          error = "ScriptNotifier::Services::Sms could not send message to '#{address.inspect}'"
          ScriptNotifier.rescue_action_and_report(e, error)
        end

        return_values
      end

    end
  end
end