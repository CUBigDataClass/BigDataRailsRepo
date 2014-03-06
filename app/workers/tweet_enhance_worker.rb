class TweetEnhanceWorker
  include Sidekiq::Worker
  CHUNK = 1000

  # tweet_arr should be an array of hashes
  # representing tweets
  def perform(tweet_arr)
    enhanced_tweets = enhance_tweets tweet_arr
    push_on_enhanced_queue enhanced_tweets
  end

  private

  def redis
    @_redis ||= Redis.new host: $redis_config[:host], port: $redis_config[:port], thread_safe: true
  end

  def push_on_enhanced_queue(tweets); tweets.each{ |t| redis.lpush($redis_keys[:enhanced_tweets], t.to_json) }; end

  def enhance_tweets(tweet_arr); tweet_arr.map{ |t| enhance_tweet(t) }.select{ |a| a } ; end

  # Transforms a hash of a tweet object into a hash with additional information. Returns nil if
  # the tweet cannot be enhanced
  def enhance_tweet(tweet)
    # Not implemented
    #puts tweet.to_s
    return nil if tweet['text'].nil?
    return nil if !is_english?(tweet)

    tweet
  end

  def is_english?(tweet)
    tweet['lang'] == 'en'
  end
end
