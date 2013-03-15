ScriptNotifier README
=========================

This makes a team of four applications:

* [ScriptPublisher](https://github.com/reInteractive/ScriptPublisher)
* [ScriptRunner](https://github.com/reInteractive/ScriptRunner)
* [ScriptSink](https://github.com/reInteractive/ScriptSink)
* [ScriptNotifier](https://github.com/reInteractive/ScriptNotifier)

Decription
--------------------------

Usage
--------------------------

Install ScriptNotifier as follows:

    $ gem install script_notifier-0.0.1.gem

To run:

    $ export SCRIPT_SINK_ENV=production
    $ bundle exec bin/script_notifier notification_queue_uri

The URI is required, for example:

    $ export SCRIPT_SINK_ENV=production
    $ script_notifier tcp://localhost:6010


Operation
--------------------------

ScriptNotifier is the way that StillAlive as a system sends out alerts to users

ScriptSink dumps notification messages to the ScriptNotifier queue as the following JSON hash:

    {
    }

Once the ScriptNotifier gets a notification, it simply sends it to StillAiveService gem for
processing and sending outwards.

It then pulls the next notification from the queue.


Development
-------------------------

Checkout the code:

    $ git clone git@github.com:reInteractive/ScriptNotifier.git

Run the specs:

    $ rake

Gem Building
--------------------------

Update +lib/script_notifier/version.rb+ to the new version of the gem.

Build the gem:

    $ rake build

Test install the gem:

    $ gem install script_notifier-0.0.1.gem
