module SampleMessages

  def sample_notifications
    sample_failure_message['notifications']
  end

  def sample_failure_script_data
    sample_failure_message.reject { |k,v| k == 'notifications' }
  end

  def sample_success_script_data
    sample_success_message.reject { |k,v| k == 'notifications' }
  end

  def sample_failure_message(params = {})
    {
      'script_id' => 1,
      'site_name' => 'My Site',
      'script_name' => 'My Script',
      'failure_message' => 'Could not find ABC on the page',
      'failure_step_id' => 122,
      'failure_attempts' => 3,
      'script' => [
        [121, 'When I go to http =>//www.example.com/'],
        [124, 'And I click "Login"'],
        [122, 'Then I should see "Email"']
      ],
      'notifications' => [
        {
          'type' => 'sms',
          'address' => '+61432124194'
        },
        {
          'type' => 'sms',
          'address' => '+61432124200'
        },
        {
          'type' => 'email',
          'address' => 'mikel@example.com'
        },
        {
          'type' => 'email',
          'address' => 'bob@example.org'
        }
      ]
    }.merge!(params)
  end

  def sample_success_message(params = {})
    {
      'script_id' => 1,
      'site_name' => 'My Site',
      'script_name' => 'My Script',
      'failure_attempts' => 3,
      'script' => [
        [121, 'When I go to http =>//www.example.com/'],
        [124, 'And I click "Login"'],
        [122, 'Then I should see "Email"']
      ],
      'notifications' => [
        {
          'type' => 'sms',
          'address' => '+61432124194'
        },
        {
          'type' => 'sms',
          'address' => '+61432124200'
        },
        {
          'type' => 'email',
          'address' => 'mikel@example.com'
        },
        {
          'type' => 'email',
          'address' => 'bob@example.org'
        }
      ]
    }.merge!(params)
  end

  def sample_result(params = {})
    {
      'script_id' => 1,
      'site_name' => 'My Site',
      'script_name' => 'My Script',
      'failure_message' => 'Could not find ABC on the page',
      'failure_step_id' => 122,
      'failure_attempts' => 3,
      'script' => [
        [121, 'When I go to http =>//www.example.com/'],
        [124, 'And I click "Login"'],
        [122, 'Then I should see "Email"']
      ],
      'notifications' => [
        {
          'type' => 'sms',
          'address' => '+61432124194',
          'success' => true,
          'sent_at' => Time.now.utc.iso8601
        },
        {
          'type' => 'sms',
          'address' => '+61432124200',
          'success' => true,
          'sent_at' => Time.now.utc.iso8601
        },
        {
          'type' => 'email',
          'address' => 'mikel@example.com',
          'success' => true,
          'sent_at' => Time.now.utc.iso8601
        },
        {
          'type' => 'email',
          'address' => 'bob@example.org',
          'success' => true,
          'sent_at' => Time.now.utc.iso8601
        }
      ]
    }.merge!(params)
  end
end