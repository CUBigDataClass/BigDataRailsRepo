require 'twitter'
require 'yaml'

module TwitterClient

  def client
    unless @@client
      tw_config = YAML.load_file( File.join(File.dirname(__FILE__), '..', 'twitter.yml' ) )[Rails.env]
      @@client = Twitter::REST::Client.new do |config|
        config.consumer_key        = tw_config[:api_key]
        config.consumer_secret     = tw_config[:api_secret]
        config.access_token        = tw_config[:access_token]
        config.access_token_secret = tw_config[:access_token_secret]
      end
    end
    @@client
  end

  private

  def method_missing(method, *args, &block)
    self.client.send(method, args, block)
  end

end