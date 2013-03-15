# encoding:utf-8
$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "script_notifier/version"

Gem::Specification.new do |s|
  s.name        = "script_notifier"
  s.version     = ScriptNotifier::VERSION
  s.authors     = ["Mikel Lindsaar"]
  s.email       = ["mikel@reinteractive.net"]
  s.homepage    = "http://github.com/reInteractive/ScriptNotifier"
  s.license     = 'Copyright reInteractive (RubyX P/L ATF RubyX Trust)'
  s.summary     = "ScriptNotifier is used by StillAlive to process and send all external notifications"
  s.description = "ScriptNotifier listens to a queue waiting for notification messages to be sent to it " +
                  "from the Script Sink.  It depends on the still_alive_services gem to send messages."

  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.md"]
  s.files = %w(README.md Rakefile Gemfile LICENSE bin/script_notifier) +
            Dir.glob("lib/**/*")

  s.executables << 'script_notifier'

  s.add_dependency('ffi-rzmq', "~> 0.9.6")
  s.add_dependency('json', "~> 1.5.4")
  s.add_dependency('activesupport', "~> 3.2.12")

  s.add_development_dependency("rspec", "~> 2.8.0")
  s.add_development_dependency("rake", "~> 0.9.2")
  s.add_development_dependency("bundler", "~> 1.0")
  s.add_development_dependency("timecop")

  s.require_path = 'lib'
end
