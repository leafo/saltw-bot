
require "lsqlite3"
require "date"
math.randomseed os.time!

module "misc.sqlite", package.seeall

export ^

class Datastore
  db_name: "store.db"

  format_date: (d=date(true)) => d\fmt "${iso}"

  new: (@db_name) =>
    @db = sqlite3.open @db_name
    @create_db!

  exec: (query) =>
    if 1 == @db\exec query
      error "sqlite execute: " .. @db\errmsg!

  prepare: (query) =>
    stm = @db\prepare query
    error "sqlite prepare: " .. @db\errmsg! unless stm
    stm

  select_one: (query, ...) =>
    stm = @prepare "SELECT " .. query
    stm\bind_values ...
    result = if stm\step! == sqlite3.ROW
      stm\get_values!
    stm\finalize!
    unpack result if result

  stm: (query, ...) =>
    stm = @prepare query
    stm\bind_values ...
    stm\step!
    stm\finalize!

  create_db: => -- : )


