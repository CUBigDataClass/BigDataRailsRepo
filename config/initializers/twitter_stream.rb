require_relative '../initializers/twitter_keys'

TweetStream.configure do |config|
  config.consumer_key       = $twitter_keys['api_key']
  config.consumer_secret    = $twitter_keys['api_secret']
  config.oauth_token        = $twitter_keys['access_token']
  config.oauth_token_secret = $twitter_keys['access_token_secret']
  config.auth_method        = :oauth
end