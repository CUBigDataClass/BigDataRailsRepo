require 'curl'
require 'json'
require_relative './hash.rb'

module SimpleElasticSearch

  LOGGING = false

  def get_hits(input)
    if input.is_a?(Hash) && input.keys.include?('hits')
      get_hits input['hits']
    else
      input
    end
  end

  def create_index(host, port, index_name)
    result = perform_elasticsearch host, index_name, :put, {}, port
    JSON.parse result
  end

  def create_mapping(host, port, index, options={})
    raise "Mapping options must be in the form of #{example_mappings_str}" unless options.keys.map{ |k| k.to_s }.include? 'mappings'
    result = perform_elasticsearch host, index, :put, options, port
    JSON.parse result
  end

  def post(host, port, index, type, document={})
    path = "#{index}/#{type}"
    result = perform_elasticsearch host, path, :post, document.to_json, port
    JSON.parse result
  end

  def post_bulk(host, port, payload, index=nil, type=nil)
    if index && type
      path = 'index/_bulk'
    elsif index
      path = 'index/type/_bulk'
    else
      path = '_bulk'
    end
    payload = bulkify_array(payload)
    response = perform_elasticsearch( host, path, :post, payload, port )
    JSON.parse response
  end

  def all_docs_in_index(host, port, index, type=nil, max=nil)
    path = (type ? "#{index}/#{type}" : "#{index}") + '/_search'
    puts [host, path, port]

    all_query = {
      query:{
        query_string:{
          query: "*"
        }
      },
      from: 0,
      size: (max || 100000)
    }

    response = perform_elasticsearch host, path, :get, all_query, port
    JSON.parse response
  end

  def delete_index(host, port, index)
    response = perform_elasticsearch host, index, :delete, {}, port
    JSON.parse response
  end

  def search(host, port, index, query={}, type=nil)
    base = type ? "#{index}/#{type}" : "#{index}"
    path = "#{base}/_search"
    response = perform_elasticsearch host, path, :get, query, port
    result = JSON.parse( response )
    type ? result.hits : result.hit
    result
  end

  private

  def perform_elasticsearch( host, path, action, params={}, port=nil )
    url = "#{host}:#{port}/#{path}"
    puts "Performing: #{[url, action, params]}" if LOGGING
    params = params.to_json unless [String, Hash].include? params.class
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

  # adapted from elasticsearch-api for handling Array bulk actions
  # https://github.com/elasticsearch/elasticsearch-ruby/blob/master/elasticsearch-api/lib/elasticsearch/api/utils.rb
  def bulkify_array(payload)
    case
      # Hashes with `:data`
      when payload.any? { |d| d.is_a?(Hash) && d.values.first.is_a?(Hash) && (d.values.first[:data] || d.values.first['data']) }
        payload = payload.
            inject([]) do |sum, item|
          operation, meta = item.to_a.first
          meta            = meta.clone
          data            = meta.delete(:data) || meta.delete('data')

          sum << { operation => meta }
          sum << data if data
          sum
        end.
            map { |item| MultiJson.dump(item) }
        payload << "" unless payload.empty?
        return payload.join("\n")

      # Array of strings
      when payload.all? { |d| d.is_a? String }
        payload << ''

      # Header/Data pairs
      else
        payload = payload.map { |item| MultiJson.dump(item) }
        payload << ''
    end

    payload = payload.join("\n")
  end

end
