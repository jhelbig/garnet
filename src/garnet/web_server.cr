require "router"
require "redis"
require "cors"
module Garnet
  class WebServer
    include Router
    # this should be changed to a connection pool ASAP
    @@redis = Redis.new(host: Garnet::REDIS_HOST, port: Garnet::REDIS_PORT, password: Garnet::REDIS_PASSWORD, namespace: Garnet::REDIS_NAMESPACE)

    def draw_routes
      post "/video/info" do |context, params|
        req_body = JSON.parse(context.request.body.not_nil!.gets_to_end)
        ydl_vid = Ydl::Video.new(req_body["youtube_url"].to_s)
        response_body = {
          "title": ydl_vid.title,
          "url": ydl_vid.url,
          "best_formats": ydl_vid.best_formats.map{|vf| vf.attributes },
          "full_formats":{
            "video": ydl_vid.full_formats.map{|vf| vf.attributes },
            "audio": ydl_vid.audio_formats.map{|af| af.attributes }
          }
        }.to_json
        context.response.headers["Access-Control-Allow-Origin"] = "*"
        context.response.headers["Access-Control-Allow-Methods"] = "GET, POST, OPTIONS, PUT, PATCH, DELETE"
        context.response.headers["Content-Type"] = "application/json"
        context.response.print response_body
        context
      end

      post "/video/download" do |context, params|
        # TODO - insert into collection with GUID for future feature to remove items
        req_body = JSON.parse(context.request.body.not_nil!.gets_to_end)
        ydl_vid = Ydl::Video.new(req_body["youtube_url"].to_s)
        if @@redis.publish(Garnet::DOWNLOAD_BUS, {"message": "New video has been requested for download!", "video_title": ydl_vid.title, "url": req_body["youtube_url"].to_s, "quality": req_body["format_id"]}.to_json)
          push_response = true
        else
          push_response = false
        end
        context.response.headers["Access-Control-Allow-Origin"] = "*"
        context.response.headers["Access-Control-Allow-Methods"] = "GET, POST, OPTIONS, PUT, PATCH, DELETE"
        context.response.headers["Content-Type"] = "application/json"
        context.response.print push_response
        context
      end

      # TODO - Add endpoint to remove an item from the list based on GUID

      get "/downloads/active" do |context, params|
        active_download = JSON.parse(@@redis.get(Garnet::ACTIVE_DOWNLOAD) || "{}")
        context.response.headers["Access-Control-Allow-Origin"] = "*"
        context.response.headers["Access-Control-Allow-Methods"] = "GET, POST, OPTIONS, PUT, PATCH, DELETE"
        context.response.headers["Content-Type"] = "application/json"
        context.response.print active_download.to_json
        context
      end

      get "/downloads/list" do |context, params|
        dlist = @@redis.lrange(Garnet::DOWNLOAD_QUEUE, 0, -1).map{|vd| JSON.parse(vd.to_s) }
        context.response.headers["Access-Control-Allow-Origin"] = "*"
        context.response.headers["Access-Control-Allow-Methods"] = "GET, POST, OPTIONS, PUT, PATCH, DELETE"
        context.response.headers["Content-Type"] = "application/json"
        context.response.print dlist.to_json
        context
      end

      delete "/downloads/clear" do |context, params|
        @@redis.del(Garnet::DOWNLOAD_QUEUE)
        context.response.headers["Access-Control-Allow-Origin"] = "*"
        context.response.headers["Access-Control-Allow-Methods"] = "GET, POST, OPTIONS, PUT, PATCH, DELETE"
        context.response.headers["Content-Type"] = "application/json"
        context.response.print true
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
          allowed_origins: ["*"],
          allowed_methods: ["GET","POST","OPTIONS","PUT","PATCH","DELETE"]
        )
      ])
      address = server.bind_tcp Garnet::BIND_INTERFACE, Garnet::BIND_PORT
      puts "Listening on http://#{address}"
      server.listen
    end
  end
end
