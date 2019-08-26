
import Widget from require "lapis.html"

class Stats extends Widget
  content: =>
    style type: "text/css", [[
      body {
        font-family: sans-serif;
      }
    ]]

    h1 "Stats"

    element "table", border: 1, ->
      thead ->
        tr ->
          td "Name"
          td "Message count"
          td "Points"
          td "Last seen"
          td "Random message"

      for user in *@users
        tr ->
          td ->
            a href: "https://twitch.tv/#{user.name}", user.name

          td user.messages_count
          td user.points_count
          td user.last_seen_at
          td user.random_message
