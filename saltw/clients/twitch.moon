
http_request = require "http.request"
json = require "cjson"

class Twitch
  irc_api_base: "https://tmi.twitch.tv"
  api_base: "https://api.twitch.tv/helix"
  oauth_base: "https://id.twitch.tv/oauth2"

  new: (@current_stream) =>

  get_client_id: =>
    unless @client
      @client = assert @http_request "validate", {
        send_client_id: false
        api_base: @oauth_base
      }

    @client.client_id

  http_request: (path, opts={}) =>
    url = "#{opts.api_base or @api_base}/#{path}"

    if opts.query
      import encode_query_string from require "lapis.util"
      url = "#{url}?#{encode_query_string opts.query}"

    req = assert http_request.new_from_uri url

    unless opts.auth == false
      oauth_token = assert require("pass")!
      oauth_token = oauth_token\gsub "^oauth:", ""
      req.headers\append "authorization", "OAuth #{oauth_token}"

      unless opts.send_client_id == false
        req.headers\append "client-id", @get_client_id!

    headers, stream = assert req\go!

    body = assert stream\get_body_as_string!

    status = headers\get ":status"
    unless status == "200"
      return nil, "failed to fetch: #{status}", body

    response = json.decode body
    response, headers

  get_current_stream: =>
    res, err = @get_streams {
      user_login: @current_stream
    }

    return nil, err unless res

    res.data[1]

  get_streams: (opts) =>
    @http_request "streams", {
      query: opts
    }

  -- http://tmi.twitch.tv/group/user/moonscript/chatters
  get_chatters: =>
    response, headers = @http_request "group/user/#{@current_stream}/chatters", {
      api_base: @irc_api_base
      auth: false
    }
    response.chatters, response.chatter_count

