# encoding: utf-8
module ScriptNotifier

  class Router

    def initialize(message)
      @message = message
      extract_notifications
    end

    def deliver!
      threads = []

      @notifications.each_with_index do |notification, index|
        threads << Thread.new(notification, index) do |notification, index|
          result = send_notification(notification)
          @notifications[index][:sent_at] = result[:sent_at]
          @notifications[index][:success] = result[:success]
          @notifications[index][:error]   = result[:error] if result[:error].present?
        end
      end

      threads.each { |thread|  thread.join }

      @script_data.merge({:notifications => @notifications})
    end

    private

    def extract_notifications
      @notifications = @message[:notifications]
      @script_data = @message.reject { |k,v| k == :notifications }
    end

    def send_notification(notification)
      case notification[:service]
      when ScriptNotifier.test_run_mode
        Services::Tester.new(@script_data, notification).deliver!
      when 'sms'
        Services::Sms.new(@script_data, notification).deliver!
      when 'email'
        Services::Email.new(@script_data, notification).deliver!
      when 'twitter'
        Services::Twitter.new(@script_data, notification).deliver!
      else
        ScriptNotifier.log("#{Time.now}: Don't have a #{notification[:service]} service to use")
        {:success => false, :sent_at => Time.now.utc.iso8601, :error => {:type => 'ArgumentError', :message => "Can not process \"#{notification[:service]}\" alerts at this time"}}
      end
    end

  end
end
