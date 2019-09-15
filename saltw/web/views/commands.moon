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
          input type: "text", list: "command_names", name: "command", required: true

          command_names = {}
          datalist id: "command_names", ->
            for command in *@chat_commands
              continue if command_names[command.command]
              command_names[command.command] = true
              option value: command.command

        label ->
          div class: "label", "Response"
          textarea {
            style: "width: 100%; max-width: 400px; height: 80px;"
            name: "response"
            required: true
          }

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
            td "used"
            td "last used"
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
              td ->
                details ->
                  summary tostring command.active
                  form {
                    method: "post"
                    action: @url_for "command", {
                      command_id: command.id
                    }
                  }, ->
                    if command.active
                      button name: "action", value: "disable", "Disable"
                    else
                      button name: "action", value: "enable", "Enable"



