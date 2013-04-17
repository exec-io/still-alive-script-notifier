# encoding: utf-8

ENV['SCRIPT_NOTIFIER_ENV'] = 'development' unless ENV['SCRIPT_NOTIFIER_ENV']

module ScriptNotifier
  require 'rubygems'

  require 'ffi-rzmq'
  require 'json'

  require 'script_notifier/version'
  require 'script_notifier/base'
  require 'script_notifier/services/base'
  require 'script_notifier/services/sms'
  require 'script_notifier/services/email'
  require 'script_notifier/services/twitter'

  def self.log(message)
    STDOUT.puts message
    STDOUT.flush
  end
end
