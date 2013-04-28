require 'spec_helper'

describe ScriptNotifier::Services::Flowdock do

  def failure_script_result(attrs = {})
    sample_failure_script_data.merge!(attrs)
  end

  def success_script_result(attrs = {})
    sample_success_script_data.merge!(attrs)
  end

  def notification(attrs = {})
    sample_notifications.select { |n| n['service'] == 'flowdock' }.first.merge!(attrs)
  end

  subject { ScriptNotifier::Services::Flowdock.new(failure_script_result, notification) }

  it "accepts script data and notificaiton hashen" do
    expect { subject }.to_not raise_error(ArgumentError)
  end

  describe "deliver!" do

    let(:site_name) { failure_script_result['site_name'] }
    let(:script_name) { failure_script_result['script_name'] }
    let(:failure_message) { failure_script_result['failure_message'] }
    let(:failure_attempts) { failure_script_result['failure_attempts'] }
    let(:tags) { failure_script_result['failure_attempts'] }

    context "without error from the provider" do

      before(:each) do
        subject.stub!(:send_message_to_flowdock)
      end

      it "returns a success hash" do
        time = Time.now
        Timecop.freeze(time) do
          subject.deliver!.should eq({ :success => true, :timestamp => time.utc.iso8601 })
        end
      end

      it "sends the failure message to Flowdock if the script failed" do
        message = "StillAlive FAIL: Just received '#{failure_message}' on script #{script_name} for site #{site_name} - #{failure_attempts} failures - https://stillalive.com/my/dashboard"
        subject.should_receive(:send_message_to_flowdock).with(message)
        subject.deliver!
      end

      it "sends the success message to Flowdock if the script passed" do
        message = "StillAlive PASS: Your script #{script_name} for site #{site_name} is now passing again after #{failure_attempts} - https://stillalive.com/my/dashboard"
        service = ScriptNotifier::Services::Flowdock.new(success_script_result, notification)
        service.should_receive(:send_message_to_flowdock).with(message)
        service.deliver!
      end

      it "finds the flowdock flow" do
        api_token = notification['payload']['api_token']

        service = ScriptNotifier::Services::Flowdock.new(success_script_result, notification)
        client = mock('FlowClient')
        ::Flowdock::Flow.should_receive(:new).with(:api_token => api_token, :external_user_name => "StillAlive").and_return(client)

        service.send(:find_flowdock_flow)
      end

      it "speaks into the flowdock chat with tags" do
        tags = notification['payload']['tags']

        service = ScriptNotifier::Services::Flowdock.new(success_script_result, notification)
        flow = mock('Flowdock::Flow')
        service.should_receive(:find_flowdock_flow).and_return(flow)
        flow.should_receive(:push_to_chat).with(:content => 'test', :tags => tags).once

        service.send(:send_message_to_flowdock, 'test')
      end

      it "speaks into the flowdock chat without tags" do
        no_tag_notification = notification
        no_tag_notification['payload']['tags'] = nil

        service = ScriptNotifier::Services::Flowdock.new(success_script_result, no_tag_notification)
        flow = mock('Flowdock::Flow')
        service.should_receive(:find_flowdock_flow).and_return(flow)
        flow.should_receive(:push_to_chat).with(:content => 'test', :tags => []).once

        service.send(:send_message_to_flowdock, 'test')
      end

    end

    context "with an error from the provider" do

      it "notifies the user if there was an invalid parameter error" do
        subject.stub!(:send_message_to_flowdock).and_raise(::Flowdock::Flow::InvalidParameterError)
        ScriptNotifier.should_not_receive(:rescue_action_and_report)

        error_result = {
                         :message => "ERROR: we could not deliver to your flowdock chat on script #{script_name} due to an invalid token or tag, please check your settings.",
                         :type => 'InvalidParameterError'
                       }
        time = Time.now
        Timecop.freeze(time) do
          subject.deliver!.should eq({ :success => false, :timestamp => time.utc.iso8601, :error => error_result })
        end
      end

      it "notifies the user if there was an api error" do
        subject.stub!(:send_message_to_flowdock).and_raise(::Flowdock::Flow::ApiError)
        ScriptNotifier.should_not_receive(:rescue_action_and_report)

        error_result = {
                         :message => "ERROR: we could not deliver to your flowdock chat on script #{script_name} due to a Flowdock API Error.",
                         :type => 'ApiError'
                       }
        time = Time.now
        Timecop.freeze(time) do
          subject.deliver!.should eq({ :success => false, :timestamp => time.utc.iso8601, :error => error_result })
        end
      end

      it "notifies airbrake if there was a different error" do
        subject.stub!(:send_message_to_flowdock).and_raise(StandardError)
        ScriptNotifier.should_receive(:rescue_action_and_report).once

        error_result = { :message => "ERROR: we could not deliver to your flowdock chat on script #{script_name} due to an internal error.",
                         :type => 'StandardError'
                       }
        time = Time.now
        Timecop.freeze(time) do
          subject.deliver!.should eq({ :success => false, :timestamp => time.utc.iso8601, :error => error_result })
        end
      end

    end
  end
end
