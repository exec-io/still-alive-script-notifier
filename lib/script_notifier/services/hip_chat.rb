module ScriptNotifier
  module Services

    require 'hipchat'

    class HipChat

      include Services::Base

      def after_initialize
        @room_name  = payload['room_name']
        @api_token  = payload['api_token']
        @notify     = payload['notify'] == true ? 1 : 0
      end

      def deliver!
        if success
          message = "StillAlive PASS: Your script #{script_name} for site #{site_name} is now passing again after #{failure_attempts} - https://stillalive.com/my/dashboard"
        else
          message = "StillAlive FAIL: Just received '#{failure_message}' on script #{script_name} for site #{site_name} - #{failure_attempts} failures - https://stillalive.com/my/dashboard"
        end

        begin
          send_message_to_hip_chat(message)
          return_values = { :success => true, :timestamp => Time.now.utc.iso8601 }

        rescue ::HipChat::UnknownRoom
          error = {
                    :message => "ERROR: we could not find the HipChat room '#{@room_name}' on script #{script_name}, please check your settings.",
                    :type => 'UnknownRoom'
                  }
          return_values = { :success => false, :timestamp => Time.now.utc.iso8601, :error => error }

        rescue ::HipChat::Unauthorized
          error = {
                    :message => "ERROR: we could not deliver to your HipChat room '#{@room_name}' on script #{script_name} due to an authentication failure, please check your settings.",
                    :type => 'Unauthorized'
                  }
          return_values = { :success => false, :timestamp => Time.now.utc.iso8601, :error => error }

        rescue ::HipChat::UnknownResponseCode
          error = {
                    :message => "ERROR: we could not find the HipChat room '#{@room_name}' on script #{script_name}, due to a HipChat API error.",
                    :type => 'UnknownResponseCode'
                  }
          return_values = { :success => false, :timestamp => Time.now.utc.iso8601, :error => error }

        rescue => e
          error = {
                    :message => "ERROR: we could not deliver to your HipChat room '#{@room_name}' on script #{script_name} due to an internal error.",
                    :type => e.class.to_s
                  }
          return_values = { :success => false, :timestamp => Time.now.utc.iso8601, :error => error }

          error = "ScriptNotifier::Services::HipChat could not send message to '#{payload.inspect}' due to #{e.class}"
          ScriptNotifier.rescue_action_and_report(e, error)

        end

        return_values
      end

    private

      def send_message_to_hip_chat(message)
        client = find_hip_chat_client
        client.rooms_message(@room_name, 'StillAlive', message, @notify, 'red')
      end

      def find_hip_chat_client
        ::HipChat::Client.new(@api_token)
      end

    end

  end
end