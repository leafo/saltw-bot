db = require "lapis.db"
import enum from require "lapis.db.model"

import find_tag from require "saltw.twitch"

import to_json from require "lapis.util"

class ChannelUserMessages extends require "saltw.model"
  @timestamp: true

  @log: (message) =>
    user_id = find_tag message.tags, "user-id"

    @create {
      channel: message.channel
      name: message.name
      message: message.message
      :user_id
      data: db.raw db.escape_literal to_json message.tags
    }

