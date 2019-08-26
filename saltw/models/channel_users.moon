
db = require "lapis.db"
import enum from require "lapis.db.model"

import insert_on_conflict_update from require "saltw.db.helpers"

class ChannelUsers extends require "saltw.model"
  @timestamp: true

  @relations: {
    {"point_logs", has_many: "ChannelUserPointLogs"}
  }

  @log: (channel, user, message) =>
    insert_on_conflict_update @, {
      [{
        column: "name"
        value: db.raw "lower(name)"
      }]: user\lower!

      :channel
    }, {
      messages_count: 1
      random_message: message
      last_seen_at: db.raw "date_trunc('second', now() at time zone 'utc')"
    }, {
      messages_count: db.raw "#{db.escape_identifier ChannelUsers\table_name!}.messages_count + excluded.messages_count"
      random_message: message
      last_seen_at: db.raw "excluded.last_seen_at"
    }

