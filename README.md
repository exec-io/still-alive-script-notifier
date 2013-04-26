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

ScriptSink dumps notification messages to the ScriptNotifier queue as the following JSON hash for a failure:

    {
      'script_id': 1,
      'site_name': 'My Site',
      'script_name': 'My Script',
      'failure_message': 'Could not find ABC on the page',
      'failure_step_id': 122,
      'failure_attempts': 3,
      'script': [
        [121, 'When I go to http://www.example.com/'],
        [124, 'And I click "Login"'],
        [122, 'Then I should see "Email"']
      ],
      'notifications': [
        {
          'type': 'sms',
          'address': '+61432124194',
          'user_id': 111
        },
        {
          'type': 'sms',
          'address': '+61432124200'
          'user_id': 222
        },
        {
          'type': 'email',
          'address': 'mikel@example.com'
          'user_id': 111
        },
        {
          'type': 'email',
          'address': 'bob@example.org'
          'user_id': 222
        },
      ]
    }

If the message is a success it reads:

    {
      'script_id': 1,
      'site_name': 'My Site',
      'script_name': 'My Script',
      'script': [
        [121, 'When I go to http://www.example.com/'],
        [124, 'And I click "Login"'],
        [122, 'Then I should see "Email"']
      ],
      'notifications': [
        {
          'type': 'sms',
          'address': '+61432124194',
          'user_id': 111
        },
        {
          'type': 'sms',
          'address': '+61432124200'
          'user_id': 222
        },
        {
          'type': 'email',
          'address': 'mikel@example.com'
          'user_id': 111
        },
        {
          'type': 'email',
          'address': 'bob@example.org'
          'user_id': 222
        },
      ]
    }

Once the ScriptNotifier gets a notification, it sends out the notifications required.  Once done it
sends back to ScriptSink the following JSON message:

    {
      'script_id': 1,
      'site_name': 'My Site',
      'script_name': 'My Script',
      'failure_message': 'Could not find ABC on the page',
      'failure_step': 3,
      'notifications': [
        {
          'type': 'sms',
          'address': '+61432124194',
          'user_id': 111,
          'success': true,
          'sent_at': '2013-04-25T02:43:42Z',
        },
        {
          'type': 'sms',
          'address': '+61432124200'
          'user_id': 222,
          'success': false,
          'sent_at': '2013-04-25T02:43:42Z',
          'error': { 'message': 'ERROR: we could not deliver to +61432124200, please check the number and update your settings.',
                     'type': 'InvalidRecipient'
                   }
        },
        {
          'type': 'email',
          'address', 'mikel@example.com'
          'user_id': 111,
          'success': true,
          'sent_at': '2013-04-25T02:43:42Z'
        },
        {
          'type': 'email',
          'address', 'bob@example.org'
          'user_id': 222,
          'success': false,
          'sent_at': '2013-04-25T02:43:42Z',
          'error': { 'message': 'ERROR: we could not deliver to bob@example.org, please check the number and update your settings.',
                     'type': 'InvalidRecipient'
                   }
        },
      ]
    }

Which then get written to the database by ScriptSink into the Notifcations table.  Time stamps are in iso8601 format (`Time.now.utc.iso8601`)


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
