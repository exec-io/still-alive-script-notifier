require 'spec_helper'

describe ScriptNotifier::Services::Campfire do

  def failure_script_result(attrs = {})
    sample_failure_script_data.merge!(attrs)
  end

  def success_script_result(attrs = {})
    sample_success_script_data.merge!(attrs)
  end

  def notification(attrs = {})
    sample_notifications.select { |n| n[:service] == 'campfire' }.first.merge!(attrs)
  end

  subject { ScriptNotifier::Services::Campfire.new(failure_script_result, notification) }

  it "accepts script data and notificaiton hashen" do
    expect { subject }.to_not raise_error(ArgumentError)
  end

  describe "deliver!" do

    let(:site_name) { failure_script_result[:site_name] }
    let(:script_name) { failure_script_result[:script_name] }
    let(:room_name)   { notification[:payload][:room_name] }
    let(:failure_message) { failure_script_result[:failure_message] }
    let(:failure_attempts) { failure_script_result[:failure_attempts] }

    context "without error from the provider" do

      before(:each) do
        subject.stub!(:send_message_to_campfire)
      end

      it "returns a success hash" do
        time = Time.now
        Timecop.freeze(time) do
          subject.deliver!.should eq({ :success => true, :sent_at => time.utc.iso8601 })
        end
      end

      it "sends the failure message to Campfire if the script failed" do
        message = "StillAlive FAIL: Just received '#{failure_message}' on script #{script_name} for site #{site_name} - #{failure_attempts} failures - https://stillalive.com/my/dashboard"
        subject.should_receive(:send_message_to_campfire).with(message)
        subject.deliver!
      end

      it "sends the success message to Campfire if the script passed" do
        message = "StillAlive PASS: Your script #{script_name} for site #{site_name} is now passing again after #{failure_attempts} - https://stillalive.com/my/dashboard"
        service = ScriptNotifier::Services::Campfire.new(success_script_result, notification)
        service.should_receive(:send_message_to_campfire).with(message)
        service.deliver!
      end

      it "finds the campfire room" do
        subdomain = notification[:payload][:subdomain]
        api_token = notification[:payload][:api_token]
        room_name = notification[:payload][:room_name]

        service = ScriptNotifier::Services::Campfire.new(success_script_result, notification)
        client = mock('TinderClient')
        ::Tinder::Campfire.should_receive(:new).with(subdomain, :token => api_token, :ssl => true).and_return(client)
        client.should_receive(:find_room_by_name).with(room_name).once

        service.send(:find_campfire_room)
      end

      it "speaks into the campfire room with sound" do
        service = ScriptNotifier::Services::Campfire.new(success_script_result, notification)
        room = mock('TinderRoon')
        service.should_receive(:find_campfire_room).and_return(room)
        room.should_receive(:speak).with('test').once
        room.should_receive(:play).with('trombone')

        service.send(:send_message_to_campfire, 'test')
      end

      it "speaks into the campfire room without sound" do
        no_sound_notification = notification
        no_sound_notification[:payload][:play_sound] = false

        service = ScriptNotifier::Services::Campfire.new(success_script_result, no_sound_notification)
        room = mock('TinderRoon')
        service.should_receive(:find_campfire_room).and_return(room)
        room.should_receive(:speak).with('test').once
        room.should_not_receive(:play).with('trombone')

        service.send(:send_message_to_campfire, 'test')
      end

    end

    context "with error from the provider" do

      it "notifies the user if there was an authentication error" do
        subject.stub!(:send_message_to_campfire).and_raise(::Tinder::AuthenticationFailed)
        ScriptNotifier.should_not_receive(:rescue_action_and_report)

        error_result = {
                         :message => "ERROR: we could not deliver to your campfire room '#{room_name}' on script #{script_name} due to an authentication failure, please check your settings.",
                         :type => 'AuthenticationFailed'
                       }
        time = Time.now
        Timecop.freeze(time) do
          subject.deliver!.should eq({ :success => false, :sent_at => time.utc.iso8601, :error => error_result })
        end
      end

      it "notifies airbrake if there was a different error" do
        subject.stub!(:send_message_to_campfire).and_raise(StandardError)
        ScriptNotifier.should_receive(:rescue_action_and_report).once

        error_result = { :message => "ERROR: we could not deliver to your campfire room '#{room_name}' on script #{script_name} due to an internal error.",
                         :type => 'StandardError'
                       }
        time = Time.now
        Timecop.freeze(time) do
          subject.deliver!.should eq({ :success => false, :sent_at => time.utc.iso8601, :error => error_result })
        end
      end

    end
  end
end
