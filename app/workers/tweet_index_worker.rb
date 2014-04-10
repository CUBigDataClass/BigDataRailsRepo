# Sidekiq worker to index tweets into elasticsearch

class TweetIndexWorker
  include Sidekiq::Worker
  include SimpleElasticSearch

  def perform(tweet_arr)
    bulk_index format_tweets(tweet_arr)
  end

  private
  def bulk_index(arr)
    payload = arr.inject([]) do |acc, tweet|
      acc << { index: { _index: $elasticsearch_index, _type: Tweet::ELASTIC_SEARCH_TWEET_TYPE } }
      acc << tweet
    end
    Rails.logger.debug post_bulk $elasticsearch_config.host, $elasticsearch_config.port, payload, $elasticsearch_index
  end

  def format_tweets(tweets)
    tweets.map do |tweet|
      format_lat_long tweet
    end
  end

  def format_lat_long(tweet)
    tweet[:location] = { lat: tweet.lat, lon: tweet.lon }
    tweet
  end

end