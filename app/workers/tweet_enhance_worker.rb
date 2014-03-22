class TweetEnhanceWorker
  include Sidekiq::Worker
  CHUNK = 1000
  LAT = 'lat'
  LON = 'lon'
  GEO = 'geo'
  COORDINATES = 'coordinates'

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

  def push_on_enhanced_queue(tweets); tweets.each{ |t| redis.hset($redis_keys[:enhanced_tweets], Time.now.to_f, t.to_json) }; end

  def enhance_tweets(tweet_arr); tweet_arr.map{ |t| enhance_tweet(t) }.select{ |a| a } ; end

  # Transforms a hash of a tweet object into a hash with additional information. Returns nil if
  # the tweet cannot be enhanced
  def enhance_tweet(tweet)
    # Not implemented
    #puts tweet.to_s
    return nil if tweet['text'].nil?
    return nil if !is_english?(tweet)

    if has_lat_long?(tweet)
      tweet[LAT], tweet[LON] = tweet[GEO][COORDINATES]
    else
      ( found_lat_lon = lookup_lat_long(tweet) ) ? (tweet[LAT], tweet[LON] = found_lat_lon) : (return nil)
    end

    tweet
  end

  def is_english?(tweet)
    tweet['lang'] == 'en'
  end

  def has_lat_long?(tweet)
    begin
      coordinates = tweet[GEO][COORDINATES]
      coordinates.is_a?(Array) && coordinates.size == 2
    rescue
      nil
    end
  end

  def lookup_lat_long(tweet)
    user = tweet['user']

    if (location = user['location'])
      results = MapQuestSearch.raw location

      return nil if results.nil?

      city=nil
      prefered_map_quest_search_types.each do |type|
        city = results.detect{ |result| result['type'] == type }
        break if city
      end
      city ? [city[LAT], city[LON]] : nil
    else
      nil
    end
  end

  def prefered_map_quest_search_types
    @_prefered_types ||= %w(
      city
      hamlet
      country
    )
  end
end
