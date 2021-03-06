# encoding: utf-8
require 'spec_helper'

describe ScriptNotifier::Router do

  let(:subject) { ScriptNotifier::Router.new(sample_failure_message) }
  let(:sent_at) { Time.now.utc.iso8601 }
  let(:notification_count) { sample_failure_message[:notifications].count }

  it "instantiates" do
    expect { ScriptNotifier::Router.new({}) }.to_not raise_error
  end

  it "raises an error with no message" do
    expect { ScriptNotifier::Router.new }.to raise_error(ArgumentError)
  end

  context "extracting data from the message" do
    it "extracts the script data and notifications from the message hash" do
      subject.instance_variable_get(:@script_data).should == sample_failure_message.delete_if { |k,v| k == :notifications }
      subject.instance_variable_get(:@notifications).should == sample_failure_message[:notifications]
    end
  end

  context "delivering the messages" do
    it "sends a notification for each notification" do
      subject.should_receive(:send_notification).exactly(notification_count).times.and_return({})
      subject.deliver!
    end

    it "merges the result given from sending the notification into the return hash" do
      Timecop.freeze(Time.now) do
        subject.should_receive(:send_notification).exactly(notification_count).times.and_return({:success => true, :sent_at => sent_at})
        result = subject.deliver!
        result.should == sample_result
      end
    end

    context "each service" do
      before(:each) do
        @script_data = subject.instance_variable_get(:@script_data)
        @service_instance = mock(ScriptNotifier::Services::Base)
      end

      it "instantiates and sends an sms notification" do
        notification = { :service => 'sms', :payload => {:address => '+61432124194'} }
        ScriptNotifier::Services::Sms.should_receive(:new).once.with(@script_data, notification).and_return(@service_instance)
        @service_instance.should_receive(:deliver!).once
        subject.send(:send_notification, notification)
      end

      it "instantiates and sends an email notification" do
        notification = { :service => 'email', :payload => {:address => 'mikel@example.com'} }
        ScriptNotifier::Services::Email.should_receive(:new).once.with(@script_data, notification).and_return(@service_instance)
        @service_instance.should_receive(:deliver!).once
        subject.send(:send_notification, notification)
      end

      it "instantiates and sends an twitter notification" do
        notification = { :service => 'twitter', :payload => {:address => '@lindsaar'} }
        ScriptNotifier::Services::Twitter.should_receive(:new).once.with(@script_data, notification).and_return(@service_instance)
        @service_instance.should_receive(:deliver!).once
        subject.send(:send_notification, notification)
      end

      it "logs and returns a failure result if no service is found" do
        notification = { :service => 'unknown', :payload => {:address => '@lindsaar'} }

        time = Time.now
        Timecop.freeze(time) do
          result = subject.send(:send_notification, notification)
          result.should eq({:success => false, :sent_at => time.utc.iso8601, :error => {:type => 'ArgumentError', :message => 'Can not process "unknown" alerts at this time'}})
        end
      end

    end

  end

end
