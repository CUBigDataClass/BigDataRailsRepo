class ArchiveTweetWorker
	include Sidekiq::Worker

  CHUNK = 100

	def perform
    while true
      tweets = pop_tweets
      open_buffer
      save_all_tweets tweets
      close_buffer
    end
	end

	private

  def file_path
    File.join Rails.root, 'tmp', 'tweets.json'
  end

  def pop_tweets
    ret_val = []
    CHUNK.times{ |a| ret_val << $redis.brpop($redis_keys[:twitter_enhanced], 0)[-1] }
    ret_val.map(&:to_json)
  end
  
  def save_all_tweets(tweets)
    tweets.each{ |t| save t }
  end
  
  def open_buffer
    @_file = File.open(file_path, 'w')
  end
  
  def close_buffer
    @_file.close
  end

  def save(tweet)
    @_file << tweet
  end

end
