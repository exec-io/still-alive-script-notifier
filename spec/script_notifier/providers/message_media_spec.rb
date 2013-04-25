require 'spec_helper'

describe ScriptNotifier::Providers::MessageMedia::Provider do

  def stub_response(filename)
    body = File.read(File.join(SPEC_ROOT, 'support', 'soap_responses', filename))
    stub_request(:post, "http://soap.m4u.com.au/").to_return(:body => body)
  end

  let(:klass)  { ScriptNotifier::Providers::MessageMedia::Provider }

  describe "sending an alert" do

    it "sends a text message" do
      stub_response('send_message_success.xml')
      klass.send_alert_text_message!(1, '0432124194', 'This is a message').should_not be_nil
    end

    it "sends a text message" do
      stub_response('send_message_success.xml')
      klass.send_alert_voice_message!(1, '0432124194', 'First Script').should_not be_nil
    end

    it "returns a hash of account information" do
      stub_response('send_message_success.xml')
      result = klass.send_alert_text_message!('1', '0432124194', 'This is a message')
      result.should == {:success => true, :message_id => '1', :credit_remaining => 10}
    end

    it "returns a hash of account information" do
      stub_response('send_message_success.xml')
      result = klass.send_alert_voice_message!('1', '0432124194', 'First Script')
      result.should == {:success => true, :message_id => '1', :credit_remaining => 10}
    end

  end

  describe "exceptions" do

    context "sending a voice message" do

      it "raises InvalidMessageIdError if there is no message id" do
        expect { klass.send_alert_voice_message!(nil, '61432124194', 'My Script') }.should raise_error(ScriptNotifier::Providers::MessageMedia::InvalidMessageIdError)
      end

      it "raises InvalidRecipientError if there is no recipient" do
        expect { klass.send_alert_voice_message!(1, '', 'My Script') }.should raise_error(ScriptNotifier::Providers::MessageMedia::InvalidRecipientError)
      end

      it "raises InvalidRecipientError if MessageMedia complain the recipient is incorrect" do
        stub_response('send_message_invalid_recipient.xml')
        expect { klass.send_alert_voice_message!(1, '0432124194', 'My Script') }.should raise_error(ScriptNotifier::Providers::MessageMedia::InvalidRecipientError)
      end

      it "raises EmptyScriptNameError if there is no script name" do
        expect { klass.send_alert_voice_message!(1, '61432124914', '') }.should raise_error(ScriptNotifier::Providers::MessageMedia::EmptyScriptNameError)
      end

      it "raises RecipientBlockedError if MessageMedia complain the recipient is blocking us" do
        stub_response('send_message_recipient_blocked.xml')
        expect { klass.send_alert_voice_message!(1, '0432124194', 'My Script') }.should raise_error(ScriptNotifier::Providers::MessageMedia::RecipientBlockedError)
      end

    end

    context "sending a text message" do

      it "raises InvalidMessageIdError if there is no message id" do
        expect { klass.send_alert_text_message!(nil, '61432124194', 'This is a message') }.should raise_error(ScriptNotifier::Providers::MessageMedia::InvalidMessageIdError)
      end

      it "raises InvalidRecipientError if there is no recipient" do
        expect { klass.send_alert_text_message!(1, '', 'This is a message') }.should raise_error(ScriptNotifier::Providers::MessageMedia::InvalidRecipientError)
      end

      it "raises InvalidRecipientError if MessageMedia complain the recipient is incorrect" do
        stub_response('send_message_invalid_recipient.xml')
        expect { klass.send_alert_text_message!(1, '0432124194', 'This is a message') }.should raise_error(ScriptNotifier::Providers::MessageMedia::InvalidRecipientError)
      end

      it "raises EmptyMessageContentError if there is no script name" do
        expect { klass.send_alert_text_message!(1, '61432124914', '') }.should raise_error(ScriptNotifier::Providers::MessageMedia::EmptyMessageContentError)
      end

      it "raises RecipientBlockedError if MessageMedia complain the recipient is blocking us" do
        stub_response('send_message_recipient_blocked.xml')
        expect { klass.send_alert_text_message!(1, '0432124194', 'This is a message') }.should raise_error(ScriptNotifier::Providers::MessageMedia::RecipientBlockedError)
      end

    end

  end

end
