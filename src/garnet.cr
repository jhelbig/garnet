# TODO: Write documentation for `Garnet`
require "option_parser"
require "ydl"
require "./garnet/*"

module Garnet
  VERSION = "1.5.8"
  BIND_PORT = ENV["GARNET_HTTP_PORT"].to_i
  BIND_INTERFACE = "0.0.0.0"
  REDIS_HOST = ENV["GARNET_REDIS_HOST"]
  REDIS_PORT = ENV["GARNET_REDIS_PORT"].to_i
  REDIS_PASSWORD = ENV["GARNET_REDIS_PASSWORD"]
  REDIS_NAMESPACE = ENV["GARNET_REDIS_NAMESPACE"]
  #REDISU = Redis.new(host: "0.0.0.0", port: 6379, password: "garnet_dev", namespace: "YTDL") # this needs to be replaced by a connection pool
  NOTIFY_QUEUE = ENV["GARNET_NOTIFY_QUEUE"]
  DOWNLOAD_BUS = "garnet_download"
  DOWNLOAD_QUEUE = "garnet_download_queue"
  ACTIVE_DOWNLOAD = "garnet_active_download"
  DOWNLOADER_SLEEP_TIMEOUT = ENV["GARNET_DOWNLOADER_SLEEP"].to_i
  DOWNLOAD_QUANTITY = 1
end

OptionParser.parse do |parser|
  parser.banner = "Garnet - Youtube download service"

  parser.on "-v", "--version", "Show version" do
    puts "version #{Garnet::VERSION}"
    exit
  end

  parser.on "-h", "--help", "Show help" do
    puts parser
    exit
  end

  parser.on "-s TYPE", "--server=TYPE", "Start a server: web/downloader" do |server_type|
    if server_type == "web"
      webServer = Garnet::WebServer.new
      webServer.draw_routes
      webServer.run
    end

    if server_type == "downloader"
      Garnet::Downloader.new
    end

    if server_type == "usher"
      Garnet::Usher.new
    end
  end
end
