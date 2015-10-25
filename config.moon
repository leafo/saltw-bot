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

  admin_password "admin"

  extensions {
    "url_titles"
    "admin"
  }

  postgres {
    database: "saltw"
  }

