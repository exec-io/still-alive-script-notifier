# encoding: utf-8

ENV['SCRIPT_NOTIFIER_ENV'] = 'development' unless ENV['SCRIPT_NOTIFIER_ENV']

module ScriptNotifier
  require 'rubygems'

  require 'ffi-rzmq'
  require 'json'
  require "net/http"
  require "uri"
  require 'active_support/core_ext/class/attribute_accessors'

  require 'script_notifier/version'
  require 'script_notifier/base'
  require 'script_notifier/processor'
  require 'script_notifier/router'
  require 'script_notifier/providers/message_media'
  require 'script_notifier/services/base'
  require 'script_notifier/services/sms'
  require 'script_notifier/services/email'
  require 'script_notifier/services/twitter'
  require 'script_notifier/services/campfire'

  def self.test_run_mode
    if ENV['SCRIPT_NOTIFIER_ENV'].to_s === 'test'
      false
    else
      true
    end
  end

  def self.log(message)
    unless ENV['SCRIPT_NOTIFIER_ENV'].to_s === 'test'
      STDOUT.puts message
      STDOUT.flush
    end
  end

  def self.rescue_action_and_report(exception, message)
    if ENV['SCRIPT_NOTIFIER_ENV'].to_s === 'test'
      raise exception
    else
      Airbrake.notify(exception, :parameters => message)
    end
  end
end
