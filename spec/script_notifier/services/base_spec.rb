require 'spec_helper'

describe ScriptNotifier::Services::Base do

  def script_data(attrs = {})
    {
      'script_id' => 1,
      'site_name' => 'My Site',
      'script_name' => 'My Script',
      'failure_message' => 'Could not find ABC on the page',
      'failure_step' => 122,
      'failure_attempts' => 4,
      'script' => [
        [121, 'When I go to http =>//www.example.com/'],
        [124, 'And I click "Login"'],
        [122, 'Then I should see "Email"']
      ]
    }.merge!(attrs)
  end

  def notification(attrs = {})
    {
      'type' => 'sms',
      'address' => '+61432124194',
      'user_id' => 111
    }.merge!(attrs)
  end

  subject { ScriptNotifier::Services::Base.new(script_data, notification) }

  it "accepts script data and notificaiton hashen" do
    expect { subject }.to_not raise_error(ArgumentError)
  end

  describe "base service" do

    it "sets the address as an attr_reader" do
      subject.address.should eq('+61432124194')
    end

    it "sets the failure_message and failure_step as attr_readers" do
      subject.failure_message.should eq('Could not find ABC on the page')
      subject.failure_step.should eq(122)
      subject.failure_attempts.should eq(4)
      subject.success.should be_false
    end

    it "sets success to true if there is no failure message" do
      subject = ScriptNotifier::Services::Base.new(script_data({'failure_message' => nil}), notification)
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