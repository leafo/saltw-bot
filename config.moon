config = require "lapis.config"

config "test", ->
  postgres {
    database: "saltw_test"
  }

config "twitch", ->
  host "irc.chat.twitch.tv"
  port "6667"
  name "bladder_x"
  channels { "#moonscript" }
  oauth_token require "pass"
  twitch true

  postgres {
    database: "twitch_bot"
    socket_type: "cqueues"
  }

  extensions {
    -- "speak"
    -- "scramble_vim"
    -- "midi"
    "stats"
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


