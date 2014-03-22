class TweetWatchWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  TWEETS_PER_ARCHIVE_WORKER = 500
  TWEETS_PER_ENHANCE_WORKER = 500
  HOURS_UNTIL_ARCHIVE = 2

  recurrence { minutely }

  Time.class_eval do
    def self.measure(&block)
      start = Time.now
      yield
      Time.now - start
    end
  end

  def perform
    tweet_arr=[]


    time = Time.measure do

      list_size = size_of_list($redis_keys[:raw_tweets]).to_f/2
      list_size = list_size.ceil
      while true
        val = redis.rpop($redis_keys[:raw_tweets])
        (tweet_arr << JSON.parse(val)) unless val.nil?
        break if list_size <= tweet_arr.size || tweet_arr.size > TWEETS_PER_ENHANCE_WORKER
      end
    end

    #Rails.logger.debug "Took #{time} to perform with #{tweet_arr.size} elements\n\n"

    (TweetEnhanceWorker.perform_async tweet_arr.select{ |a| !a.nil? }) unless tweet_arr.empty?

    t = (Time.now - HOURS_UNTIL_ARCHIVE.hours).to_f
    keys_older_than_2_hours = redis.hkeys($redis_keys[:enhanced_tweets]).select{ |k| t > k.to_f }
    #debugger
    ArchiveTweetWorker.perform_async pop_enhanced_tweets keys_older_than_2_hours unless keys_older_than_2_hours.empty?
  end


  private

  def redis; @_redis ||= Redis.new host: $redis_config[:host], port: $redis_config[:port], thread_safe: true; end

  def pop_tweets_older_than_timestamp(t)
    time_stamp = t.to_i
    oldest_keys = redis.hkeys($redis_keys[:enhanced_tweets]).select{ |key| key < time_stamp }
    ret_val = redis.hmget $redis_keys[:enhanced_tweets], oldest_keys
    redis.hdel redis_keys[:enhanced_tweets], oldest_keys
    ret_val
  end

  def pop_enhanced_tweets(n)
    Rails.logger.debug "HMGET args were: #{[$redis_keys[:enhanced_tweets], n].inspect}"
    begin
      results = redis.hmget($redis_keys[:enhanced_tweets], n)
    rescue

    end
    redis.hdel $redis_keys[:enhanced_tweets], n
    results
  end

  def size_of_list(key)
    redis.llen key
  end

  # Not implimented
  def max_worker_chunk

  end

end
