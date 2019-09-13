
http_request = require "http.request"
json = require "cjson"

class Twitch
  api_base: "https://tmi.twitch.tv"

  new: (@channel) =>

  http_request: (path) =>
    url = "#{@api_base}/#{path}"
    headers, stream = assert http_request.new_from_uri(url)\go!

    body = stream\get_body_as_string!

    status = headers\get ":status"
    unless status == "200"
      return nil, "failed to fetch chatters: #{status}"

    response = json.decode body
    response, headers

  -- http://tmi.twitch.tv/group/user/moonscript/chatters
  get_chatters: =>
    response, headers = @http_request "group/user/#{@channel}/chatters"
    response.chatters, response.chatter_count


