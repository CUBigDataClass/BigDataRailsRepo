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

    TweetStream::Client.new.sample do |status|
      puts status.text
      $redis.lpush($redis_keys[:raw_tweets], status.to_json)
    end

  end
end
