import Irc from require "saltw.irc"

cqueues = require "cqueues"
loop = assert cqueues.new!

loop\wrap ->
  Irc loop, require("saltw.config")

import Widget from require "lapis.html"

class Stats extends Widget
  content: =>
    html ->
      head ->
        style type: "text/css", [[
          body {
            font-family: sans-serif;
          }
        ]]

      body ->
        h1 "Stats"

        element "table", border: 1, ->
          thead ->
            tr ->
              td "Name"
              td "Message count"
              td "Last seen"
              td "Random message"

          for user in *@users
            tr ->
              td ->
                a href: "https://twitch.tv/#{user.name}", user.name

              td user.messages_count
              td user.last_seen_at
              td user.random_message

loop\wrap ->
  http_server = require "http.server"
  http_headers = require "http.headers"

  server = assert http_server.listen {
    host: "localhost"
    port: 8081
    onstream: (server, stream) ->
      req_headers = stream\get_headers!
      -- body = stream\get_body_as_string!

      headers = http_headers.new!
      headers\append ":status", "200"
      headers\append "content-type", "text/html; charset=utf-8"

      stream\write_headers headers, false

      import ChannelUsers from require "saltw.models"

      stream\write_body_from_string Stats({
        users: ChannelUsers\select "where channel = '#moonscript' order by messages_count desc limit 100"
      })\render_to_string!
  }

  assert server\listen!
  assert server\loop!

assert loop\loop!



