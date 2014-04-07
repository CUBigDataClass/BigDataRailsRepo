class BDElasticSearch::Base < ActiveRecord::Base
  include ElasticSearch::Model
  include Elasticsearch::Model::Callbacks
end
