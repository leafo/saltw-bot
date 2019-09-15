
db = require "lapis.db"
import enum from require "lapis.db.model"
import insert_on_conflict_update from require "saltw.db.helpers"

import to_json from require "lapis.util"

class ChatCommands extends require "saltw.model"
  @timestamp: true

  @types: enum {
    simple: 1
    callback: 2
  }

  @create: (opts) =>
    opts.type = @types\for_db opts.type or "simple"

    opts.version = db.raw db.interpolate_query "
      coalesce(
        (select max(version) from chat_commands where command = ?) + 1,
        1)
    ", opts.command

    opts.data = if type(opts.data) == "table"
      to_json opts.data

    super opts


