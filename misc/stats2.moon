
-- this queues the stats, then sends them off somewhere else

module "misc.stats2", package.seeall


date = require "date"
json = require "cjson"
config = require "config"
state = require "state"

import insert from table

export ^

class MemoryStats
  new: => @messages = {}

  format_date: (d=date(true)) => d\fmt "${iso}"
  handle_message: (name, msg) => insert @messages, { :name, :msg, time: @format_date! }
  get_messages: => @messages
  clear_queue: => @messages = {}

if false
  import Datastore from require "misc.sqlite"
  class SqliteStats extends Datastore
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

    get_messages: =>
      [r for r in @db\nrows "select * from messages"]

    clear_queue: =>
      @exec [[ drop table messages ]]
      @create_db!

    print_queue: =>
      require "moon"
      print "queue:"
      for t in @db\nrows "select * from messages order by time desc"
        moon.p t


class Stats extends MemoryStats
  make_handler: =>
    (irc, name, channel, msg, host) ->
      return unless channel\match "^#" -- don't count user PRIVMSG
      return unless channel == "#saltw" -- TODO: WOOPS

      if msg == "!stats"
        @send_messages (count) ->
          irc\message "#{config.stats_public_url} (sent #{count})", channel
      else
        @handle_message name, msg

  send_messages: (callback) =>
    {:HTTPRequest} = state

    messages = @get_messages!
    if #messages == 0
      callback 0 if callback
      return

    print "Sending #{#messages} messages to #{config.stats_url}"

    dump = json.encode messages
    HTTPRequest\post config.stats_url, dump, (res, headers) ->
      if res == "ok"
        @clear_queue!
        callback #messages if callback
      else
        print "Stats server responded:", res


  make_task: =>
    @task = {
      name: "Publish stats"
      time: 10
      interval: config.stats_update_time
      action: -> @send_messages!
    }
    @task


-- data = Stats!
-- data\handle_message "leafo", "the test.. " .. math.random!
-- data\handle_message "leafo", "another test..." .. math.random!
-- data\print_queue!

