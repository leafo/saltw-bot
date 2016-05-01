shell_escape = (str) ->
  str\gsub "'", "''"

class Speak extends require  "saltw.extension"
  new: (@irc) =>
    @irc\on "irc.message", @\message_handler

  message_handler: (e, irc, name, channel, message) =>
    -- remove any nasty characters
    speak = ("#{name} says #{message}")\gsub "[^%w ]", " "
    speak = speak\sub 1, 80

    port = "--ao=jack:port=[Gate In #1]"
    port_local = "--ao=jack"

    cmd = {
      "espeak -z -v en-us -g 4 --stdout '#{shell_escape speak}'"
      "mpv '#{shell_escape port}' -"
    }

    cmd = "(#{table.concat cmd, " | "}) &"
    print cmd
    io.popen cmd
