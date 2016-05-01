shell_escape = (str) ->
  str\gsub "'", "''"

local last_person

class Speak extends require  "saltw.extension"
  new: (@irc) =>
    @irc\on "irc.message", @\message_handler

  message_handler: (e, irc, name, channel, message) =>
    return if message\match "^!"

    if last_person != name
      message = "#{name} says #{message}"
      last_person = name

    -- remove any nasty characters
    speak = message\gsub "[^%w ]", " "
    speak = speak\sub 1, 100

    port = "--ao=jack:port=[Gate In #1]"
    port_local = "--ao=jack"

    cmd = {
      "espeak -z -v en-us -g 4 --stdout '#{shell_escape speak}'"
      "mpv '#{shell_escape port}' -"
    }

    cmd = "(#{table.concat cmd, " | "}) &"
    io.popen cmd
