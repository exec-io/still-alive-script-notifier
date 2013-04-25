module ScriptNotifier
  module Providers
    module MessageMedia
      require 'handsoap'

      class InvalidMessageIdError < StandardError; end
      class InvalidRecipientError < StandardError; end
      class EmptyMessageContentError < StandardError; end
      class EmptyScriptNameError < StandardError; end
      class RecipientBlockedError < StandardError; end

      class Provider < ::Handsoap::Service

        endpoint({ :uri => 'http://soap.m4u.com.au/', :version => 1 })

        def get_credit_remaining
          response = check_user!
          check_credit_remaining(response)
        end

        def send_alert_voice_message!(message_id, recipient, script)
          raise InvalidMessageIdError, "Please specifify a message_id"           unless message_id.present?
          raise InvalidRecipientError, "You must provide a recipient to send to" unless recipient.present?
          raise EmptyScriptNameError,  "The script name can not be blank"        unless script.present?

          response = send_voice_alert!(message_id, recipient, script)
          check_send_message_status(response)
          {
            :success          => check_success(response),
            :message_id       => message_id,
            :credit_remaining => check_credit_remaining(response),
          }
        end

        def send_alert_text_message!(message_id, recipient, message)
          raise InvalidMessageIdError,    "Please specifify a message_id"           unless message_id.present?
          raise InvalidRecipientError,    "You must provide a recipient to send to" unless recipient.present?
          raise EmptyMessageContentError, "The message can not be blank"            unless message.present?

          response = send_sms_alert!(message_id, recipient, message)
          check_send_message_status(response)
          {
            :success          => check_success(response),
            :message_id       => message_id,
            :credit_remaining => check_credit_remaining(response),
          }
        end

      private

        def on_create_document(doc)
          # register namespaces for the request
          doc.alias 'ns', 'http://xml.m4u.com.au/2009'
        end

        def on_response_document(doc)
          # register namespaces for the response
          doc.add_namespace 'ns', 'http://xml.m4u.com.au/2009'
        end

        def send_voice_alert!(message_id, mobile_number, script)
          soap_action = 'http://xml.m4u.com.au/2009/sendMessages'
          response = invoke('sendMessages', soap_action) do |doc|
            doc.set_attr 'xmlns', 'http://xml.m4u.com.au/2009'
            add_authentication(doc)
            doc.add "requestBody" do |body|
              body.add "messages" do |messages|
                messages.add "message" do |message|
                  message.set_attr 'format', 'voice'
                  message.set_attr 'sequenceNumber', '1'
                  message.add "recipients" do |recipients|
                    recipients.add "recipient", mobile_number do |recipient|
                      recipient.set_attr 'uid', message_id
                    end
                  end
                  message.add "content", "Hello, this is an alert from the Still Alive application monitoring service.  Your script #{script} has failed, please log into your Still Alive dashboard to resolve this issue."
                end
              end
            end
          end
        end

        def send_sms_alert!(message_id, mobile_number, message_text)
          soap_action = 'http://xml.m4u.com.au/2009/sendMessages'
          response = invoke('sendMessages', soap_action) do |doc|
            doc.set_attr 'xmlns', 'http://xml.m4u.com.au/2009'
            add_authentication(doc)
            doc.add "requestBody" do |body|
              body.add "messages" do |messages|
                messages.add "message" do |message|
                  message.set_attr 'format', 'SMS'
                  message.set_attr 'sequenceNumber', '1'
                  message.add "recipients" do |recipients|
                    recipients.add "recipient", mobile_number do |recipient|
                      recipient.set_attr 'uid', message_id
                    end
                  end
                  message.add "content", message_text
                end
              end
            end
          end
        end

        def check_send_message_status(response)
          error = response.xpath("//ns:error").first
          if error.present?
            case error['code']
            when 'invalidRecipient'
              raise MessageMedia::InvalidRecipientError
            when 'emptyMessageContent'
              raise MessageMedia::EmptyMessageContentError
            when 'recipientBlocked'
              raise MessageMedia::RecipientBlockedError
            else
              raise StandardError, "Unknown error has occurred - #{response.xpath("//ns:content").to_s}"
            end
          end
        end

        def check_user!
          soap_action = 'http://xml.m4u.com.au/2009/checkUser'
          response = invoke('checkUser', soap_action) do |message|
            message.set_attr 'xmlns', 'http://xml.m4u.com.au/2009'
            add_authentication(message)
          end
        end

        def check_replies!
          soap_action = 'http://xml.m4u.com.au/2009/checkReplies'
          response = invoke('tns:checkReplies', soap_action) do |message|
            raise "TODO"
          end
        end

        def check_reports!
          soap_action = 'http://xml.m4u.com.au/2009/checkReports'
          response = invoke('tns:checkReports', soap_action) do |message|
            raise "TODO"
          end
        end

        def confirm_replies!
          soap_action = 'http://xml.m4u.com.au/2009/confirmReplies'
          response = invoke('tns:confirmReplies', soap_action) do |message|
            raise "TODO"
          end
        end

        def confirm_reports!
          soap_action = 'http://xml.m4u.com.au/2009/confirmReports'
          response = invoke('tns:confirmReports', soap_action) do |message|
            raise "TODO"
          end
        end

        def add_authentication(builder)
          builder.add "authentication" do |a|
            a.add "userId", ScriptNotifier::Base.message_media_user_id
            a.add "password", ScriptNotifier::Base.message_media_password
          end
        end

        def check_credit_remaining(response)
          response.document.xpath("//ns:accountDetails").first['creditRemaining'].to_i
        end

        def check_success(response)
          response.document.xpath("//ns:result").first['failed'].to_i == 0
        end

      end

    end
  end
end