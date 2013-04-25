# encoding: utf-8

ENV['debug'] = 'test' unless ENV['debug']
ENV['SCRIPT_NOTIFIER_ENV'] = 'test'

unless defined?(SPEC_ROOT)
  SPEC_ROOT = File.join(File.dirname(__FILE__))
end

# Load in our code
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'timecop'
require 'webmock/rspec'
require 'script_notifier'
require File.join(SPEC_ROOT, 'support/sample_messages')

RSpec.configure do |config|
  config.include SampleMessages
end
