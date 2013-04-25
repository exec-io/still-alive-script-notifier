module ScriptNotifier
  module Services
    class Base

      attr_reader :script_data, :notification

      def initialize(script_data, notification)
        @script_data  = script_data
        @notification = notification
      end

      def deliver!
        raise NotImplementedError
      end
    end
  end
end
