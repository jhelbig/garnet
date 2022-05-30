require "uuid"
require "json"

struct GarnetVideo
  getter id : String
  getter message : String = "New video has been requested for download!"
  getter video_title : String
  getter url : String
  getter quality : String
  getter downloading : Bool = false

  def initialize(msg : String, title : String, vurl : String, vqual : String)
    @id = UUID.random().to_s
    @message = msg unless msg.empty?
    @video_title = title
    @url = vurl
    @quality = vqual
    @downloading = false
  end
  
  def initialize(jsn : JSON::Any)
    jsn = jsn.as_h
    @id = jsn["id"].as_s
    @message = jsn["message"].as_s
    @video_title = jsn["video_title"].as_s
    @url = jsn["url"].as_s
    @quality = jsn["quality"].as_s
    @downloading = jsn["downloading"].as_bool
  end
  
  def attributes : Hash(String, String | Bool)
    return {
      "id" => @id,
      "message" => @message,
      "video_title" => @video_title,
      "url" => @url,
      "quality" => @quality,
      "downloading" => @downloading
    }
  end

  def to_json
    self.attributes.to_json
  end
  
  def triggerDownload
    @downloading = true
  end
end