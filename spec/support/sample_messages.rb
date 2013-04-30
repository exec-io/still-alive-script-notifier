module SampleMessages

  def sample_notifications
    sample_failure_message[:notifications]
  end

  def sample_failure_script_data
    sample_failure_message.reject { |k,v| k == :notifications }
  end

  def sample_success_script_data
    sample_success_message.reject { |k,v| k == :notifications }
  end

  def sample_failure_message(params = {})
    {
      :script_id => 1,
      :site_name => 'My Site',
      :script_name => 'My Script',
      :failure_message => 'Could not find ABC on the page',
      :failure_step_id => 122,
      :failure_attempts => 3,
      :script => [
        [121, 'When I go to http =>//www.example.com/'],
        [124, 'And I click "Login"'],
        [122, 'Then I should see "Email"']
      ],
      :notifications => [
        {
          :service    => 'sms',
          :payload    => {
            :address    => '+61432124194'
          }
        },
        {
          :service    => 'email',
          :payload    => {
            :address    => 'mikel@example.com'
          }
        },
        {
          :service    => 'twitter',
          :payload    => {
            :address    => '@example'
          }
        },
        {
          :service    => 'campfire',
          :payload    => {
            :api_token  => 'CAMPFIRETOKEN',
            :room_name  => 'stillalive',
            :subdomain  => 'execio',
            :play_sound => true
          }
        },
        {
          :service => 'flowdock',
          :payload => {
            :api_token  => 'FLOWDOCKTOKEN',
            :tags       => ['stillalive', 'alert']
          }
        },
        {
          :service => 'hip_chat',
          :payload => {
            :api_token  => 'HIPCHATTOKEN',
            :room_name  => 'stillalive',
            :notify     => true
          }
        }
      ]
    }.merge!(params)
  end

  def sample_success_message(params = {})
    {
      :script_id => 1,
      :site_name => 'My Site',
      :script_name => 'My Script',
      :failure_attempts => 3,
      :script => [
        [121, 'When I go to http =>//www.example.com/'],
        [124, 'And I click "Login"'],
        [122, 'Then I should see "Email"']
      ],
      :notifications => [
        {
          :service => 'sms',
          :payload => {
            :address => '+61432124194'
          }
        },
        {
          :service => 'email',
          :payload => {
            :address => 'mikel@example.com'
          }
        },
        {
          :service => 'twitter',
          :payload => {
            :address => '@example'
          }
        },
        {
          :service => 'campfire',
          :payload => {
            :room_name  => 'stillalive',
            :api_token  => 'CAMPFIRETOKEN',
            :subdomain  => 'execio',
            :play_sound => true
          }
        },
        {
          :service => 'flowdock',
          :payload => {
            :api_token  => 'FLOWDOCKTOKEN',
            :tags       => ['stillalive', 'alert']
          }
        },
        {
          :service => 'hip_chat',
          :payload => {
            :api_token  => 'HIPCHATTOKEN',
            :room_name  => 'stillalive',
            :notify     => true
          }
        }
      ]
    }.merge!(params)
  end

  def sample_result(params = {})
    {
      :script_id => 1,
      :site_name => 'My Site',
      :script_name => 'My Script',
      :failure_message => 'Could not find ABC on the page',
      :failure_step_id => 122,
      :failure_attempts => 3,
      :script => [
        [121, 'When I go to http =>//www.example.com/'],
        [124, 'And I click "Login"'],
        [122, 'Then I should see "Email"']
      ],
      :notifications => [
        {
          :service => 'sms',
          :success => true,
          :sent_at => Time.now.utc.iso8601,
          :payload => {
            :address => '+61432124194'
          }
        },
        {
          :service => 'email',
          :success => true,
          :sent_at => Time.now.utc.iso8601,
          :payload => {
            :address => 'mikel@example.com'
          }
        },
        {
          :service => 'twitter',
          :success => true,
          :sent_at => Time.now.utc.iso8601,
          :payload => {
            :address => '@example'
          }
        },
        {
          :service => 'campfire',
          :success => true,
          :sent_at => Time.now.utc.iso8601,
          :payload => {
            :api_token  => 'CAMPFIRETOKEN',
            :room_name  => 'stillalive',
            :subdomain  => 'execio',
            :play_sound => true
          }
        },
        {
          :service => 'flowdock',
          :success => true,
          :sent_at => Time.now.utc.iso8601,
          :payload => {
            :api_token  => 'FLOWDOCKTOKEN',
            :tags       => ['stillalive', 'alert']
          }
        },
        {
          :service => 'hip_chat',
          :success => true,
          :sent_at => Time.now.utc.iso8601,
          :payload => {
            :api_token  => 'HIPCHATTOKEN',
            :room_name  => 'stillalive',
            :notify     => true
          }
        }
      ]
    }.merge!(params)
  end
end