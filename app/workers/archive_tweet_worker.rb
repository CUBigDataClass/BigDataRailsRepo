class ArchiveTweetWorker
  include Sidekiq::Worker

  CHUNK = 100

	# Expects an array of hash representations of Tweet objects
  def perform(tweet_arr)
  	open_buffer
    save_all_tweets tweet_arr
  	close_buffer
    Rails.logger.debug "Wrote out #{tweet_arr.size} tweets"
  end

  private

  def file_path
    File.join Rails.root, 'db', 'dat', 'tweets.yml'
  end

  def save_all_tweets(tweets)
    tweets.each{ |t| save t.to_yaml }
  end

  def open_buffer
    @_file = File.open(file_path, 'w')
  end

  def close_buffer
    @_file.close
  end

  def save(tweet)
    @_file << (tweet + "\n")
  end

end
