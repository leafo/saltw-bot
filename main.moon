import Irc from require "saltw.irc"

cqueues = require "cqueues"
loop = assert cqueues.new!

loop\wrap ->
  Irc loop, require("saltw.config")

loop\wrap ->
  import start_server from require "lapis.cmd.cqueues"
  App = require "saltw.web.app"
  start_server App

assert loop\loop!

