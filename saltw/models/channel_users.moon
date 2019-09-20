
db = require "lapis.db"
import enum from require "lapis.db.model"

import insert_on_conflict_update from require "saltw.db.helpers"

class ChannelUsers extends require "saltw.model"
  @timestamp: true

  @relations: {
    {"point_logs",
      has_many: "ChannelUserPointLogs"
      order: "created_at desc"
    }
  }

  @log: (channel, user, message) =>
    table_name = db.escape_identifier ChannelUsers\table_name!

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
      messages_count: db.raw "#{table_name}.messages_count + excluded.messages_count"
      random_message: db.raw "(
        case
          when random() < greatest(0.01, 1.0 / (#{table_name}.messages_count + 1)) then excluded.random_message
          else #{table_name}.random_message
        end
      )"
      last_seen_at: db.raw "excluded.last_seen_at"
    }

  url_params: (req) =>
    "channel_user", channel_user_id: @id

  give_point: (reason, amount=1) =>
    import ChannelUserPointLogs from require "saltw.models"
    log = ChannelUserPointLogs\create {
      channel_user_id: @id
      :reason
      :amount
    }

    if log
      @update {
        points_count: db.raw db.interpolate_query "points_count + ?", log.amount
      }

    log






