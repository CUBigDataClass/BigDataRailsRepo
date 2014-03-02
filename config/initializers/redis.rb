redis_config = YAML.load_file(File.join(Rails.root, 'config', 'redis.yml'))[Rails.env]

$redis = Redis.new :host => redis_config[:host], :port => redis_config[:port]

$redis_keys={
    raw_tweets: 'twitter:raw'
}