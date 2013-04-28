require 'spec_helper'

describe ScriptNotifier::Services::Sms do

  def failure_script_result(attrs = {})
    sample_failure_script_data.merge!(attrs)
  end

  def success_script_result(attrs = {})
    sample_success_script_data.merge!(attrs)
  end

  def notification(attrs = {})
    sample_notifications.select { |n| n['service'] == 'sms' }.first.merge!(attrs)
  end

  subject { ScriptNotifier::Services::Sms.new(failure_script_result, notification) }

  it "accepts script data and notificaiton hashen" do
    expect { subject }.to_not raise_error(ArgumentError)
  end

  describe "deliver!" do

    let(:address)         { notification['payload']['address'] }
    let(:failure_message) { failure_script_result['failure_message'] }
    let(:sms_provider)    { ScriptNotifier::Providers::MessageMedia::Provider }

    context "without error from the provider" do

      before(:each) do
        sms_provider.stub!(:send_alert_text_message!)
      end

      it "returns a success hash" do
        time = Time.now
        Timecop.freeze(time) do
          subject.deliver!.should eq({ :success => true, :timestamp => time.utc.iso8601 })
        end
      end

      it "sends the address and failure message to the SMS provider class if the script failed" do
        message = "StillAlive FAIL: '#{failure_message}' on script #{failure_script_result['script_name']} for site #{failure_script_result['site_name']}"
        sms_provider.should_receive(:send_alert_text_message!).with(address, message)
        subject.deliver!
      end

      it "sends the address and success message to the SMS provider class if the script passed" do
        message = "StillAlive PASS: Your script #{success_script_result['script_name']} for site #{success_script_result['site_name']} is now passing"
        service = ScriptNotifier::Services::Sms.new(success_script_result, notification)
        sms_provider.should_receive(:send_alert_text_message!).with(address, message)
        service.deliver!
      end


    end

    context "with error from the provider" do

      it "returns an error if InvalidRecipient" do
        sms_provider.should_receive(:send_alert_text_message!).and_raise(ScriptNotifier::Providers::MessageMedia::InvalidRecipientError)

        error_result = { :message => "ERROR: we could not deliver to +61432124194, please check the number and update your settings.",
                         :type => 'InvalidRecipient'
                       }
        time = Time.now
        Timecop.freeze(time) do
          subject.deliver!.should eq({ :success => false, :timestamp => time.utc.iso8601, :error => error_result })
        end
      end

      it "notifies airbrake if there was a different error" do
        sms_provider.should_receive(:send_alert_text_message!).and_raise(StandardError)
        ScriptNotifier.should_receive(:rescue_action_and_report).once

        error_result = { :message => "ERROR: we could not deliver to +61432124194 due to an internal error.",
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
