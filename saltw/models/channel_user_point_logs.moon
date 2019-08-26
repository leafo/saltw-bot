
db = require "lapis.db"
import enum from require "lapis.db.model"

class ChannelUserPointLogs extends require "saltw.model"
  @timestamp: true

  @relations: {
    {"channel_user", belongs_to: "ChannelUsers"}
  }


