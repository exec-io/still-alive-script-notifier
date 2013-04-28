module ScriptNotifier
  module Services

    require 'flowdock'

    class Flowdock

      include Services::Base

      def after_initialize
        @api_token  = payload['api_token']
        @tags       = payload['tags'] || []
      end

      def deliver!
        if success
          message = "StillAlive PASS: Your script #{script_name} for site #{site_name} is now passing again after #{failure_attempts} - https://stillalive.com/my/dashboard"
        else
          message = "StillAlive FAIL: Just received '#{failure_message}' on script #{script_name} for site #{site_name} - #{failure_attempts} failures - https://stillalive.com/my/dashboard"
        end

        begin
          send_message_to_flowdock(message)
          return_values = { :success => true, :timestamp => Time.now.utc.iso8601 }

        rescue ::Flowdock::Flow::InvalidParameterError
          error = {
                    :message => "ERROR: we could not deliver to your flowdock chat on script #{script_name} due to an invalid token or tag, please check your settings.",
                    :type => 'InvalidParameterError'
                  }
          return_values = { :success => false, :timestamp => Time.now.utc.iso8601, :error => error }

        rescue ::Flowdock::Flow::ApiError
          error = {
                    :message => "ERROR: we could not deliver to your flowdock chat on script #{script_name} due to a Flowdock API Error.",
                    :type => 'ApiError'
                  }
          return_values = { :success => false, :timestamp => Time.now.utc.iso8601, :error => error }

        rescue => e
          error = {
                    :message => "ERROR: we could not deliver to your flowdock chat on script #{script_name} due to an internal error.",
                    :type => e.class.to_s
                  }
          return_values = { :success => false, :timestamp => Time.now.utc.iso8601, :error => error }

          error = "ScriptNotifier::Services::Flowdock could not send message to '#{payload.inspect}' due to #{e.class}"
          ScriptNotifier.rescue_action_and_report(e, error)

        end

        return_values
      end

    private

      def send_message_to_flowdock(message)
        flow = find_flowdock_flow
        flow.push_to_chat(:content => message, :tags => @tags)
      end

      def find_flowdock_flow
        ::Flowdock::Flow.new(:api_token => @api_token, :external_user_name => "StillAlive")
      end

    end

  end
end