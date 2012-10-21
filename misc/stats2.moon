
-- this queues the stats, then sends them off somewhere else

import Datastore from require "misc.sqlite"

module "misc.stats2", package.seeall
require "moon"

json = require "cjson"
config = require "config"

export ^

class Stats extends Datastore
  db_name: "saltw_queue.db"

  create_db: =>
    @exec [[
      CREATE TABLE IF NOT EXISTS messages (
        name TEXT, time DATETIME, msg INTEGER
      )
    ]]

  handle_message: (name, msg) =>
    @stm [[
      INSERT INTO messages (name, time, msg)
      VALUES (?, ?, ?)
    ]], name, @format_date!, msg

  purge_messages: =>

  print_queue: =>
    require "moon"
    print "queue:"
    for t in @db\nrows "select * from messages order by time desc"
      moon.p t

  make_handler: =>
    (irc, name, channel, msg, host) ->
      @handle_message name, msg

  make_task: =>
    import HTTPRequest from require "main"
    {
      name: "Publish stats"
      time: 10
      interval: config.stats_update_time
      action: ->
        messages = [r for r in @db\nrows "select * from messages"]
        return if #messages == 0
        print "Sending #{#messages} messages to #{config.stats_url}"

        dump = json.encode [r for r in @db\nrows "select * from messages"]
        HTTPRequest\post config.stats_url, dump, (res, headers) ->
          if res == "ok"
            @exec [[ drop table messages ]]
            @create_db!
          else
            print "Stats server responded:", res
    }


-- data = Stats!
-- data\handle_message "leafo", "the test.. " .. math.random!
-- data\handle_message "leafo", "another test..." .. math.random!
-- data\print_queue!

