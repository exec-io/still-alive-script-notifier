# encoding: utf-8
require 'spec_helper'

describe ScriptNotifier::Router do

  it "instantiates" do
    expect { ScriptNotifier::Router.new({}) }.to_not raise_error
  end

  it "raises an error with no message" do
    expect { ScriptNotifier::Router.new }.to raise_error(ArgumentError)
  end

  context "extracting data from the message" do

    let(:subject) { ScriptNotifier::Router.new(sample_message) }

    it "extracts the data and then delivers the messages when told to deliver" do
      subject.should_receive(:extract).with(sample_message).once.and_return(['script', ['notifications']])
      subject.should_receive(:route!).with('script', ['notifications']).once
      subject.deliver!
    end

    it "extracts the script data and notifications from the message hash" do
      script_data, notifications = subject.send(:extract, sample_message)

      script_data.should == sample_message.delete_if { |k,v| k == 'notifications' }
      notifications.should == sample_message['notifications']
    end

  end

end
