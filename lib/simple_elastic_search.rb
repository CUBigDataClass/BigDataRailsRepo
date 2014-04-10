require 'curl'
require 'json'
require 'debugger'
require './hash'
module SimpleElasticSearch


  LOGGING = false
  def create_index(host, port, index_name)
    result = perform host, index_name, :put, {}, port
    JSON.parse result
  end

  def create_mapping(host, port, index, options={})
    raise "Mapping options must be in the form of #{example_mappings_str}" unless options.keys.map{ |k| k.to_s }.include? 'mappings'
    result = perform host, index, :put, options, port
    JSON.parse result
  end

  def post(host, port, index, type, document={})
    path = "#{index}/#{type}"
    result = perform host, path, :post, document.to_json, port
    JSON.parse result
  end

  def post_bulk(host, payload, index=nil, type=nil)
    if index && type
      path = 'index/_bulk'
    elsif index
      path = 'index/type/_bulk'
    else
      path = '_bulk'
    end

    perform host, path, :post, payload, port
  end

  def all_docs_in_index(host, port, index, type=nil)
    path = (type ? "#{index}/#{type}" : "#{index}") + '/_search'
    puts [host, path, port]
    response = perform host, path, :get, {}, port
    JSON.parse( response )
  end

  def delete_index(host, port, index)
    response = perform host, index, :delete, {}, port
    JSON.parse response
  end

  def search(host, port, index, query={}, type=nil)
    base = type ? "#{index}/#{type}" : "#{index}"
    path = "#{base}/_search"
    response = perform host, path, :get, query, port
    result = JSON.parse( response )
    type ? result.hits : result.hit
    result
  end

  private
  def perform( host, path, action, params={}, port=nil )
    url = "#{host}:#{port}/#{path}"
    puts "Performing: #{[url, action, params]}" if LOGGING
    c = Curl.send(action, url, params)
    c.body_str
  end

  def example_mappings_str
    {
        mappings:{
            tweet:{
                properties:{
                    tweet_text:{ type:"string" },
                    username:{ type:"string" },
                    location:{ type:"geo_point" },
                    hashtags:{ type:"string" }
                }
            }
        }
    }.to_s
  end

end