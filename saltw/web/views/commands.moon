import Widget from require "lapis.html"

import ChatCommands from require "saltw.models"

class Stats extends Widget
  render_secret_toggle: (editing) =>
    div ->
      label ->
        input {
          type: "checkbox"
          name: "secret"
          checked: editing and editing.secret
        }
        text " Secret"

  render_command_name_input: (editing) =>
    label ->
      div class: "label", "Command"
      input {
        type: "text"
        list: "command_names"
        name: "command"
        required: true
        value: editing and editing.command
      }

      command_names = {}
      datalist id: "command_names", ->
        for command in *@chat_commands
          continue if command_names[command.command]
          command_names[command.command] = true
          option value: command.command

  render_simple_command_form: =>
    editing = if @edit_command and @edit_command\is_type_simple!
      @edit_command

    fieldset ->
      legend "create command"

      form method: "post", ->
        input type: "hidden", name: "type", value: "simple"

        @render_command_name_input editing
        @render_secret_toggle editing

        label ->
          div class: "label", "Response"
          textarea {
            style: "width: 100%; max-width: 400px; height: 80px;"
            name: "response"
            required: true
          }, editing and editing.data.response

        div class: "buttons", ->
          button "Submit"

  render_callback_command_form: =>
    editing = if @edit_command and @edit_command\is_type_callback!
      @edit_command

    details {
      open: not not editing
    }, ->
      summary "callbacks commands..."

      fieldset ->
        legend "create callback command"

        form method: "post", ->
          input type: "hidden", name: "type", value: "callback"

          @render_command_name_input editing
          @render_secret_toggle editing

          label ->
            div class: "label", "callback"
            input type: "type", name: "callback", value: editing and editing.data.callback

          div class: "buttons", ->
            button "Submit"

  content: =>
    h1 "Commands"
    if @edit_command
      p ->
        strong ->
          text "Editing "
          text @edit_command.command
          text ". "
          a {
            href: @url_for "commands"
          }, "clear"

    @render_simple_command_form!

    @render_callback_command_form!

    if next @chat_commands
      h2 "Commands"

      element "table", ->
        thead ->
          tr ->
            td "command"
            td "version"
            td "type"
            td "response/callback"
            td "used"
            td "last used"
            td "active"
            td "secret"

        tbody ->
          for command in *@chat_commands
            tr ->
              td ->
                a {
                  href: @url_for("commands", nil, command_id: command.id)
                }, command.command
              td command.version
              td ChatCommands.types\to_name command.type
              td ->
                if command.data.response
                  text command.data.response
                elseif command.data.callback
                  code command.data.callback
                else
                  em style: "opacity: 0.5", "n/a"
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

                    div ->
                      nobr ->
                        input type: "checkbox", name: "confirm"
                        text " "
                        button name: "action", value: "delete", "delete"

              td tostring command.secret


