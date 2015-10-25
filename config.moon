config = require "lapis.config"

config "test", ->
  postgres {
    database: "saltw_test"
  }

config "development", ->
  join_delay 2
  channels { "#leafo" }

  ipb {
    url: "http://saltworld.net/forums/?app=forums&module=extras&section=newpoststream"
    channels: { "#leafo" }
  }

  host "localhost"
  name "bladder_x"

  admin_password "admin"

  extensions {
    "url_titles"
    "admin"
    "ipb_forum"
    "stats"
  }

  postgres {
    database: "saltw"
  }

