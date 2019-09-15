import Widget from require "lapis.html"

import ChatCommands from require "saltw.models"

class Stats extends Widget
  content: =>
    h1 "Commands"

    fieldset ->
      legend "create/update command"
      form method: "post", ->
        label ->
          div class: "label", "Command"
          input type: "text", name: "command", required: true

        label ->
          div class: "label", "Response"
          input type: "text", name: "response", required: true

        div class: "buttons", ->
          button "Submit"

    if next @chat_commands
      h2 "Commands"

      element "table", ->
        thead ->
          tr ->
            td "command"
            td "version"
            td "type"
            td "response"
            td "used_count"
            td "last_used_at"
            td "active"

        tbody ->
          for command in *@chat_commands
            tr ->
              td command.command
              td command.version
              td ChatCommands.types\to_name command.type
              td command.data.response
              td command.used_count
              td command.last_used_at
              td tostring command.active





