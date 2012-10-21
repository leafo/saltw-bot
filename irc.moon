
module "main", package.seeall

require "socket"
require "socket.url"
require "util"
require "misc.smf_scraper"

import insert, remove from table

strip = (str) -> str\match "^(.-)%s*$"

event_loop = nil

config = get_config "config", {
  name: 'bladder_x'
  host: 'irc.esper.net'
  port: 6667

  message_prefix: 'New ', -- used for New reply, New post

  channels: { '#saltw' }

  verbose: true

  feed_url: 'http://www.saltw.net/index.php?action=.xml'
  poll_time: 5.0

  stats_url: "http://leafo.net/saltw/"
  stats_update_tiime: 60*3
}

export ^

-- character buffer
class Buffer
  append: (c) => insert @, c
  tostring: (slice=false) =>
    out = table.concat @
    if slice
      out = out\sub 1, #self - (slice or 0)
    out
  ends_with: (str) =>
    i = #self
    for c in str\reverse!\gmatch"."
      return false if i < 1 or c != @[i]
      i -= 1
    true

-- coroutine based socket reader
class Reader
  new: (@socket, fn=nil) =>
    @socket\settimeout 0 -- nonblocking
    @loop = fn

  get_byte: =>
    while true
      byte, err = @socket\receive 1
      switch err
        when "closed"
          error "socket closed!"
        when "timeout"
          coroutine.yield!
        else
          return byte
  
  get_bytes: (count) =>
    b = Buffer!
    while #b < count
      b\append @get_byte!

    b\tostring!

  get_bytes_until_closed: =>
    b = Buffer!
    while true
      byte, err = @socket\receive 1
      switch err
        when "closed"
          return b\tostring!
        when "timeout"
          coroutine.yield!
        else
          b\append byte

  get_line: =>
    b = Buffer!
    while not b\ends_with "\r\n"
      b\append @get_byte!
    b\tostring 2

  make_coroutine: => coroutine.create self\loop

  loop: =>

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

  log = (...) -> print "+++", ...

  new: (@host, @port) =>
    @message_handlers = {}

    @channels = {}
    @socket = socket.connect @host, @port
    if not @socket
      error "could not connect to server #{@host}:#{@port}"

    @socket\send "NICK #{config.name}\r\n"
    @socket\send "USER ".."moon "\rep(3)..":Bildo Bagins\r\n"

    event_loop\add_task {
      time: 10
      action: ->
        if config.password
          @message_to 'NickServ', 'IDENTIFY '..config.password

        for channel in *config.channels
          @join channel
    }

    irc = @
    @reader = Reader @socket, =>
      while true
        irc\handle_message @get_line!


  add_message_handler: (handler) =>
    insert @message_handlers, handler

  handle_message: (line) =>
    print "IRC:", line if config.verbose

    ping = line\match "^PING :(.*)"
    if ping
      @socket\send "PONG #{ping}\r\n"
      log "PONG"
      return

    name, host, channel, msg = line\match(':([^!]+)!([^%s]+) PRIVMSG (#[%w_]+) :(.*)')
    if name
      for handler in *@message_handlers
        handler @, name, channel, msg, host


  join: (channel) =>
    @socket\send "JOIN #{channel}\r\n"
    insert @channels, channel

  message: (msg, channel=nil) =>
    if channel
      @socket\send "PRIVMSG #{channel} :#{msg}\r\n"
    else
      for channel in *@channels
        @message msg, channel

  message_to: (who, msg) =>
    @socket\send 'PRIVMSG '..who..' :'..msg..'\r\n'

  me: (msg) =>
    msg = table.concat msg if type(msg) == "table"
    delim = string.char 0x01
    self\message table.concat { delim, 'ACTION ', msg, delim }

  color: (color, msg) =>
    delim = string.char 0x03
    table.concat { delim, colors[color] or color, msg, delim }


class HTTPRequest
  method: "GET"

  @post: (url, data, callback) =>
    http = self url, data
    http.method = "POST"
    http.headers["Content-Length"] = #data
    http\send callback

  @get: (url, callback) =>
    http = self url
    http.method = "GET"
    http\send callback
    
  new: (@url, @data=nil) =>
    @headers = {
      "Connection": "close"
    }

  send: (callback) =>
    @url = "http://" .. @url unless @url\match "^http://"
    print "HTTP:", @url
    url = socket.url.parse @url
    if not url.host
      return callback nil, "Malformed url: #{@url}"

    socket = socket.connect url.host, url.port or 80

    if not socket
      return callback nil, "Failed to open connection to #{url.host}"

    path = url.path or "/"
    path ..= "?" .. url.query if url.query

    socket\send "#{@method} #{path} HTTP/1.1\r\n"
    @headers["Host"] = url.host

    for k,v in pairs @headers
      socket\send "#{k}: #{v}\r\n"

    socket\send "\r\n"
    socket\send @data if @data

    event_loop\add_listener Reader socket, =>
      header = {}
      while true
        line = @get_line!
        break if line == ""
        key, value = line\match "([^:]+): (.*)"
        header[key] = value if key

      body = if header['Content-Length']
        @get_bytes tonumber(header['Content-Length'])
      elseif header['Transfer-Encoding'] == "chunked"
        chunks = {}
        while true
          size = tonumber '0x'..@get_line!
          break if size == 0
          table.insert chunks, @get_bytes size
          @get_line! -- get the extra \r\n

        table.concat chunks
      elseif header["Connection"] == "close"
        @get_bytes_until_closed!
      else
        require"moon".p header
        error "Don't know how to read HTTP response"

      callback body, header

class EventLoop
  new: =>
    @listening = {}
    @readers = {}
    @tasks = {}

  -- task = {
  --   name: "The Name"
  --   interval: 4 -- how many seconds between each re-run, nil to run once
  --   time: 10 -- time in seconds until next run
  --   action: -> -- the function
  -- }
  add_task: (task) =>
    table.insert @tasks, task

  add_listener: (reader) =>
    socket = reader.socket
    fn = reader\make_coroutine!

    @readers[socket] = fn
    insert @listening, socket

  remove_listener: (client) =>
    client\close!
    @readers[client] = nil
    @listening = [sock for sock in *@listening when sock != client]

  run: =>
    last_time = socket.gettime!
    while true
      readable, writable, err = socket.select @listening, nil, 1
      if err ~= "timeout"
        for socket in *readable
          co = @readers[socket]
          result = { coroutine.resume co }
          success = remove result, 1
          error unpack result unless success

          if coroutine.status(co) == "dead"
            @remove_listener socket

      -- run the tasks
      time = socket.gettime!
      dt = time - last_time
      last_time = time
      @tasks = for task in *@tasks
        task.time = (task.time or task.interval or 0) - dt
        if task.time < 0
          -- print "Running task:", task.name
          task\action!
          if task.interval
            task.time += task.interval
            task
          else
            nil -- removes it
        else
          task

event_loop = EventLoop!

host, port = ...
irc = Irc host or config.host, port or config.port

event_loop\add_task {
  name: "Scrape forums"
  time: 0
  interval: 5
  action: =>
    return if @running
    @running = true
    @smf = @smf or misc.SMFFeed!

    HTTPRequest\get config.feed_url, (body) ->
      @running = false
      return unless body
      new_posts = @smf\get_new_posts body

      for post in *new_posts
        post_type = 'topic'
        if post.subject\match("^Re: ") then
          post.subject = post.subject\sub 5
          post_type = 'reply in'

        with irc
          \me {
            \color "grey",    config.message_prefix..post_type..' '
            \color "orange",  post.subject
            \color "grey",    " ["..post.board.name.."] by "
            \color "green",   post.poster.name
            \color "grey",    " > "
            post.link
          }
      
}

event_loop\add_listener irc.reader

require "misc.stats2"
stats = misc.stats2.Stats!
event_loop\add_task stats\make_task!
irc\add_message_handler stats\make_handler!

-- get the title of a webpage
irc\add_message_handler (irc, name, channel, msg) ->
  if url = msg\match "^!title (.*)"
    url = strip url
    HTTPRequest\get url, (body, headers) ->
      if body
        irc\message body\match("<title>(.-)</title>"), channel

event_loop\run!

