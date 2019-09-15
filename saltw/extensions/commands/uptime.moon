
import ChatCommands from require "saltw.models"

(irc, message) =>
  twitch = ChatCommands\get_twitch!

  stream = twitch\get_current_stream!
  unless stream and stream.started_at
    return "Is the stream running?"

  date = require "date"
  sec = date.diff(date(true), date(stream.started_at))\spanseconds!

  import time_ago_in_words from require "lapis.util"
  irc\message "Uptime: #{time_ago_in_words stream.started_at, 2, ""}"
