class Tweet
  extend SimpleElasticSearch

  ELASTIC_SEARCH_TWEET_TYPE = 'tweet'
  @@_es_client = Elasticsearch::Client.new

  def self.all
    results = self.all_docs_in_index $elasticsearch_config[:host], $elasticsearch_config[:port], $elasticsearch_index
    results.hits.hits
  end

  def self.query(query)
    result = elasicsearch_client.search(
      index: $elasticsearch_index,
      body: query
    )
    hits = get_hits result
    ret = hits.collect do |r|
      begin
        [r['_source']['lat'], r['_source']['lon']]
      rescue
        nil
      end
    end

    ret.delete nil
    ret
  end

  def self.search_str(str)
    query = {
        query:{
            query_string:{
                query: (str)
            }
        }
    }
    result = self.search $elasticsearch_config[:host], $elasticsearch_config[:port], $elasticsearch_index, query, ELASTIC_SEARCH_TWEET_TYPE
    result.hits.hits
  end

  def self.elasicsearch_client
    @@_es_client
  end

end
