class TweetEnhanceWorker
  include Sidekiq::Worker
  CHUNK = 1000

  def perform
    tweets = pop_tweets
    enhanced_tweets = enhance_tweet tweets
    push_on_enhanced_queue enhanced_tweets
  end

  private

  def push_on_enhanced_queue(tweets); tweets.each{ |t| $redis.lpush($redis_keys[:enhanced_tweets], t) }; end

  def pop_tweets
    ret_val=[]
    CHUNK.times{ ret_val << $redis.brpop }
  end

  def enhance_tweets(tweet_arr)
    ret_val=[]
    tweet_arr.each{ |t| ret_val << enhance_tweet(t) }
    ret_val
  end

  # Transforms a Twitter::Tweet object into a hash with additional information
  def enhance_tweet(tweet)
    tweet.to_hash
  end
end