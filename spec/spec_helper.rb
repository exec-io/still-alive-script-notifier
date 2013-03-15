# encoding: utf-8

ENV['debug'] = 'test' unless ENV['debug']
ENV['SCRIPT_SINK_ENV'] = 'test'

unless defined?(SPEC_ROOT)
  SPEC_ROOT = File.join(File.dirname(__FILE__))
end

# Load in our code
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'script_notifier'

RSpec.configure do |config|

end
