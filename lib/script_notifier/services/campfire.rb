module ScriptNotifier
  module Services

    require 'tinder'

    class Campfire

      include Services::Base

      def after_initialize
        @room_name  = payload['room_name']
        @api_token  = payload['api_token']
        @subdomain  = payload['subdomain']
        @play_sound = payload['play_sound'] || false
        @sound      = payload['sound'] || 'trombone'
      end

      def deliver!
        if success
          message = "StillAlive PASS: Your script #{script_name} for site #{site_name} is now passing again after #{failure_attempts} - https://stillalive.com/my/dashboard"
        else
          message = "StillAlive FAIL: Just received '#{failure_message}' on script #{script_name} for site #{site_name} - #{failure_attempts} failures - https://stillalive.com/my/dashboard"
        end

        begin
          send_message_to_campfire(message)
          return_values = { :success => true, :timestamp => Time.now.utc.iso8601 }

        rescue ::Tinder::AuthenticationFailed
          error = {
                    :message => "ERROR: we could not deliver to your campfire room '#{@room_name}' on script #{script_name} due to an authentication failure, please check your settings.",
                    :type => 'AuthenticationFailed'
                  }
          return_values = { :success => false, :timestamp => Time.now.utc.iso8601, :error => error }

        rescue => e
          error = {
                    :message => "ERROR: we could not deliver to your campfire room '#{@room_name}' on script #{script_name} due to an internal error.",
                    :type => e.class.to_s
                  }
          return_values = { :success => false, :timestamp => Time.now.utc.iso8601, :error => error }

          error = "ScriptNotifier::Services::Campfire could not send message to '#{payload.inspect}' due to #{e.class}"
          ScriptNotifier.rescue_action_and_report(e, error)

        end

        return_values
      end

    private

      def send_message_to_campfire(message)
        room = find_campfire_room
        room.play(@sound) if @play_sound
        room.speak(message)
      end

      def find_campfire_room
        campfire = ::Tinder::Campfire.new(@subdomain, :token => @api_token, :ssl => true)
        campfire.find_room_by_name(@room_name)
      end

    end

  end
end