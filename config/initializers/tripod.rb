Tripod.configure do |config|

  #config.cache_store = Tripod::CacheStores::MemcachedCacheStore.new('localhost:11211') || nil
  #config.response_limit_bytes = nil
  #config.timeout_seconds = 60
  config.logger = Rails.logger

end
