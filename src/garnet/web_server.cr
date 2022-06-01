require "router"
require "redis"
require "cors"
require "./structs/garnet_video"
module Garnet
  class WebServer
    include Router
    # this should be changed to a connection pool ASAP
    @@redis = Redis.new(host: Garnet::REDIS_HOST, port: Garnet::REDIS_PORT, password: Garnet::REDIS_PASSWORD, namespace: Garnet::REDIS_NAMESPACE)

    def draw_routes
      post "/video/info" do |context, params|
        begin
          req_body = JSON.parse(context.request.body.not_nil!.gets_to_end)
          puts "getting info on video at '#{req_body["youtube_url"]}'"
          ydl_vid = Ydl::Video.new(req_body["youtube_url"].to_s)
          response_body = {
            "title": ydl_vid.title,
            "url": ydl_vid.url,
            "channel_url": ydl_vid.channel_url,
            "thumbnails": ydl_vid.thumbnails.map{|tn| tn.attributes },
            "best_formats": ydl_vid.best_formats.map{|vf| vf.attributes },
            "full_formats":{
              "video": ydl_vid.full_formats.map{|vf| vf.attributes },
              "audio": ydl_vid.audio_formats.map{|af| af.attributes }
            }
          }.to_json
        rescue e
          response_body = {"error": e.to_s}.to_json
        end
        context.response.headers["Access-Control-Allow-Origin"] = ENV["GARNET_CORS_ORIGIN_ALLOW"]
        context.response.headers["Access-Control-Allow-Methods"] = Garnet::ALLOWED_HTTP_METHODS
        context.response.headers["Content-Type"] = "application/json"
        context.response.print response_body
        context
      end

      post "/video/download" do |context, params|
        req_body = JSON.parse(context.request.body.not_nil!.gets_to_end)
        ydl_vid = Ydl::Video.new(req_body["youtube_url"].to_s)
        gv = GarnetVideo.new("", ydl_vid.title.to_s, req_body["youtube_url"].to_s, req_body["format_id"].to_s)
        puts "adding video '#{gv.video_title}'(#{gv.id}) to download queue"
        if @@redis.publish(Garnet::DOWNLOAD_BUS, gv.to_json)
          push_response = true
        else
          push_response = false
        end
        context.response.headers["Access-Control-Allow-Origin"] = ENV["GARNET_CORS_ORIGIN_ALLOW"]
        context.response.headers["Access-Control-Allow-Methods"] = Garnet::ALLOWED_HTTP_METHODS
        context.response.headers["Content-Type"] = "application/json"
        context.response.print push_response
        context
      end

      get "/downloads/active" do |context, params|
        puts "listing active download"
        active_download = (@@redis.get(Garnet::ACTIVE_DOWNLOAD) || "{}")
        context.response.headers["Access-Control-Allow-Origin"] = ENV["GARNET_CORS_ORIGIN_ALLOW"]
        context.response.headers["Access-Control-Allow-Methods"] = Garnet::ALLOWED_HTTP_METHODS
        context.response.headers["Content-Type"] = "application/json"
        context.response.print active_download
        context
      end

      get "/downloads/list" do |context, params|
        puts "listing download queue"
        dlist = @@redis.lrange(Garnet::DOWNLOAD_QUEUE, 0, -1).map{|vd| JSON.parse(vd.to_s) }
        context.response.headers["Access-Control-Allow-Origin"] = ENV["GARNET_CORS_ORIGIN_ALLOW"]
        context.response.headers["Access-Control-Allow-Methods"] = Garnet::ALLOWED_HTTP_METHODS
        context.response.headers["Content-Type"] = "application/json"
        context.response.print dlist.to_json
        context
      end
      
      delete "/downloads/list" do |context, params|
        req_body = JSON.parse(context.request.body.not_nil!.gets_to_end)
        @@redis.lrange(Garnet::DOWNLOAD_QUEUE, 0, -1).map{|vd| JSON.parse(vd.to_s) }.each_with_index{|v,i|
          if v["id"] == req_body["download_id"].to_s
            puts "Deleting '#{v["video_title"]}'(#{v["id"]}) from download queue!"
            @@redis.lrem(Garnet::DOWNLOAD_QUEUE, 1, v.to_json.to_s)
          end
        }
        context.response.headers["Access-Control-Allow-Origin"] = ENV["GARNET_CORS_ORIGIN_ALLOW"]
        context.response.headers["Access-Control-Allow-Methods"] = Garnet::ALLOWED_HTTP_METHODS
        context.response.headers["Content-Type"] = "application/json"
        context.response.print @@redis.lrange(Garnet::DOWNLOAD_QUEUE, 0, -1).map{|vd| JSON.parse(vd.to_s) }.to_json
        context
      end

      purge "/downloads/list" do |context, params|
        puts "purging entire download queue!"
        @@redis.del(Garnet::DOWNLOAD_QUEUE)
        context.response.headers["Access-Control-Allow-Origin"] = ENV["GARNET_CORS_ORIGIN_ALLOW"]
        context.response.headers["Access-Control-Allow-Methods"] = Garnet::ALLOWED_HTTP_METHODS
        context.response.headers["Content-Type"] = "application/json"
        context.response.print @@redis.lrange(Garnet::DOWNLOAD_QUEUE, 0, -1).map{|vd| JSON.parse(vd.to_s) }.to_json
        context
      end
    end

    def run
      server = HTTP::Server.new([
        route_handler,
        Cors::Handler.new(
          respond_ok: ->(ctx : HTTP::Server::Context) {
            ctx.response.status = HTTP::Status::OK
            ctx.response.content_type = "application/json"
            ctx.response.print("{}")
          },
          allowed_origins: [ENV["GARNET_CORS_ORIGIN_ALLOW"]],
          allowed_methods: Garnet::ALLOWED_HTTP_METHODS
        )
      ])
      address = server.bind_tcp Garnet::BIND_INTERFACE, Garnet::BIND_PORT
      puts "Garnet API Listening on http://#{address}"
      server.listen
    end
  end
end
