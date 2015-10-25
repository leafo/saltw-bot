
import decode_html_entities from require "lapis"

-- get the title of a youtube url
make_handler = ->
  (irc, name, channel, msg) ->
    -- 'http://youtu.be/nJjJ_8CgzDY' -- short url
    url = if id = msg\match "youtu%.be/([%w_-]+)"
      "www.youtube.com/watch?v=#{id}"

    url = unless url
      msg\match "www%.youtube%.com/watch%?v=[%w_-]+"

    if url
      HTTPRequest\get url, (body, headers) ->
        if body
          title = body\match("<title>(.-)</title>")
          if match = title\match "^(.-) %- YouTube$"
            title = match

          title = decode_html_entities title

          with irc
            \me {
              \color "grey", "[YouTube] "
              title
            }, channel

{ :make_handler }
