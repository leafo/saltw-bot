
db = require "lapis.db"
import Model, enum from require "lapis.db.model"

class ChannelUsers extends Model
  @timestamp: true

  @log: (channel, user, message) =>
    res = db.update @table_name!, {
      messages_count: db.raw "messages_count + 1"
      random_message: message
      last_seen_at: db.raw "date_trunc('second', now() at time zone 'utc')"
    }, {
      :channel
      [db.raw "lower(name)"]: user\lower!
    }

    return if res and res.affected_rows > 0

    @create {
      messages_count: 1
      random_message: message
      last_seen_at: db.raw "date_trunc('second', now() at time zone 'utc')"
      :channel
      name: user
    }

