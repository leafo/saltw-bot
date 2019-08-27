
import bind from require "saltw.util"

MESSAGES = {
  "!today": "I am working on my twitch bot written in MoonScript. Adding class hotreloading for development. yes it still works #{os.time!}"
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


class Today extends require "saltw.extension"
  new: (@irc) =>
    @irc\on "irc.message", bind @, "message_handler"

  message_handler: (e, irc, message) =>
    msg = switch message.message
      when "!list", "!help", "!commands"
        keys = [key for key in pairs MESSAGES]
        table.sort keys
        keys = table.concat keys, " "
        "Available commands: #{keys}"
      else
        MESSAGES[message.message]

    if msg and #msg >= 500
      print "\n\n MESSAGE TOO LONG \n\n"
      return

    return unless msg

    irc\message msg

