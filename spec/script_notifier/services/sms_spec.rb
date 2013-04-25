require 'spec_helper'

describe ScriptNotifier::Services::Sms do

  def script_data(attrs = {})
    {
      'script_id' => 1,
      'site_name' => 'My Site',
      'script_name' => 'My Script',
      'failure_message' => 'Could not find ABC on the page',
      'failure_step' => 3
    }.merge!(attrs)
  end

  def notification(attrs = {})
    {
      'type' => 'sms',
      'address' => '+61432124194',
      'user_id' => 111
    }.merge!(attrs)
  end

  subject { ScriptNotifier::Services::Sms.new(script_data, notification) }

  it "accepts script data and notificaiton hashen" do
    expect { subject }.to_not raise_error(ArgumentError)
  end

  describe "deliver!" do

    let(:address)         { notification['address'] }
    let(:failure_message) { script_data['failure_message'] }
    let(:sms_provider)    { ScriptNotifier::Providers::MessageMedia::Provider }
    let(:result_message)  { "StillAlive FAIL: '#{failure_message}' on script #{script_data['script_name']} for site #{script_data['site_name']}" }
    
    context "successfully" do

      before(:each) do
        sms_provider.stub!(:send_alert_text_message!)
      end

      it "sends the address and failure message to the SMS provider class" do
        sms_provider.should_receive(:send_alert_text_message!).with(address, result_message)
        subject.deliver!
      end

      it "returns a success hash" do
        time = Time.now
        Timecop.freeze(time) do
          subject.deliver!.should eq({ :success => true, :timestamp => time.utc.iso8601 })
        end
      end

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
