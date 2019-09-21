import Irc from require "saltw.irc"

cqueues = require "cqueues"
loop = assert cqueues.new!

loop\wrap ->
  package.loaded["saltw.irc.current"] = Irc loop, require("saltw.config")

loop\wrap ->
  import start_server from require "lapis.cmd.cqueues"
  start_server "saltw.web.app"

loop\wrap ->
  HotLoader = require "saltw.hot_loader"
  loader = HotLoader!
  loader\start!


if love
  time = 0
  Game = require "saltw.game"
  game = Game!

  love.load = ->
    game\load!

  love.update = (dt) ->
    assert loop\loop 0
    game\update dt

  love.draw = (dt) ->
    game\draw!

else
  assert loop\loop!

