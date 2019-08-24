config = require "lapis.config"

config "test", ->
  postgres {
    database: "saltw_test"
  }

config "twitch", ->
  host "irc.chat.twitch.tv"
  prot "6667"
  name "bladder_x"
  channels { "#moonscript" }
  oauth_token require "pass"
  twitch true

  extensions {
    -- "speak"
    -- "scramble_vim"
    -- "midi"
    "today"
  }


config "development", ->
  join_delay 2

  host "localhost"
  name "bladder_x"

  channels { "#leafo" }

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

  systemd {
    user: true
  }


