class TwitterController < ApplicationController
  def query

    result = client.search params[:query_str] #, params[:query_params]

    respond_to do |format|
      format.json{ render text: result.inject(""){ |acc, tweet| "#{acc} #{tweet.text}\n\n" } and return }
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
