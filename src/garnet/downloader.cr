# https://www.youtube.com/watch?v=w0HgHet0sxg
require "redis"
module Garnet
  class Downloader
    def initialize()
      @redis = Redis.new(host: Garnet::REDIS_HOST, port: Garnet::REDIS_PORT, password: Garnet::REDIS_PASSWORD, namespace: Garnet::REDIS_NAMESPACE)
      while true
        if (@redis.get(Garnet::ACTIVE_DOWNLOAD) == "" || @redis.get(Garnet::ACTIVE_DOWNLOAD).nil?) && @redis.lrange(Garnet::DOWNLOAD_QUEUE, 0, -1).size > 0
          vd = @redis.lpop(Garnet::DOWNLOAD_QUEUE)
          self.downloadVideo(JSON.parse(vd)) if !vd.nil?
          sleep 3
        elsif !@redis.get(Garnet::ACTIVE_DOWNLOAD).nil?
          self.downloadVideo(JSON.parse(@redis.get(Garnet::ACTIVE_DOWNLOAD).to_s)) if @redis.get(Garnet::ACTIVE_DOWNLOAD) != ""
        else
          sleep 15
        end
      end
    end

    private def downloadVideo(msg : JSON::Any)
      @redis.set(Garnet::ACTIVE_DOWNLOAD, msg.to_json)
      puts "Downloading video: #{msg["video_title"]}"
      ydl_vid = Ydl::Video.new(msg["url"].to_s)
      if msg["quality"].to_s.downcase == "best"
        ydl_vid.download_and_mux(ydl_vid.best_formats)
      else
        ydl_vid.download(msg["quality"].to_s)
      end
      puts "Downloading video complete: #{msg["video_title"]}"
      @redis.publish(Garnet::NOTIFY_QUEUE, {"message": "Download complete!", "video_title": msg["video_title"], "video_url": msg["url"]})
      @redis.del(Garnet::ACTIVE_DOWNLOAD)
    end
  end
end
