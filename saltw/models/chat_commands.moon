
db = require "lapis.db"
import enum from require "lapis.db.model"
import insert_on_conflict_update from require "saltw.db.helpers"

import types from require "tableshape"

import to_json from require "lapis.util"
class ChatCommands extends require "saltw.model"
  @timestamp: true

  @types: enum {
    simple: 1
    callback: 2
    -- alias: 3
  }

  @type_data_shapes: {
    simple: types.shape {
      response: types.string
    }

    callback: types.shape {
      callback: types.string
    }
  }

  @parse_command: (msg) =>
    command = msg\match "^!([^%s]+)"
    if command
      command\lower!

  -- lists active, non-secret commands (fetching latest version)
  @list_commands: =>
    ChatCommands\select "
      where (command, version) in (
        select command, max from (select command, max(version) from #{db.escape_identifier @table_name!} group by 1) foo
      )
      and active and not secret
    "

  @find_command: (name) =>
    command = unpack @select "where command = ? order by version desc limit 1", name
    return nil, "no command" unless command
    return nil, "command not active" unless command.active

    command

  @get_twitch: =>
    unless @twitch
      Twitch = require "saltw.clients.twitch"
      @twitch = Twitch "moonscript"

    @twitch

  @is_admin: (name) =>
    import types from require "tableshape"
    config = require "saltw.config"

    return false unless config.admin_names

    types.one_of(config.admin_names) name

  @create: (opts) =>
    opts.command = opts.command\lower!
    opts.command = opts.command\gsub "^!+", ""

    opts.type = @types\for_db opts.type or "simple"

    opts.version = db.raw db.interpolate_query "
      coalesce(
        (select max(version) from #{db.escape_identifier @table_name!} where command = ?) + 1,
        1)
    ", opts.command

    if data_shape = @type_data_shapes[@types\to_name opts.type]
      assert data_shape opts.data

    opts.data = if type(opts.data) == "table"
      to_json opts.data

    super opts

  run_command: (irc, message) =>
    @update {
      used_count: db.raw "used_count + 1"
      last_used_at: db.raw "date_trunc('second', now() at time zone 'utc')"
    }, timestamp: false

    switch @type
      when @@types.simple
        response = assert @data.response, "missing response for simple command"
        irc\message response
      when @@types.callback
        success, fn = pcall ->
          require "saltw.extensions.commands.#{@command}"

        if success
          fn @, irc, message
        else
          print "WARNING: callback command doesn't exist: #{@command}"
      else
        error "unknown type: #{@type}"

  is_type_simple: =>
    @type == @@types.simple

  is_type_callback: =>
    @type == @@types.callback
