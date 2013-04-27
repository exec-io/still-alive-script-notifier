# encoding: utf-8

require 'airbrake'
module ScriptNotifier

  class Base
    cattr_reader :notice_queue_uri, :result_queue_uri,
                 :message_media_user_id, :message_media_password,
                 :twitter_consumer_key, :twitter_consumer_secret, :twitter_oauth_token, :twitter_oauth_token_secret, 
                 :smtp_settings, :email_from_domain

    # Gather Config
    def self.setup_config(config_yml = nil)
      Airbrake.configure do |config|
        config.api_key = 'e94d7e79bbb79e17aab77c66890191c1'
        config.host = 'api.airbrake.io'
      end

      config_yml ||= File.join(File.expand_path('../', __FILE__), '../../config/', 'config.yml')
      config = YAML::load(File.read(config_yml))

      @@notice_queue_uri       = config['notice_queue_uri'] || 'tcp://127.0.0.1:5558'
      @@result_queue_uri       = config['result_queue_uri'] || 'tcp://127.0.0.1:5559'

      @@message_media_user_id  = config['message_media_username']
      @@message_media_password = config['message_media_password']

      @@twitter_consumer_key           = config['twitter_consumer_key']
      @@twitter_consumer_secret        = config['twitter_consumer_secret']
      @@twitter_oauth_token            = config['twitter_oauth_token']
      @@twitter_oauth_token_secret     = config['twitter_oauth_token_secret']

      @@email_settings         = config['email_settings']
      @@email_from_domain      = config['email_from_domain']
    end
  end
end