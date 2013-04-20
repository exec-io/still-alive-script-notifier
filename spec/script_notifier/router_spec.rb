# encoding: utf-8
require 'spec_helper'

describe ScriptNotifier::Router do

  context "class methods" do
    let(:klass) { ScriptNotifier::Router }

    it "extracts the data and then delivers the messages when told to deliver" do
      klass.should_receive(:extract).with('message').once.and_return(['script', ['notifications']])
      klass.should_receive(:route!).with('script', ['notifications']).once
      klass.deliver!('message')
    end

    it "extracts the script data and notifications from the message hash" do
      script_data, notifications = klass.extract(sample_message)

      script_data.should == sample_message.delete_if { |k,v| k == 'notifications' }
      notifications.should == sample_message['notifications']
    end

    

  end


end
