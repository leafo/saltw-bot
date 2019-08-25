shell_escape = (str) ->
  str\gsub "'", "''"

random_item = (items) ->
  items[math.random 1, #items]

class Speak extends require  "saltw.extension"
  new: (@irc) =>
    @irc\on "irc.message", @\message_handler


  message_handler: (e, irc, message) =>
    {:name, :channel, :message} = message

    return unless message == "!vim"

    fonts = {
      "Perfect DOS VGA 437 16"
      "Terminus 17"
      "Source Code Pro 13"
      "Roboto Mono 16"
      "C64 Pro Mono 13"
    }

    colors = {
      "eddie"
      "elflord"
      "wombat"
      "blue_mod"
      "zellner"
    }

    font = random_item fonts
    color = random_item colors
    font = font\gsub " ", "\\ "

    command = "<ESC>:set guifont=#{font}<CR>:colorscheme #{color}<CR>"
    io.popen "gvim --remote-send '#{shell_escape command}'"
