require './simple_elastic_search'
require 'debugger'

include SimpleElasticSearch

host = "http://localhost"
port = 9200
index_name = 'big-data'

tweet_mapping = {
    mappings:{
        tweet:{
            properties:{
                tweet_text:{ type:"string", index_title: "text" },
                username:{ type:"string" },
                location:{ type:"geo_point" },
                hashtags:{ type:"string" }
            }
        }
    }
}

require 'json'

def lines
  puts "\n\n\n"
end

puts SimpleElasticSearch.delete_index host, port, index_name
lines
puts SimpleElasticSearch.create_mapping host, port, index_name, tweet_mapping
lines
puts SimpleElasticSearch.post host, port, index_name, 'tweet', { text: 'HIHIHIHIHIHIHIHIH', location: [-23.2943843, 87.298484], hashtags: ['#yolo', '#princeofpersia'] }
lines
puts SimpleElasticSearch.all_docs_in_index host, port, index_name, 'tweet'
lines

query = {
    query:{
        match:{
          text: 'HIHIHIHIHIHIHIHIH'
        }
    }
}

sleep 2
puts "THIS IS THE ANSWER: " + SimpleElasticSearch.search( host, port, index_name, query, 'tweet' ).hits.hits.to_s