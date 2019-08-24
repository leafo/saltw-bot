import Irc from require "saltw.irc"

cqueues = require "cqueues"
loop = assert cqueues.new!

loop\wrap ->
  Irc loop, require("saltw.config")

assert loop\loop!



