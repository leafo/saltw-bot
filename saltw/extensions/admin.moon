
format_list = (items) ->
  copy = { k,v for k,v in pairs items }
  table.sort(copy)
  table.concat copy, ", "

class Admin extends require "saltw.extension"
  @actions: {
    mute: (sender, username) =>
      ipb = require "saltw.misc.ipb_scraper"
      ipb.options.muted_names[username] = true
      @irc\message "muted #{username}", sender

    speak: (sender, channel, ...) =>
      unless channel and channel\match "^#"
        @irc\message "usage: speak #channel the message", sender
        return

      @irc\message table.concat({...}, " "), channel

    list_mute: (sender) =>
      error "FIXME"
      ipb = require "saltw.misc.ipb_scraper"
      names = format_list [k for k in pairs ipb.options.muted_names]
      @irc\message "Muted: #{names}", sender

    list_post_chain: (sender) =>
      error "FIXME"
      ipb = require "saltw.misc.ipb_scraper"
      names = format_list ipb.options.post_chain
      @irc\message "Post chain: #{names}", sender

    help: (sender) =>
      action_names = format_list [k for k in pairs @@actions]
      @irc\message "Actions: #{action_names}", sender
  }

  new: (@irc) =>
    return unless @irc.config.admin_password
    @irc\on "irc.message", @\message_handler

  message_handler: (e, irc, name, channel, message) =>
    return if channel\match "^#"

    args = [ tok for tok in  message\gmatch "%S+" ]
    return unless args[1] == @irc.config.admin_password
    table.remove args, 1

    cmd = args[1]

    if action = @@actions[cmd]
      table.remove args, 1
      action @, name, unpack args
