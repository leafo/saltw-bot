import Irc from require "saltw.irc"

cqueues = require "cqueues"
loop = assert cqueues.new!

loop\wrap ->
  Irc loop, require("saltw.config")

loop\wrap ->
  import start_server from require "lapis.cmd.cqueues"
  start_server "saltw.web.app"

loop\wrap ->
  HotLoader = require "saltw.hot_loader"
  loader = HotLoader!
  loader\start!

assert loop\loop!

