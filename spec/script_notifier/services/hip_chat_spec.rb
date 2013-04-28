require 'spec_helper'

describe ScriptNotifier::Services::HipChat do

  def failure_script_result(attrs = {})
    sample_failure_script_data.merge!(attrs)
  end

  def success_script_result(attrs = {})
    sample_success_script_data.merge!(attrs)
  end

  def notification(attrs = {})
    sample_notifications.select { |n| n['service'] == 'hip_chat' }.first.merge!(attrs)
  end

  subject { ScriptNotifier::Services::HipChat.new(failure_script_result, notification) }

  it "accepts script data and notificaiton hashen" do
    expect { subject }.to_not raise_error(ArgumentError)
  end

  describe "deliver!" do

    let(:site_name) { failure_script_result['site_name'] }
    let(:script_name) { failure_script_result['script_name'] }
    let(:room_name)   { notification['payload']['room_name'] }
    let(:failure_message) { failure_script_result['failure_message'] }
    let(:failure_attempts) { failure_script_result['failure_attempts'] }

    context "without error from the provider" do

      before(:each) do
        subject.stub!(:send_message_to_hip_chat)
      end

      it "returns a success hash" do
        time = Time.now
        Timecop.freeze(time) do
          subject.deliver!.should eq({ :success => true, :timestamp => time.utc.iso8601 })
        end
      end

      it "sends the failure message to HipChat if the script failed" do
        message = "StillAlive FAIL: Just received '#{failure_message}' on script #{script_name} for site #{site_name} - #{failure_attempts} failures - https://stillalive.com/my/dashboard"
        subject.should_receive(:send_message_to_hip_chat).with(message)
        subject.deliver!
      end

      it "sends the success message to HipChat if the script passed" do
        message = "StillAlive PASS: Your script #{script_name} for site #{site_name} is now passing again after #{failure_attempts} - https://stillalive.com/my/dashboard"
        service = ScriptNotifier::Services::HipChat.new(success_script_result, notification)
        service.should_receive(:send_message_to_hip_chat).with(message)
        service.deliver!
      end

      it "finds the HipChat client" do
        api_token = notification['payload']['api_token']

        service = ScriptNotifier::Services::HipChat.new(success_script_result, notification)
        client = mock('HipChatClient')
        ::HipChat::Client.should_receive(:new).with(api_token).and_return(client)

        service.send(:find_hip_chat_client)
      end

      it "speaks into the hip_chat room with notification" do
        room_name = notification['payload']['room_name']

        service = ScriptNotifier::Services::HipChat.new(success_script_result, notification)
        client = mock('HipChatClient')
        service.should_receive(:find_hip_chat_client).and_return(client)
        client.should_receive(:rooms_message).with(room_name, 'StillAlive', 'test', 1, 'red').once

        service.send(:send_message_to_hip_chat, 'test')
      end

      it "speaks into the hip_chat room without sound" do
        no_alert_notification = notification
        no_alert_notification['payload']['notify'] = nil

        service = ScriptNotifier::Services::HipChat.new(success_script_result, no_alert_notification)
        client = mock('HipChatClient')
        service.should_receive(:find_hip_chat_client).and_return(client)
        client.should_receive(:rooms_message).with(room_name, 'StillAlive', 'test', 0, 'red').once

        service.send(:send_message_to_hip_chat, 'test')
      end

    end

    context "with error from the provider" do

      it "notifies the user if there was an unknown room error" do
        subject.stub!(:send_message_to_hip_chat).and_raise(::HipChat::UnknownRoom)
        ScriptNotifier.should_not_receive(:rescue_action_and_report)

        error_result = {
                         :message => "ERROR: we could not find the HipChat room '#{room_name}' on script #{script_name}, please check your settings.",
                         :type => 'UnknownRoom'
                       }
        time = Time.now
        Timecop.freeze(time) do
          subject.deliver!.should eq({ :success => false, :timestamp => time.utc.iso8601, :error => error_result })
        end
      end

      it "notifies the user if there was an authentication error" do
        subject.stub!(:send_message_to_hip_chat).and_raise(::HipChat::Unauthorized)
        ScriptNotifier.should_not_receive(:rescue_action_and_report)

        error_result = {
                         :message => "ERROR: we could not deliver to your HipChat room '#{room_name}' on script #{script_name} due to an authentication failure, please check your settings.",
                         :type => 'Unauthorized'
                       }
        time = Time.now
        Timecop.freeze(time) do
          subject.deliver!.should eq({ :success => false, :timestamp => time.utc.iso8601, :error => error_result })
        end
      end

      it "notifies the user if there was an API error" do
        subject.stub!(:send_message_to_hip_chat).and_raise(::HipChat::UnknownResponseCode)
        ScriptNotifier.should_not_receive(:rescue_action_and_report)

        error_result = {
                         :message => "ERROR: we could not find the HipChat room '#{room_name}' on script #{script_name}, due to a HipChat API error.",
                         :type => 'UnknownResponseCode'
                       }
        time = Time.now
        Timecop.freeze(time) do
          subject.deliver!.should eq({ :success => false, :timestamp => time.utc.iso8601, :error => error_result })
        end
      end

      it "notifies airbrake if there was a different error" do
        subject.stub!(:send_message_to_hip_chat).and_raise(StandardError)
        ScriptNotifier.should_receive(:rescue_action_and_report).once

        error_result = { :message => "ERROR: we could not deliver to your HipChat room '#{room_name}' on script #{script_name} due to an internal error.",
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
