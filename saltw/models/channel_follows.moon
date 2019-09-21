
db = require "lapis.db"
import enum from require "lapis.db.model"

import insert_on_conflict_update from require "saltw.db.helpers"

date = require "date"

class ChannelFollows extends require "saltw.model"
  @timestamp: true

  @types: enum {
    follow: 1
    subscribe: 2
  }

  @create: (opts) =>
    opts.type = @types\for_db opts.type

    insert_on_conflict_update @, {
      channel: assert opts.channel
      user_id: assert opts.user_id
      type: opts.type
    }, {
      created_at: opts.followed_at
      followed_at: opts.followed_at
    }, {
      followed_at: opts.followed_at
    }, {
      return_inserted: true
    }
 
  just_followed: (threshold=60*14) =>
    original_follow_date = date @created_at
    follow_age = date.diff(date(true), original_follow_date)\spanseconds!
    follow_age < threshold


