
format_list = (items) ->
  copy = { k,v for k,v in pairs items }
  table.sort(copy)
  table.concat copy, ", "

local actions
actions = {
  mute: (irc, sender, username) ->
    ipb = require "misc.ipb_scraper"
    ipb.options.muted_names[username] = true
    irc\message "muted #{username}", sender

  speak: (irc, sender, channel, ...) ->
    irc\message table.concat({...}, " "), channel

  list_mute: (irc, sender) ->
    ipb = require "misc.ipb_scraper"
    names = format_list [k for k in pairs ipb.options.muted_names]
    irc\message "Muted: #{names}", sender

  list_post_chain: (irc, sender) ->
    ipb = require "misc.ipb_scraper"
    names = format_list ipb.options.post_chain
    irc\message "Post chain: #{names}", sender

  help: (irc, sender) ->
    action_names = format_list [k for k in pairs actions]
    irc\message "Actions: #{action_names}", sender
}

handler = (irc, name, channel, message) ->
  config = require "config"

  return if channel\match "^#"
  return unless config.admin_password

  args = [ tok for tok in  message\gmatch "%S+" ]
  return unless args[1] == config.admin_password
  table.remove args, 1

  cmd = args[1]

  if action = actions[cmd]
    table.remove args, 1
    action irc, name, unpack args

{ :handler }


