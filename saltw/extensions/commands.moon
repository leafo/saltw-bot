
import bind from require "saltw.util"


MESSAGES = {
  "!today": "I am working on my twitch bot written in MoonScript. Adding twitch api communication"
  "!drink": "Usually iced tea, but sometimes water"
  "!linux": "I use Arch Linux, AwesomeWM, Vim"
  "!language": "I typically code in MoonScript (which compiles to Lua), but also sometimes JavaScript"
  "!editor": "Vim in rxvt-unicode"
  "!itchio": "I founded https://itch.io/ I may work on it during stream sometimes"
  "!moonscript": "MoonScript is a language I made that I use to program most of my projects in https://moonscript.org"
  "!camera": "Nikon D5100 screencaptured PTP with Entangle https://entangle-photo.org/"
  "!adam": "Adam makes Bot Land http://twitch.tv/Adam13531"
  "!keyboard": "ErgoDox EZ with Kailh Speed Switches (Silver) (qwerty)"
  "!lua": "I use it for everything"
  "!faq": "Try here: https://github.com/leafo/streaming-wiki"
  "!github": "https://github.com/leafo"
  "!discord": "My discord: https://discord.gg/Y75ZXrD itch.io discord: https://discord.gg/3Q6qm95"
  "!twitter": "https://twitter.com/moonscript"
}


--  !equip
--  !moonscript
--  !language
--  !faq
--  !linux
--  !beard
--  !burst (!tada)
--  !itch
--  !rules
--  !uptime -- need api for
--  !drink
--  !keyboard


class Commands extends require "saltw.extension"
  new: (@irc) =>
    @irc\on "irc.message", bind @, "message_handler"

  is_admin: (name) =>
    import types from require "tableshape"
    config = require "saltw.config"

    return false unless config.admin_names

    types.one_of(config.admin_names) name

  get_twitch: =>
    unless @twitch
      Twitch = require "saltw.clients.twitch"
      @twitch = Twitch "moonscript"

    @twitch

  make_it_rain: (message) =>
    unless @is_admin message.name
      return

    {:channel} = message

    return unless channel\match "^#"

    twitch = @get_twitch!

    chatters = twitch\get_chatters!
    return unless chatters

    points = 0

    for name in *chatters.viewers
      import ChannelUsers from require "saltw.models"
      cu = ChannelUsers\find {
        :channel
        :name
      }

      if cu
        cu\give_point "!makeitrain", 1
        points += 1

    "bleedPurple bleedPurple It's raining #{points} point(s) SMOrc"

  uptime: =>
    twitch = @get_twitch!
    stream = twitch\get_current_stream!
    unless stream and stream.started_at
      return "Is the stream running?"

    date = require "date"
    sec = date.diff(date(true), date(stream.started_at))\spanseconds!

    import time_ago_in_words from require "lapis.util"
    "Uptime: #{time_ago_in_words stream.started_at, 2, ""}"

  message_handler: (e, irc, message) =>
    msg = switch message.message
      when "!list", "!help", "!commands"
        keys = [key for key in pairs MESSAGES]
        table.sort keys
        keys = table.concat keys, " "
        "Available commands: #{keys}"
      when "!uptime"
        @uptime!
      when "!makeitrain"
        @make_it_rain message
      else
        MESSAGES[message.message]

    if msg and #msg >= 500
      print "\n\n MESSAGE TOO LONG \n\n"
      return

    return unless msg

    irc\message msg

