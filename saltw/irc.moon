
socket = require "cqueues.socket"

{parse: parse_url} = require "socket.url"

import decode_html_entities from require "saltw.util"
import insert from table

import Reader from require "saltw.socket"
import Dispatch from require "saltw.dispatch"

log = (...) -> print "+++", ...

class Irc
  extension_prefix: "saltw.extensions."

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

  new: (@cqueues, @config) =>
    host = assert @config.host, "config missing host"
    @host, @port = host\match "^(.-):(%d*)$"

    @host or= @config.host
    @port or= 6667

    @dispatch = Dispatch!

    @extensions = for e in *@config.extensions or {}
      require("#{@extension_prefix}#{e}") @

    @dispatch\trigger "irc.before_connect", @

    @connect!

    @cqueues\wrap ->
      -- TODO: add a way to stop looping when client is closed
      -- TODO: figure out how to handle errors
      for ln in @socket\lines!
        @handle_message ln

  connect: =>
    @channels = {}
    socket = socket.connect @host, @port
    @socket = socket

    unless @socket
      error "could not connect to server #{@host}:#{@port}"

    pcall ->
      oauth_token = require("pass")!
      @socket\write "PASS #{oauth_token}\n\n"

    @socket\write "NICK #{@config.name}\r\n"
    @socket\write "USER ".."moon "\rep(3)..":Bildo Bagins\r\n"

    if @config.twitch
      @socket\write "CAP REQ :twitch.tv/membership\r\n"
      @socket\write "CAP REQ :twitch.tv/tags\r\n"

    @dispatch\trigger "irc.connect", @

    if @config.password
      @message_to "NickServ", "IDENTIFY #{@config.password}"

    for channel in *@config.channels
      @join channel

  on: (event, handler) =>
    @dispatch\on event, handler

  handle_message: (line) =>
    print "IRC:", line if @config.verbose

    ping = line\match "^PING :(.*)"
    if ping
      @socket\write "PONG #{ping}\r\n"
      log "PONG"
      return

    name, host, channel, msg = line\match(':([^!]+)!([^%s]+) PRIVMSG (#?[%w_]+) :(.*)')
    if name
      @dispatch\trigger "irc.message", @, name, channel, msg, host

  join: (channel) =>
    @socket\write "JOIN #{channel}\r\n"
    insert @channels, channel
    @dispatch\trigger "irc.join", @, channel

  message: (msg, channel=@channels) =>
    if type(channel) == "table"
      for c in *channel
        @message msg, c
    else
      -- on channel
      @socket\write "PRIVMSG #{channel} :#{msg}\r\n"

  message_to: (who, msg) =>
    @socket\write 'PRIVMSG '..who..' :'..msg..'\r\n'

  me: (msg, channel=nil) =>
    msg = table.concat msg if type(msg) == "table"
    delim = string.char 0x01
    @message table.concat({ delim, 'ACTION ', msg, delim }), channel

  color: (color, msg) =>
    delim = string.char 0x03
    table.concat { delim, colors[color] or color, msg, delim }
-- 
-- if config.stats_url
--   stats2 = require "saltw.misc.stats2"
--   stats = stats2.Stats!
--   event_loop\add_task stats\make_task!
--   irc\add_message_handler stats\make_handler!
-- 


{ :Irc }
