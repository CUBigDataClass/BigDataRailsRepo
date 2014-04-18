class TwitterController < ApplicationController

  RADIUS = '10mi'

  def index; end

  def all_city_search
    city_geos = City.all.collect{ |city| [city.latitude, city.longitude] }
    radius = params[:radius] || RADIUS

    all_tweets=[]
    search_threads=[]
    city_geos[0..4].each do |city_geo|
      search_threads << Thread.new do
        geo_str = "#{city_geo[0]}, #{city_geo[-1]}, #{radius}"
        Rails.logger.debug "All city query: #{params[:query_str]} #{geo_str}"

        begin
          result = client.search( params[:query_str], {geocode: geo_str, count: 5} ).collect(&:text)
          Rails.logger.debug result
          all_tweets.merge result
        rescue => e
          puts e.message
          sleep 10
          retry
        end
      end
    end
    search_threads.each(&:join)

    respond_to do |format|
      format.json { render json: all_tweets.to_json }
      format.text { render text: all_tweets.inspect }
    end
  end

  def query
    result = Twitter.search_str( query )
    respond_to do |format|
      format.json{ render text: result.inject(""){ |acc, tweet| "#{acc} #{tweet.text}\n\n" } and return }
    end
  end

  #GET /twitter/elasticsearch_query?query='{
  #   "query":{
  #     "stuff":{}
  #   }
  # }'

  def elasticsearch_query
    query_obj = params[:query]
    result = Tweet.search(query_obj)
    # TODO: Filter out only lat lon

    respond_to do |format|
      format.json{ render json: result }
    end
  end

  # Sample of all tweets in elasticsearch
  def elasticsearch_sample
    results = Tweet.all
    if params[:geo]
      results = results.collect do |redis_arr|
        tweet = JSON.parse redis_arr[-1]
        [tweet['lat'].to_f, tweet['lon'].to_f]
      end
      results.delete []
    end

    respond_to do |format|
      format.json{ render json: results.to_json }
    end
  end

  # lat lon sample from all tweets in redis
  def lat_lon_sample
    results = $redis.hgetall $redis_keys[:enhanced_tweets]
    results = results.collect do |redis_arr|
      tweet = JSON.parse redis_arr[-1]
      [tweet['lat'].to_f, tweet['lon'].to_f]
    end
    results.delete []

    respond_to do |format|
      format.json{ render json: results.to_json }
    end
  end

  private

  def client
    @@client ||= init_client
  end

  def init_client
    tw_config = YAML.load_file( File.join(Rails.root, 'config','twitter.yml' ) )[Rails.env]

    Rails.logger.debug tw_config
    Twitter::REST::Client.new do |config|
      config.consumer_key        = tw_config["api_key"]
      config.consumer_secret     = tw_config["api_secret"]
      config.access_token        = tw_config["access_token"]
      config.access_token_secret = tw_config["access_token_secret"]
    end
  end
end
