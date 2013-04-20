# encoding: utf-8
require 'spec_helper'

def sample_message(params = {})
  {
    'script_id' => 1,
    'site_name' => 'My Site',
    'script_name' => 'My Script',
    'failure_message' => 'Could not find ABC on the page',
    'failure_step' => 3,
    'notifications' => [
      {
        'type' => 'sms',
        'address' => '+61432124194'
      },
      {
        'type' => 'email',
        'address' => 'mikel@example.com'
      }
    ]
  }.merge!(params)
end

def sample_result(params = {})
  {
    'script_id' => 1,
    'site_name' => 'My Site',
    'script_name' => 'My Script',
    'failure_message' => 'Could not find ABC on the page',
    'failure_step' => 3,
    'notifications' => [
      {
        'type' => 'sms',
        'address' => '+61432124194',
        'success' => true,
        'sent_at' => 'TIMESTAMP'
      },
      {
        'type' => 'email',
        'address' => 'mikel@example.com',
        'success' => true,
        'sent_at' => 'TIMESTAMP'
      }
    ]
  }.merge!(params)
end

describe ScriptNotifier::Router do

  it "has a run! method" do
    subject.should respond_to(:run!)
  end

  it "is not running at first" do
    subject.should_not be_running
  end

  it "has a stop running method" do
    subject.should respond_to(:stop_running!)
  end

  context "process! method" do

    it "gets the next message, processes it and sends the results when told to process!" do
      subject.should_receive(:get_next_notification).once.and_return(sample_message)
      subject.should_receive(:route).once.with(sample_message).and_return(sample_result)
      subject.should_receive(:send_result).once.with(sample_result)
      subject.send(:process!)
    end

    it "returns nil and halts processing if get_next_notification_message returns nil" do
      subject.stub!(:get_next_notification).once.and_return(nil)
      subject.should_not_receive(:route)
      subject.should_not_receive(:send_result)
      subject.send(:process!)
    end
  end

  context "getting the next message" do
    it "returns a hash of the JSON message" do
      subject.should_receive(:receive_message_from_queue).and_return(sample_message.to_json)
      subject.send(:get_next_notification).should == sample_message
    end

    it "returns nil if there is an error parsing the message" do
      subject.should_receive(:receive_message_from_queue).and_return("invalid-json#{sample_message.to_json}")
      subject.send(:get_next_notification).should == nil
    end
  end

  context "routing the notification to the handler" do
    it "sends the notifications hash to Services class" do
      ScriptNotifier::Services::Base.should_receive(:deliver!).with(sample_message).once.and_return(sample_result)
      subject.send(:route, sample_message).should == sample_result
    end
  end

  context "sending the result message" do
    it "returns a hash of the JSON message" do
      subject.should_receive(:send_message_to_queue).once.with(sample_result.to_json)
      subject.send(:send_result, sample_result)
    end
  end

end
