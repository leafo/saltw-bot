
socket = require "socket"
{parse: parse_url} = require "socket.url"

import decode_html_entities from require "saltw.util"
import insert from table

import Reader from require "saltw.socket"

log = (...) -> print "+++", ...

class Irc
  colors = {
    white: 0
    black: 1
    blue: 2
    green: 3
    red: 4
    brown: 5
    purple: 6
    orange: 7
    yellow: 8
    lime: 9
    teal: 10
    aqua: 11
    royal: 12
    pink: 13
    grey: 14
    silver: 15
  }

  new: (@event_loop, @config) =>
    host = assert @config.host, "config missing host"
    @host, @port = host\match "^(.-):(%d*)$"

    @host or= @config.host
    @port or= 6667

    @message_handlers = {}
    @connect!

    irc = @
    @reader = Reader @socket, {
      loop: =>
        while true
          irc\handle_message @get_line!

      handle_error: (msg) =>
        irc.socket = nil
        if msg == "closed"
          log "Disconnected. Reconnecting in #{@config.reconnect_time} seconds"
          irc\reconnect!
        else
          error msg
    }

    @event_loop\add_listener @reader

  connect: =>
    @channels = {}
    @socket = socket.connect @host, @port

    unless @socket
      error "could not connect to server #{@host}:#{@port}"

    @socket\send "NICK #{@config.name}\r\n"
    @socket\send "USER ".."moon "\rep(3)..":Bildo Bagins\r\n"

    @event_loop\add_task {
      time: @config.join_delay or 1
      action: ->
        return unless @socket

        if @config.password
          @message_to "NickServ", "IDENTIFY #{@config.password}"

        for channel in *@config.channels
          @join channel
    }

  reconnect: =>
    @event_loop\add_task {
      interval: @config.reconnect_time
      action: (task) ->
        log "Reconnected:", pcall ->
          log "Trying to reconnect"
          @connect!
          @reader\set_socket @socket
          @event_loop\add_listener @reader
          task.interval = nil -- stop trying to reconnect
    }

  add_message_handler: (handler) =>
    insert @message_handlers, handler

  handle_message: (line) =>
    print "IRC:", line if @config.verbose

    ping = line\match "^PING :(.*)"
    if ping
      @socket\send "PONG #{ping}\r\n"
      log "PONG"
      return

    name, host, channel, msg = line\match(':([^!]+)!([^%s]+) PRIVMSG (#?[%w_]+) :(.*)')
    if name
      for handler in *@message_handlers
        handler @, name, channel, msg, host


  join: (channel) =>
    @socket\send "JOIN #{channel}\r\n"
    insert @channels, channel

  message: (msg, channel=@channels) =>
    if type(channel) == "table"
      for c in *channel
        @message msg, c
    else
      -- on channel
      @socket\send "PRIVMSG #{channel} :#{msg}\r\n"

  message_to: (who, msg) =>
    @socket\send 'PRIVMSG '..who..' :'..msg..'\r\n'

  me: (msg, channel=nil) =>
    msg = table.concat msg if type(msg) == "table"
    delim = string.char 0x01
    self\message table.concat({ delim, 'ACTION ', msg, delim }), channel

  color: (color, msg) =>
    delim = string.char 0x03
    table.concat { delim, colors[color] or color, msg, delim }


-- event_loop = EventLoop!
-- 
-- host, port = ...
-- irc = Irc host or config.host, port or config.port
-- 
-- for k,v in pairs {:event_loop, :irc, :HTTPRequest}
--   state[k] = v
-- 
-- if config.smf_feed_url
--   smf = require "saltw.misc.smf_scraper"
--   event_loop\add_task smf.make_task!
-- 
-- if config.ipb_feed_url
--   ipb = require "saltw.misc.ipb_scraper"
--   event_loop\add_task ipb.make_task config.forum_channels
-- 
-- event_loop\add_listener irc.reader
-- 
-- if config.stats_url
--   stats2 = require "saltw.misc.stats2"
--   stats = stats2.Stats!
--   event_loop\add_task stats\make_task!
--   irc\add_message_handler stats\make_handler!
-- 
-- -- get the title of a webpage
-- irc\add_message_handler (irc, name, channel, msg) ->
--   if url = msg\match "%f[%a]https?://[^%s]+"
--     HTTPRequest\get url, (body, headers) ->
--       if body
--         title_patt = "[tT][iI][tT][lL][eE]"
--         if title = body\match("<#{title_patt}>(.-)</#{title_patt}>")
--           irc\me {
--             irc\color "grey", "[Title]"
--             " "
--             decode_html_entities(title)
--           }, channel
-- 
-- 
-- if config.admin_password
--   irc\add_message_handler require("saltw.misc.admin").handler
-- 
-- { run: -> event_loop\run! }

{ :Irc }
