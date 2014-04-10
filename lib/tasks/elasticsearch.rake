require_relative '../../lib/simple_elastic_search'

namespace :elasticsearch do
  include SimpleElasticSearch
  desc 'Load all specified mappings in db/elastic/search/mappings'
  task load_mappings: :environment do
    mappings_dir = File.join Rails.root, 'db', 'elasticsearch', 'mappings'
    Dir.entries(mappings_dir).map{ |entry| File.join mappings_dir, entry }.each do |mapping|
      next if File.directory? mapping
      map_hash = JSON.parse File.read mapping
      Rails.logger.debug mapping
      result = SimpleElasticSearch.create_mapping $elasticsearch_config[:host], $elasticsearch_config[:port], $elasticsearch_index, map_hash
      Rails.logger.debug result
    end
  end
end