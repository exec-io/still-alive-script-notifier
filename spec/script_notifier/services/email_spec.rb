require 'spec_helper'

describe ScriptNotifier::Services::Email do

  before(:each) do
    Mail::TestMailer.deliveries.clear
  end

  def failure_script_result(attrs = {})
    sample_failure_script_data.merge!(attrs)
  end

  def success_script_result(attrs = {})
    sample_success_script_data.merge!(attrs)
  end

  def notification(attrs = {})
    sample_notifications.select { |n| n['service'] == 'email'}.first.merge!(attrs)
  end

  subject { ScriptNotifier::Services::Email.new(failure_script_result, notification) }

  it "accepts script data and notificaiton hashen" do
    expect { subject }.to_not raise_error(ArgumentError)
  end

  describe "deliver!" do

    let(:address)         { notification['payload']['address'] }
    let(:failure_message) { script_data['failure_message'] }

    context "on failure" do

      subject { ScriptNotifier::Services::Email.new(failure_script_result, notification) }

      it "sends a failure email" do
        expect {
          subject.deliver!
        }.to change(Mail::TestMailer.deliveries, :count).by(1)
      end

      it "returns a success hash" do
        time = Time.now
        Timecop.freeze(time) do
          subject.deliver!.should eq({ :success => true, :timestamp => time.utc.iso8601 })
        end
      end

      it "delivers a failure email" do
        subject.deliver!
        subject_line = "StillAlive FAIL: 'Could not find ABC on the page' on script My Script for site My Site"
        mail = Mail::TestMailer.deliveries.first
        mail.subject.should eq(subject_line)
        mail.text_part.body.should include('Error Notification for My Script on My Site.')
        mail.text_part.body.should include('Failed Attempts: 3')
      end

    end

    context "on success" do

      subject { ScriptNotifier::Services::Email.new(success_script_result, notification) }

      it "sends a success email" do
        expect {
          subject.deliver!
        }.to change(Mail::TestMailer.deliveries, :count).by(1)
      end

      it "returns a success hash" do
        time = Time.now
        Timecop.freeze(time) do
          subject.deliver!.should eq({ :success => true, :timestamp => time.utc.iso8601 })
        end
      end

      it "delivers a success email" do
        subject.deliver!
        subject_line = "StillAlive PASS: Your script My Script for site My Site is now passing"
        mail = Mail::TestMailer.deliveries.first
        mail.subject.should eq(subject_line)
        mail.text_part.body.should include('Success Notification for My Script on My Site.')
        mail.text_part.body.should include('Prior Failed Attempts: 3')
      end

    end

    context "unsuccessfully" do

      it "returns an error if InvalidRecipient" do
        ScriptNotifier.stub!(:rescue_action_and_report)
        Mail::Message.any_instance.stub(:deliver).and_raise(StandardError)

        error_result = { :message => "ERROR: we could not deliver to 'mikel@example.com' due to an internal error.",
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
