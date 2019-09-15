
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

  @list_commands: =>
    ChatCommands\select "
      where (command, version) in (
        select command, max from (select command, max(version) from #{db.escape_identifier @table_name!} group by 1) foo
      )
      and active
    "

  @find_command: (name) =>
    command = @select "where command = ? order by version desc limit 1", name
    return nil, "no command" unless command
    return nil, "command not active" unless command.active

    command

  @create: (opts) =>
    opts.type = @types\for_db opts.type or "simple"

    opts.version = db.raw db.interpolate_query "
      coalesce(
        (select max(version) from #{db.escape_identifier @table_name!} where command = ?) + 1,
        1)
    ", opts.command

    opts.data = if type(opts.data) == "table"
      to_json opts.data

    super opts


