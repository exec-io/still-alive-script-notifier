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
    $ bundle exec bin/script_notifier notification_queue_uri /path/to/config.yml

The URI is required, for example:

    $ export SCRIPT_SINK_ENV=production
    $ script_notifier tcp://127.0.0.1:6010 /path/to/config.yml


Operation
--------------------------

ScriptNotifier is the way that StillAlive as a system sends out alerts to users

ScriptSink dumps notification messages to the ScriptNotifier queue as the following JSON hash:

    {
      'script_id': 1,
      'site_name': 'My Site',
      'script_name': 'My Script',
      'failure_message', 'Could not find ABC on the page',
      'failure_step', 3,
      'notifications': [
        {
          'type': 'sms',
          'address': '+61432124194'
        },
        {
          'type': 'sms',
          'address': '+61432124200'
        },
        {
          'type': 'email',
          'address': 'mikel@example.com'
        },
        {
          'type': 'email',
          'address': 'bob@example.org'
        },
      ]
    }

Once the ScriptNotifier gets a notification, it sends out the notifications required.  Once done it
sends back to ScriptSink the following JSON message:

    {
      'script_id': 1,
      'site_name': 'My Site',
      'script_name': 'My Script',
      'failure_message', 'Could not find ABC on the page',
      'failure_step', 3,
      'notifications': [
        {
          'type': 'sms',
          'address': '+61432124194',
          'success': true,
          'sent_at': Time.now.utc.iso8601
        },
        {
          'type': 'sms',
          'address': '+61432124200'
          'success': false,
          'sent_at': Time.now.utc.iso8601,
          'error': 'Some error message'
        },
        {
          'type': 'email',
          'address', 'mikel@example.com'
          'success': true,
          'sent_at': Time.now.utc.iso8601
        },
        {
          'type': 'email',
          'address', 'bob@example.org'
          'success': false,
          'sent_at': Time.now.utc.iso8601,
          'error': 'Some error message'
        },
      ]
    }

Which then get written to the database by ScriptSink into the Notifcations table.


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
