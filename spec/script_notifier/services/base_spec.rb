require 'spec_helper'

module ScriptNotifier
  module Services
    class TestService

      include Services::Base
    end
  end
end

describe ScriptNotifier::Services::Base do

  def failure_script_data(attrs = {})
    sample_failure_script_data.merge!(attrs)
  end

  def success_script_data(attrs = {})
    sample_success_script_data.merge!(attrs)
  end

  def notification(attrs = {})
    sample_notifications.first.merge!(attrs)
  end

  subject { ScriptNotifier::Services::TestService.new(failure_script_data, notification) }

  it "accepts script data and notificaiton hashen" do
    expect { subject }.to_not raise_error(ArgumentError)
  end

  describe "base service" do

    it "sets the payload as an attr_reader" do
      subject.payload.should eq(notification['payload'])
    end

    it "sets the notification as an attr_reader" do
      subject.notification.should eq(notification)
    end

    it "sets the failure_message and failure_step as attr_readers" do
      subject.failure_message.should eq('Could not find ABC on the page')
      subject.failure_step_id.should eq(122)
      subject.failure_attempts.should eq(3)
      subject.success.should be_false
    end

    it "sets success to true if there is no failure message" do
      subject = ScriptNotifier::Services::TestService.new(success_script_data, notification)
      subject.success.should be_true
    end

    it "sets the script name and id and site name as attr_readers" do
      subject.script_id.should eq(1)
      subject.script_name.should eq('My Script')
      subject.site_name.should eq('My Site')
    end

    it "sets the script steps as an attr_reader" do
      subject.script_steps.should == [
        [121, 'When I go to http =>//www.example.com/'],
        [124, 'And I click "Login"'],
        [122, 'Then I should see "Email"']
      ]
    end


  end

end