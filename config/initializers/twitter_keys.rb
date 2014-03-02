require 'yaml'

$twitter_keys = YAML.load_file( File.join(File.dirname(__FILE__), '..', 'twitter.yml' ) )[Rails.env]
