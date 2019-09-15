
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

  @callback_commands: {
    -- TODO: add aliases "!help", "!commands"
    list: (irc, message) =>
      commands = @@list_commands!
      command_names = [c.command for c in *commands]
      return unless next command_names

      table.sort command_names
      command_names = table.concat command_names, " "

      irc\message "Available commands: #{command_names}"

    uptime: (irc, message) =>
      twitch = @@get_twitch!

      stream = twitch\get_current_stream!
      unless stream and stream.started_at
        return "Is the stream running?"

      date = require "date"
      sec = date.diff(date(true), date(stream.started_at))\spanseconds!

      import time_ago_in_words from require "lapis.util"
      irc\message "Uptime: #{time_ago_in_words stream.started_at, 2, ""}"

    makeitrain: (irc, message) =>
      unless @@is_admin message.name
        return

      {:channel} = message

      return unless channel\match "^#"

      twitch = @@get_twitch!

      chatters = twitch\get_chatters!
      return unless chatters

      points = 0

      for name in *chatters.viewers
        import ChannelUsers from require "saltw.models"
        cu = ChannelUsers\find {
          :channel
          :name
        }

        if cu
          cu\give_point "!makeitrain", 1
          points += 1

      irc\message "bleedPurple bleedPurple It's raining #{points} point(s) SMOrc"
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
        fn = @@callback_commands[@command]
        if fn
          fn @, irc, message
        else
          print "WARNING: callback command doesn't exist: #{@command}"
      else
        error "unknown type: #{@type}"

  is_type_simple: =>
    @type == @@types.simple

  is_type_callback: =>
    @type == @@types.callback
