module ScriptNotifier
  module Services

    require 'twitter'

    ::Twitter.configure do |config|
      config.consumer_key = ScriptNotifier::Base.twitter_consumer_key
      config.consumer_secret = ScriptNotifier::Base.twitter_consumer_secret
      config.oauth_token = ScriptNotifier::Base.twitter_oauth_token
      config.oauth_token_secret = ScriptNotifier::Base.twitter_oauth_token_secret
    end

    class Twitter

      attr_reader :address
      include Services::Base

      def deliver!
        @address = payload['address']

        begin
          if success
            message = "#{address}: StillAlive PASS: Your script #{script_name} for site #{site_name} is now passing"
          else
            message = "#{address}: StillAlive FAIL: '#{failure_message}' on script #{script_name} for site #{site_name}"
          end

          ::Twitter.update(message)
          return_values = { :success => true, :timestamp => Time.now.utc.iso8601 }

        rescue => e
          error = {
                    :message => "ERROR: we could not deliver to '#{address}' due to an internal error.",
                    :type => e.class.to_s
                  }
          return_values = { :success => false, :timestamp => Time.now.utc.iso8601, :error => error }

          error = "ScriptNotifier::Services::Twitter could not send message to '#{address.inspect}'"
          ScriptNotifier.rescue_action_and_report(e, error)
        end

        return_values
      end

    end
  end
end
