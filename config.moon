config = require "lapis.config"

config "test", ->
  postgres {
    database: "saltw_test"
  }

config "development", ->
  join_delay 2
  channels { "#leafo" }

  host "localhost"
  name "bladder_x"

  extensions {
    "url_titles"
  }

  postgres {
    database: "saltw"
  }

