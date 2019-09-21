
db = require "lapis.db"
import concat, insert from table

insert_on_conflict_update = (model, primary, create, update, opts) ->
  import encode_values, encode_assigns from require "lapis.db"

  full_insert = {}

  for k,v in pairs primary
    if type(k) == "table" and k.column
      k = k.column

    full_insert[k] = v

  if create
    for k,v in pairs create
      full_insert[k] = v

  full_update = update or {k,v for k,v in pairs full_insert when not primary[k]}

  if model.timestamp
    d = db.format_date!
    full_insert.created_at or= d
    full_insert.updated_at or= d
    full_update.updated_at or= d

  buffer = {
    "insert into "
    db.escape_identifier model\table_name!
    " "
  }

  encode_values full_insert, buffer

  insert buffer, " on conflict ("

  for k in pairs primary
    if type(k) == "table" and k.value
      k = k.value

    insert buffer, db.escape_identifier k
    insert buffer, ", "

  buffer[#buffer] = ") do update set " -- remove ,
  encode_assigns full_update, buffer

  insert buffer, " returning *"

  if opts and opts.return_inserted
    insert buffer, ", xmax = 0 as inserted"

  q = concat buffer
  res = db.query q

  if res.affected_rows and res.affected_rows > 0
    model\load res[1]
  else
    nil, res


{:insert_on_conflict_update}

