
require "util"

module("stats", package.seeall)

local config = require "config"
if not config.db then error('no db configuration') end

local db = db(config.db.dbname, config.db.user, config.db.password)

print("stats plugin loaded")

function on_message(name, channel, msg, host)
	print("+++ Plugin message", name, channel, msg)

	-- count how many messages they have
	local iter, rows = db.select("message_count from users where name = '"..db.escape(name).."'")
	if rows > 0 then
		local count = tonumber(iter().message_count) + 1
		local update = {
			message_count = count,
			last_seen = os.time(),
		}
		local rand = math.random()
		print("Picking random", count, rand, 1/count)

		if rand <= 1/count then
			update.random_message = msg
		end

		db.execute("update users set %s where name = '"..db.escape(name).."'", db.serialize(update))

	else
		db.execute("insert into users set %s", db.serialize{
			name = name,
			message_count = 1,
			last_seen = os.time(),
			random_message = msg,
		})
	end
end


