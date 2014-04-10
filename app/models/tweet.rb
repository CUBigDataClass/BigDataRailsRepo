class Tweet
  extend SimpleElasticSearch

  ELASTIC_SEARCH_TWEET_TYPE = 'tweet'

  def self.all
    results = self.all_docs_in_index $elasticsearch_config[:host], $elasticsearch_config[:port], $elasticsearch_index
    results.hits.hits
  end

  def self.search_str(str)
    query = {
        query:{
            match:{
                text: str
            }
        }
    }
    result = self.search $elasticsearch_config[:host], $elasticsearch_config[:port], $elasticsearch_index, query, ELASTIC_SEARCH_TWEET_TYPE
    result.hits.hits
  end

end
