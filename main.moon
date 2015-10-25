import Irc from require "saltw.irc"
import EventLoop from require "saltw.event_loop"

loop = EventLoop!
irc = Irc loop, require("saltw.config")
loop\run!

