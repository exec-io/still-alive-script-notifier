module ScriptNotifier
  module Services
    module Base

      attr_reader :site_name, :script_name, :script_steps, :script_id, :success,
                  :failure_message, :failure_step_id, :failure_attempts,
                  :notification, :payload

      def initialize(script_data, notification)
        @script_data  = script_data
        @notification = notification

        @site_name        = script_data[:site_name]
        @script_id        = script_data[:script_id]
        @script_name      = script_data[:script_name]
        @script_steps     = script_data[:script]
        @failure_message  = script_data[:failure_message]
        @failure_step_id  = script_data[:failure_step_id]
        @failure_attempts = script_data[:failure_attempts]
        @notification     = notification
        @payload          = notification[:payload]
        @success          = @failure_message.blank?
        after_initialize
      end

      def after_initialize
        # Implemented in included classes
      end

      def deliver!
        raise NotImplementedError
      end
    end
  end
end
