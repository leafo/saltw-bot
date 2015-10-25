config = require "lapis.config"

config "development", ->
  join_delay 2
  forum_channels { "#saltw" }
  host "localhost"
  name "bladder_x"

