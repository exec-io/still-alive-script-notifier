require 'spec_helper'

describe ScriptNotifier::Services::Twitter do

  def failure_script_result(attrs = {})
    sample_failure_script_data.merge!(attrs)
  end

  def success_script_result(attrs = {})
    sample_success_script_data.merge!(attrs)
  end

  def notification(attrs = {})
    sample_notifications.select { |n| n[:service] == 'twitter' }.first.merge!(attrs)
  end

  subject { ScriptNotifier::Services::Twitter.new(failure_script_result, notification) }

  it "accepts script data and notificaiton hashen" do
    expect { subject }.to_not raise_error(ArgumentError)
  end

  describe "deliver!" do

    let(:address)         { notification[:payload][:address] }
    let(:site_name)       { failure_script_result[:site_name] }
    let(:script_name)         { failure_script_result[:script_name] }
    let(:failure_message) { failure_script_result[:failure_message] }

    context "without error from the provider" do

      before(:each) do
        Twitter.stub!(:send_alert_text_message!)
      end

      it "returns a success hash" do
       stub_request(:post, "https://api.twitter.com/1.1/statuses/update.json").
         with(:body => {"status"=>"@example: StillAlive FAIL: 'Could not find ABC on the page' on script My Script for site My Site"}).
         to_return(:status => 200, :body => "", :headers => {})

        time = Time.now
        Timecop.freeze(time) do
          subject.deliver!.should eq({ :success => true, :sent_at => time.utc.iso8601 })
        end
      end

      it "sends the failure message to Twitter if the script failed" do
        message = "#{address}: StillAlive FAIL: '#{failure_message}' on script #{script_name} for site #{site_name}"
        Twitter.should_receive(:update).with(message)
        subject.deliver!
      end

      it "sends the success message to Twitter if the script passed" do
        message = "#{address}: StillAlive PASS: Your script #{script_name} for site #{site_name} is now passing"
        service = ScriptNotifier::Services::Twitter.new(success_script_result, notification)
        Twitter.should_receive(:update).with(message)
        service.deliver!
      end


    end

    context "with error from the provider" do

      it "notifies airbrake if there was a different error" do
        Twitter.should_receive(:update).and_raise(StandardError)
        ScriptNotifier.should_receive(:rescue_action_and_report).once

        error_result = { :message => "ERROR: we could not deliver to '@example' due to an internal error.",
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
