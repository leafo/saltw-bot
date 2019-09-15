
import ChatCommands, ChannelUsers from require "saltw.models"

(irc, message) =>
  unless ChatCommands\is_admin message.name
    return

  {:channel} = message

  return unless channel\match "^#"

  twitch = ChatCommands\get_twitch!

  chatters = twitch\get_chatters!
  return unless chatters

  points = 0

  for name in *chatters.viewers
    cu = ChannelUsers\find {
      :channel
      :name
    }

    if cu
      cu\give_point "!makeitrain", 1
      points += 1

  irc\message "bleedPurple bleedPurple It's raining #{points} point(s) SMOrc"
