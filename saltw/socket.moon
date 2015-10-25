import insert from table

{parse: parse_url} = require "socket.url"

socket = require "socket"

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
  new: (sock, fn={}) =>
    @set_socket sock

    if type(fn) == "function"
      @loop = fn
    else
      for k,v in pairs fn
        @[k] = v

  set_socket: (@socket) =>
    @socket\settimeout 0

  get_byte: =>
    while true
      byte, err = @socket\receive 1
      switch err
        when "closed"
          coroutine.yield "closed"
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
  handle_error: (...) => error ...

class HTTPRequest
  method: "GET"

  @post: (url, data, ...) =>
    req = @ "POST", url, data
    req.headers["Content-Length"] = #data
    req\reader ...

  @get: (url, ...) =>
    req = @ "GET", url
    req\reader ...

  new: (@method, @url, @data=nil) =>
    @redirect_count = 0
    @headers = {
      "Connection": "close"
    }

  reader: (callback) =>
    @url = "http://" .. @url unless @url\match "^http://"
    print "HTTP:", @url
    url = parse_url @url
    if not url.host
      return callback nil, "Malformed url: #{@url}"

    sock = socket.connect url.host, tonumber(url.port) or 80

    unless sock
      return callback nil, "Failed to open connection to #{url.host}"

    path = url.path or "/"
    path ..= "?" .. url.query if url.query

    sock\send "#{@method} #{path} HTTP/1.1\r\n"
    @headers["Host"] = url.host

    for k,v in pairs @headers
      sock\send "#{k}: #{v}\r\n"

    sock\send "\r\n"
    sock\send @data if @data

    req = @
    Reader sock, =>
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
      elseif header["Connection"]\lower! == "close"
        @get_bytes_until_closed!
      else
        for k,v in pairs header
          print "*", k, v
        print "Don't know how to read HTTP response"
        ""

      if redirect_to = header["Location"]
        return if req.redirect_count > 5
        r = HTTPRequest redirect_to, req.data
        r.method = req.method
        r.headers = { k,v for k,v in pairs req.headers when k != "host" }
        r.redirect_count = req.redirect_count + 1
        r\send callback
      else
        callback body, header
      nil

{ :Reader, :Buffer, :HTTPRequest }
