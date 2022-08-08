require "redis"

RedisDB = Redis.new(url: Config::Setting.current.redis_url)