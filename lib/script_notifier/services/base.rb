module ScriptNotifier
  module Services
    class Base
      def initialize(message)

      end

      def deliver!
        raise NotImplementedError
      end
    end
  end
end
