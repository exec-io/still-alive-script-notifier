module SampleMessages
  def sample_error_message(params = {})
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
          'user_id' => 111
        },
        {
          'type' => 'sms',
          'address' => '+61432124200',
          'user_id' => 222
        },
        {
          'type' => 'email',
          'address' => 'mikel@example.com',
          'user_id' => 111
        },
        {
          'type' => 'email',
          'address' => 'bob@example.org',
          'user_id' => 222
        }
      ]
    }.merge!(params)
  end

  def sample_success_message(params = {})
    {
      'script_id' => 1,
      'site_name' => 'My Site',
      'script_name' => 'My Script',
      'script' => [
        [121, 'When I go to http =>//www.example.com/'],
        [124, 'And I click "Login"'],
        [122, 'Then I should see "Email"']
      ],
      'notifications' => [
        {
          'type' => 'sms',
          'address' => '+61432124194',
          'user_id' => 111
        },
        {
          'type' => 'sms',
          'address' => '+61432124200',
          'user_id' => 222
        },
        {
          'type' => 'email',
          'address' => 'mikel@example.com',
          'user_id' => 111
        },
        {
          'type' => 'email',
          'address' => 'bob@example.org',
          'user_id' => 222
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
      'failure_step' => 3,
      'notifications' => [
        {
          'type' => 'sms',
          'address' => '+61432124194',
          'success' => true,
          'sent_at' => Time.now.utc.iso8601
        },
        {
          'type' => 'email',
          'address' => 'mikel@example.com',
          'success' => true,
          'sent_at' => Time.now.utc.iso8601
        }
      ]
    }.merge!(params)
  end
end