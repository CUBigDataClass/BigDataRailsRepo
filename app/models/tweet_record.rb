class TweetRecord < ActiveRecord::Base
  table_name = :tweets

  attr_accessible :text, :lat, :long
end