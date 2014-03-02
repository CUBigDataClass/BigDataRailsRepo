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
      open_stream.each do |response|
        res = JSON.parse response
        yield block(res)
      end
    end

    private

    def oauth_nonce_str
      SecureRandom.hex
    end

    def stream_endpoint
      'https://stream.twitter.com/1.1/statuses/sample.json'
    end

    def open_stream

    end

    def twitter_get(url, params)
      curl = Curl.get(url) do |c|
        c.headers['oauth_consumer_key']     = key
        c.headers['oauth_signature_method'] = 'HMAC-SHA1'
        c.headers['oauth_timestamp']        = Time.utc_time.to_i
        c.headers['oauth_token']            = access_token
        c.headers['oauth_nonce']            = oauth_nonce_str
        c.headers['oauth_version']          = '1.0'
        c.headers['oauth_signature']        = 0
      end
    end

    def headers(url, method='GET', params='')
      return_val = {
        'url' => url,
        'oauth_consumer_key' => key,
        'oauth_signature_method' => 'HMAC-SHA1',
        'oauth_timestamp' => Time.utc.to_i,
        'oauth_token' => access_token,
        'oauth_nonce' => oauth_nonce_str,
        'oauth_version' => '1.0',
        'parameters' => params
      }

      return_val['']
    end

    def generate_parameter_str(params_hash)
      params_hash.each do |k, v|
        params_hash.delete k
        params_hash[URI.encode k] = URI.encode v
      end

      params_hash = params_hash.sort_by{ |k, v| k }.inject({}){ |acc, this| acc[this[0]] = this[1]; acc }

      return_str = params_hash.inject('') do |acc, value|
        acc << value[0]
        acc << '='
        acc << value[-1]
        acc << '&'
      end

      return_str.gsub /\&$/, ''
    end

    def generate_oauth_signature_base_str(params)
      method = params['method'].uppercase
      output_str = method + '&'
      encode_url = URI.encode params['url']
      output_str = output_str + '&' + encode_url
      output_str + '&' + URI.encode(params['parameters'])
    end

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

    def access_token

    end

# Exchange our oauth_token and oauth_token secret for the AccessToken instance.
    access_token = prepare_access_token("abcdefg", "hijklmnop")
# use the access token as an agent to get the home timeline
    response = access_token.request(:get, "https://api.twitter.com/1.1/statuses/home_timeline.json")

  end
end