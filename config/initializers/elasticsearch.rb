config_path = File.join Rails.root, 'config', 'elasticsearch.yml'
$elasticsearch_config = YAML.load_file(config_path)[Rails.env].symbolize_keys
$elasticsearch_index = 'big-data'