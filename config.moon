config = require "lapis.config"

config "test", ->
  postgres {
    database: "saltw_test"
  }

config "development", ->
  join_delay 2
  forum_channels { "#saltw" }
  host "localhost"
  name "bladder_x"

  postgres {
    database: "saltw"
  }

