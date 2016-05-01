shell_escape = (str) ->
  str\gsub "'", "''"

class Midi extends require  "saltw.extension"
  new: (@irc) =>
    @irc\on "irc.message", @\message_handler

  message_handler: (e, irc, name, channel, message) =>
    return unless message == "!tada"
    io.popen "aplaymidi -p 133:0 rimshot.mid"
