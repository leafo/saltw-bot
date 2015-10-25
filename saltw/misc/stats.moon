
-- this stores the stats locally
import Datastore from require "misc.sqlite"

class Stats extends Datastore
  db_name: "saltw.db"

  create_db: =>
    @exec [[
      CREATE TABLE IF NOT EXISTS users (
        name TEXT PRIMARY KEY,
        last_seen DATETIME,
        message_count INTEGER,
        random_message TEXT
      )
    ]]

    @exec [[
      CREATE INDEX IF NOT EXISTS message_count_index ON users (message_count DESC)
    ]]

    @exec [[
      CREATE TABLE IF NOT EXISTS user_messages (
        time DATETIME,
        name TEXT,
        PRIMARY KEY (time, name)
      )
    ]]

  handle_message: (name, msg) =>
    count = @select_one "message_count FROM users WHERE name = ?", name
    print "count:", count
    if count == nil -- brand new
      @stm [[
        INSERT INTO users
          (name, message_count, random_message, last_seen)
        VALUES (?, 1, ?, ?)
      ]], name, msg, @format_date!
    else
      @stm [[
        UPDATE users
        SET message_count = message_count + 1, last_seen = ?
        WHERE name = ?
      ]], @format_date!, name

      if math.random! < 1/count
        print "!updating random message!"
        @stm [[
          UPDATE users SET random_message = ?  WHERE name = ?
        ]], msg, name

  print_stats: =>
    print "stats:"
    for t in @db\nrows "select * from users order by message_count desc"
      require("moon").p t

data = Stats!
data\handle_message "leafo", "What the heck is this about? " .. math.random!
data\print_stats!


