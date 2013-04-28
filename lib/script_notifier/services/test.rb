module ScriptNotifier
  module Services
    class Test

      include Services::Base

      def deliver!
        message = "ScriptNotifier: got '#{notification['service']}' for address '#{address}' for script #{script_id}"
        log(message)
        return_values = { :success => true, :timestamp => Time.now.utc.iso8601 }
      end

    end
  end
end