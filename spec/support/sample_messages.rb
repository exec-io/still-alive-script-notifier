module SampleMessages
  def sample_message(params = {})
    {
      'script_id' => 1,
      'site_name' => 'My Site',
      'script_name' => 'My Script',
      'failure_message' => 'Could not find ABC on the page',
      'failure_step' => 3,
      'notifications' => [
        {
          'type' => 'sms',
          'address' => '+61432124194'
        },
        {
          'type' => 'email',
          'address' => 'mikel@example.com'
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