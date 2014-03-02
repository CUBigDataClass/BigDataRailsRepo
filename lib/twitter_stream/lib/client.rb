=begin
# Exchange your oauth_token and oauth_token_secret for an AccessToken instance.
def prepare_access_token(oauth_token, oauth_token_secret)
  consumer = OAuth::Consumer.new("APIKey", "APISecret",
    { :site => "https://api.twitter.com",
      :scheme => :header
    })
  # now create the access token object from passed values
  token_hash = { :oauth_token => oauth_token,
                 :oauth_token_secret => oauth_token_secret
               }
  access_token = OAuth::AccessToken.from_hash(consumer, token_hash )
  return access_token
end

# Exchange our oauth_token and oauth_token secret for the AccessToken instance.
access_token = prepare_access_token("abcdefg", "hijklmnop")
# use the access token as an agent to get the home timeline
response = access_token.request(:get, "https://api.twitter.com/1.1/statuses/home_timeline.json")
=end

require 'curb'
require 'json'
require 'oauth'
require 'securerandom'
require 'uri'

module TwitterStream
  class Client
    attr_reader :key, :secret, :access_token, :access_token_secret

    def initialize(key, secret, access_token, access_token_secret)
      @key = key
      @secret = secret
      @access_token = access_token
      @access_token_secret = access_token_secret
    end

    def stream(&block)
      open_stream.each_line do |response|
        res = JSON.parse response
        yield block(res)
      end
    end

    private

    def stream_endpoint
      'https://stream.twitter.com/1.1/statuses/sample.json'
    end

    def open_stream
      twitter_request :get, stream_endpoint
    end

    def prepare_access_token(oauth_token, oauth_token_secret)
      consumer = OAuth::Consumer.new(key, secret,
                                     { :site => "https://api.twitter.com",
                                       :scheme => :header
                                     })
      # now create the access token object from passed values
      token_hash = { :oauth_token => oauth_token,
                     :oauth_token_secret => oauth_token_secret
      }
      access_token = OAuth::AccessToken.from_hash(consumer, token_hash )
      return access_token
    end

    def twitter_request(method, url)
      client = prepare_access_token(access_token, access_token_secret)
      client.request method, url
    end

  end
end