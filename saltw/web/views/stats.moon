
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
            div ->
              a href: "https://twitch.tv/#{user.name}", user.name
            details ->
              summary "Give Points"

              form {
                action: @url_for user
                method: "POST"
              }, ->
                input type: "hidden", name: "csrf_token", value: @csrf_token
                label ->
                  div "Reason"
                  input type: "text", name: "reason"

                label ->
                  div "Amount"
                  input type: "number", name: "amount", value: 1

                button "Submit"

          td user.messages_count
          td user.points_count
          td user.last_seen_at
          td user.random_message
