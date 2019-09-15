
import bind from require "saltw.util"

--  !equip
--  !moonscript
--  !language
--  !faq
--  !linux
--  !beard
--  !burst (!tada)
--  !itch
--  !rules
--  !uptime -- need api for
--  !drink
--  !keyboard


class Commands extends require "saltw.extension"
  new: (@irc) =>
    @irc\on "irc.message", bind @, "message_handler"

  message_handler: (e, irc, message) =>
    import ChatCommands from require "saltw.models"
    command_name = ChatCommands\parse_command message.message
    return unless command_name
    command = ChatCommands\find_command command_name
    return unless command

    command\run_command irc, message

