import Widget from require "lapis.html"

class ChannelUser extends Widget
  content: =>
    style type: "text/css", [[
      body {
        font-family: sans-serif;
      }
    ]]

    h1 @channel_user.name

    element "table", border: 1, ->
      thead ->
        tr ->
          td "Reason"
          td "Amount"

      tbody ->
        for log in *@channel_user\get_point_logs!
          tr ->
            td log.reason
            td log.amount


