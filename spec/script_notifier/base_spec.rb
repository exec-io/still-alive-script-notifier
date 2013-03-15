# encoding: utf-8
require 'spec_helper'

class StillAliveService
end

def sample_message(params = {})
  {}.merge!(params).to_json
end

describe ScriptNotifier::Base do

  before(:each) do
    StillAliveService.any_instance.stub(:process)
  end

  it "has a run! method" do
    ScriptNotifier::Base.should respond_to(:run!)
  end

  it "gives the message decoded from JSON to the StillAliveService gem" do
    message = {"message" => 'hello'}
    ScriptNotifier::Base.stub!(:get_next_notification_message).and_return(message.to_json)
    service = StillAliveService.new
    StillAliveService.stub!(:new).and_return(service)
    service.should_receive(:process).once.with(message)

    ScriptNotifier::Base.setup_queues
    ScriptNotifier::Base.process!
  end

end
