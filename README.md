ScriptNotifier README
=========================

This makes a team of four applications:

* [ScriptPublisher](https://github.com/reInteractive/ScriptPublisher)
* [ScriptRunner](https://github.com/reInteractive/ScriptRunner)
* [ScriptSink](https://github.com/reInteractive/ScriptSink)
* [ScriptNotifier](https://github.com/reInteractive/ScriptNotifier)

Decription
--------------------------

ScriptNotifier is what we use to send notifications out to our users.  This cuts down on
database polling a great deal.

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
          'service': 'sms',
          'payload': {
            'address': '+61432124194'
          }
        },
        {
          'service': 'email',
          'payload': {
            'address': 'mikel@example.com'
          }
        },
        {
          'service': 'twitter',
          'payload': {
            'address': '@example'
          }
        },
        {
          'service': 'campfire',
          'payload': {
            'api_token': 'CAMPFIRETOKEN',
            'room': 'stillalive',
            'subdomain': 'execio',
            'play_sound': true
          }
        }
      ]
    }
If the message is a success it reads:

    {
      'script_id': 1,
      'site_name': 'My Site',
      'script_name': 'My Script',
      'failure_attempts': 3,
      'script': [
        [121, 'When I go to http://www.example.com/'],
        [124, 'And I click "Login"'],
        [122, 'Then I should see "Email"']
      ],
      'notifications': [
        {
          'service': 'sms',
          'payload': {
            'address': '+61432124194'
          }
        },
        {
          'service': 'email',
          'payload': {
            'address': 'mikel@example.com'
          }
        },
        {
          'service': 'twitter',
          'payload': {
            'address': '@example'
          }
        },
        {
          'service': 'campfire',
          'payload': {
            'api_token': 'CAMPFIRETOKEN',
            'room': 'stillalive',
            'subdomain': 'execio',
            'play_sound': true
          }
        }
      ]
    }

Once the ScriptNotifier gets a notification, it sends out the notifications required.
Once done it is done, it logs the results of the notifications directly into the
database.


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
