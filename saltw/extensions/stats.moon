import ChannelUsers, ChannelUserMessages from require "saltw.models"

import bind from require "saltw.util"

class Stats extends require "saltw.extension"
  new: (@irc) =>
    @irc\on "irc.message", bind @, "message_handler"

  message_handler: (e, irc, message) =>
    {:name, :channel} = message

    return unless channel\match "^#"
    ChannelUsers\log channel, name, message.message

    log = ChannelUserMessages\log message

    if amount = log\get_tag "bits"
      @irc\message "Thank for bit×#{amount} #{message.name}"

