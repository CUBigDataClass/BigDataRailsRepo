namespace :twitter do

  # Helpers

  def test_keys
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = $twitter_keys["api_key"]
      config.consumer_secret     = $twitter_keys["api_secret"]
      config.access_token        = $twitter_keys["access_token"]
      config.access_token_secret = $twitter_keys["access_token_secret"]
    end
    !client.search("node").collect(&:text).empty?
  end

  #---------

  task :stream => :environment do
    raise 'Invalid twitter keys' unless test_keys

    TweetStream.configure do |config|
      config.consumer_key       = $twitter_keys[:api_key]
      config.consumer_secret    = $twitter_keys[:api_secret]
      config.oauth_token        = $twitter_keys[:access_token]
      config.oauth_token_secret = $twitter_keys[:access_token_secret]
      config.auth_method        = :oauth

      #config.username = ''
      #config.password = ''
      #config.auth_method = :basic
    end

    # This will pull a sample of all tweets based on
    # your Twitter account's Streaming API role.
    client = TweetStream::Client.new


    client.on_error{ |msg| puts msg }

    client.sample do |status|
      # The status object is a special Hash with
      # method access to its keys.
      puts "#{status.text}"
    end

    #TweetStream::Client.new.sample do |status|
    #  puts status.text
    #  $redis.sadd($redis_keys[:raw_tweets], status)
    #end

  end
end
