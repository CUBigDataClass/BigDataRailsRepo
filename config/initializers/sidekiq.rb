require 'sidekiq'
require 'sidekiq/web'

Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://127.0.0.1:6379' }
end


#if Rails.env.production?
#  Sidekiq.configure_server do |config|
#    config.redis = { url: "redis://127.0.0.1:6379" }
#  end
#  Sidekiq.configure_client do |config|
#    config.redis = { url: "redis://127.0.0.1:6379" }
#  end
#elsif Rails.env.staging?
#  Sidekiq.configure_server do |config|
#    config.redis = { url: "redis://127.0.0.1:6379" }
#  end
#  Sidekiq.configure_client do |config|
#    config.redis = { url: "redis://127.0.0.1:6379" }
#  end
#else
#  Sidekiq.configure_server do |config|
#    config.redis = { url: 'redis://127.0.0.1:6379' }
#  end
#end
