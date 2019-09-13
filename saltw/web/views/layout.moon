html = require "lapis.html"

class Layout extends html.Widget
  content: =>
    html_5 ->
      head ->
        title @title or "saltw-bot"
        meta charset: "utf-8"
        style type: "text/css", [[
          body {
            font-family: sans-serif;
          }
        ]]

      body ->
        @content_for "inner"
