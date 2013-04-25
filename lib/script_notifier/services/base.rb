module ScriptNotifier
  module Services
    class Base

      attr_reader :site_name, :script_name, :script_id, :failure_message, :failure_step, :address, :success

      def initialize(script_data, notification)
        @script_data  = script_data
        @notification = notification

        @site_name       = script_data['site_name']
        @script_id       = script_data['script_id']
        @script_name     = script_data['script_name']
        @failure_message = script_data['failure_message']
        @failure_step    = script_data['failure_step']
        @address         = notification['address']
        @success         = @failure_message.blank?
      end

      def deliver!
        raise NotImplementedError
      end
    end
  end
end
