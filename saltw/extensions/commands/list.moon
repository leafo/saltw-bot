
import ChatCommands from require "saltw.models"

-- TODO: add aliases "!help", "!commands"
(irc, message) =>
  commands = ChatCommands\list_commands!
  command_names = ["!#{c.command }" for c in *commands]
  return unless next command_names

  table.sort command_names
  command_names = table.concat command_names, " "

  irc\message "Available commands: #{command_names}"
