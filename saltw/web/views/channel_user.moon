import Widget from require "lapis.html"

class ChannelUser extends Widget
  content: =>
    h1 @channel_user.name

    p ->
      a href: @url_for("stats"), "Back to stats"

    element "table", border: 1, ->
      thead ->
        tr ->
          td "Reason"
          td "Amount"
          td "When"

      tbody ->
        for log in *@channel_user\get_point_logs!
          tr ->
            td log.reason
            td log.amount
            td log.created_at


