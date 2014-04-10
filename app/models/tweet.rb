class Tweet

  ELASTIC_SEARCH_TWEET_TYPE = 'tweet'

  def self.all

  end

  def self.search_str(str)
    query = {
        query:{
            match:{
                text: str
            }
        }
    }
    result = SimpleElasticSearch.search $elasticsearch_config[:host], $elasticsearch_config[:port], index_name, query, ELASTIC_SEARCH_TWEET_TYPE
    result.hits.hits
  end

end