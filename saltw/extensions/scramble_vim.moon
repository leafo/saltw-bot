shell_escape = (str) ->
  str\gsub "'", "''"

random_item = (items) ->
  items[math.random 1, #items]

class Speak extends require  "saltw.extension"
  new: (@irc) =>
    @irc\on "irc.message", @\message_handler

  message_handler: (e, irc, name, channel, message) =>
    return unless message == "!vim"

    fonts = {
      "Perfect DOS VGA 437 16"
      "Terminus 17"
      "Source Code Pro 13"
      "Roboto Mono 16"
    }

    colors = {
      "eddie"
      "elflord"
      "wombat"
      "moon"
      "zellner"
    }

    font = random_item fonts
    color = random_item colors
    font = font\gsub " ", "\\ "

    command = ":set guifont=\"#{font}\"<CR>:colorscheme \"#{color}\"<CR>"
    print "gvim --remote-send '#{shell_escape command}'"


