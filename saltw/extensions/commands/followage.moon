
import ChatCommands from require "saltw.models"

date = require "date"

import find_tag from require "saltw.twitch"

(irc, message) =>
  twitch = ChatCommands\get_twitch!

  user_id = find_tag message.tags, "user-id"
  name = find_tag message.tags, "display-name"

  return unless user_id

  res = twitch\get_user_follows {
    to_id: "60887114"
    from_id: user_id
  }

  follow = res and res.data and res.data[1]
  if follow
    import time_ago_in_words from require "lapis.util"
    irc\message "#{name} has followed for #{time_ago_in_words follow.followed_at, 2, ""}"
  else
    irc\message "#{name} doesn't follow MoonScript yet!"



