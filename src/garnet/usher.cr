# https://www.youtube.com/watch?v=w0HgHet0sxg
require "redis"
module Garnet
  class Usher
    def initialize()
      @redis_sub = Redis.new(host: Garnet::REDIS_HOST, port: Garnet::REDIS_PORT, password: Garnet::REDIS_PASSWORD, namespace: Garnet::REDIS_NAMESPACE)
      @redis = Redis.new(host: Garnet::REDIS_HOST, port: Garnet::REDIS_PORT, password: Garnet::REDIS_PASSWORD, namespace: Garnet::REDIS_NAMESPACE)
      @redis_sub.subscribe(Garnet::DOWNLOAD_BUS) do |on|
        on.message do |channel, message|
          @redis.rpush(Garnet::DOWNLOAD_QUEUE, message.to_s)
        end
      end
    end
  end
end
