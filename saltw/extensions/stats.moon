import ChannelUsers from require "saltw.models"

class Stats extends require  "saltw.extension"
  new: (@irc) =>
    @irc\on "irc.message", @\message_handler

  message_handler: (e, irc, name, channel, message) =>
    return unless channel\match "^#"

    irc.cqueues\wrap ->
      ChannelUsers\log channel, name, message

