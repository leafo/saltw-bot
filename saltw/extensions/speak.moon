shell_escape = (str) ->
  str\gsub "'", "''"

random_item = (items) ->
  items[math.random 1, #items]

local last_person

voices = {
  "en-us+f4"
  "en-us+f3"
  "en-us+f1"
  "en-us"
  "en-uk"
  "en-uk+f2"

  -- "europe/ga"
  -- "europe/ru"
  -- "europe/is"
  -- "europe/is+f3"
  -- "fr+f4"
  -- "fr"
}

user_cache = {}
get_flags_for_user = (user) ->
  unless user_cache[user]
    voice = random_item voices
    speed = math.random 150, 180
    user_cache[user] = "-v#{voice} -s#{speed}"

  user_cache[user]

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
      "espeak -z #{get_flags_for_user name} -g 4 --stdout '#{shell_escape speak}'"
      "mpv '#{shell_escape port}' -"
    }

    cmd = "(#{table.concat cmd, " | "}) &"
    print cmd
    io.popen cmd
