module ScriptNotifier
  module Services

    require 'erb'
    require 'mail'

    if ENV['SCRIPT_NOTIFIER_ENV'] == 'test'
      Mail.defaults { delivery_method :test }
    else
      Mail.defaults { delivery_method :smtp, ScriptNotifier::Base.email_settings }
    end

    class Email

      attr_reader :address
      include Services::Base

      def deliver!
        @address = payload['address']
        @help_url = 'http://help.stillalive.com/'

        begin
          if success
            success_email.deliver
          else
            failure_email.deliver
          end

          return_values = { :success => true, :timestamp => Time.now.utc.iso8601 }
        rescue => e
          error = {
                    :message => "ERROR: we could not deliver to '#{address}' due to an internal error.",
                    :type => e.class.to_s
                  }
          return_values = { :success => false, :timestamp => Time.now.utc.iso8601, :error => error }

          error = "ScriptNotifier::Services::Email could not send message to '#{address.inspect}'"
          ScriptNotifier.rescue_action_and_report(e, error)
        end

        return_values
      end

    private

      def failure_email
        subject = "StillAlive FAIL: '#{@failure_message}' on script #{@script_name} for site #{@site_name}"
        build_email(subject, __method__)
      end

      def success_email
        subject = "StillAlive PASS: Your script #{@script_name} for site #{@site_name} is now passing"
        build_email(subject, __method__)
      end

      def test
        subject = "StillAlive TEST: Alert email for script #{@script_name} for #{@site_name} site"
        build_email(subject, __method__)
      end

      def build_email(subject, method_name)
        @mail = Mail.new(:from => "StillAlive <system@#{ScriptNotifier::Base.email_from_domain}>",
                         :to => address, :subject => subject, :content_type => 'multipart/related')

        if success
          include_success_logo
        else
          include_failure_logo
        end
        include_signature
        @attachments = @mail.attachments

        text_body = render_part(method_name, 'text')
        text_part = Mail::Part.new do
          body text_body
        end

        html_body = render_part(method_name, 'html')
        html_part = Mail::Part.new do
          content_type 'text/html; charset=UTF-8'
          body html_body
        end

        @mail.part(:content_type => "multipart/alternative") do |p|
          p.text_part = text_part
          p.html_part = html_part
        end
        File.open('/Users/mikel/text.eml', 'w') { |f| f.write(@mail.encoded) }
        @mail
      end

      def render_template(name, type)
        template = File.read(File.join(File.dirname(__FILE__), 'email', 'templates', "#{name}.#{type}.erb"))
        renderer = ERB.new(template)
        renderer.result(binding)
      end

      def render_part(name, type)
        render_template('layout', type) do
          render_template(name, type)
        end
      end

      def include_success_logo
        @mail.add_file(:filename => 'header.jpg', :content => read_image('header.jpg'))
      end

      def include_failure_logo
        @mail.add_file(:filename => 'header.jpg', :content => read_image('header-error.jpg'))
      end

      def include_signature
        @mail.add_file(:filename => 'signature.jpg', :content => read_image('team-signature.jpg'))
      end

      def read_image(image)
        File.read(File.join(File.dirname(__FILE__), 'email', 'images', image))
      end

      def render_failure_message(step)
        return "" if failure_step_id.blank?
        if step.first.to_i == failure_step_id.to_i
          "<span class='failure_message'>#{failure_message}</span>"
        else
          ""
        end
      end

      def step_class(step)
        failed_step_index = script_steps.index { |a| a.first.to_i == failure_step_id.to_i }
        current_step_index = script_steps.index(step)
        case
        when failed_step_index.nil?
          "passed"
        when current_step_index < failed_step_index
          "passed"
        when current_step_index == failed_step_index
          "failed"
        else
          "pending"
        end
      end

      def render_steps
        list_elements = script_steps.map do |step|
          "<li class='step_item #{step_class(step)}'><span>#{step.last}</span>#{render_failure_message(step)}</li>"
        end
        "<ol class='steps'>#{list_elements.join}</ol>"
      end

    end
  end
end
