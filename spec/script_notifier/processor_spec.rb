# encoding: utf-8
require 'spec_helper'

describe ScriptNotifier::Processor do

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
      subject.should_receive(:get_next_notification).once.and_return(sample_error_message)
      subject.should_receive(:route).once.with(sample_error_message).and_return(sample_result)
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
      subject.should_receive(:receive_message_from_queue).and_return(sample_error_message.to_json)
      subject.send(:get_next_notification).should == sample_error_message
    end

    it "returns nil if there is an error parsing the message" do
      subject.should_receive(:receive_message_from_queue).and_return("invalid-json#{sample_error_message.to_json}")
      subject.send(:get_next_notification).should == nil
    end
  end

  context "routing the notification to the handler" do

    it "sends the notifications hash to Services class" do
      router = ScriptNotifier::Router.new(sample_error_message)
      ScriptNotifier::Router.should_receive(:new).once.and_return(router)
      router.should_receive(:deliver!).once.and_return(sample_result)

      subject.send(:route, sample_error_message).should == sample_result
    end

  end

  context "sending the result message" do
    it "returns a hash of the JSON message" do
      subject.should_receive(:send_message_to_queue).once.with(sample_result.to_json)
      subject.send(:send_result, sample_result)
    end
  end

end
