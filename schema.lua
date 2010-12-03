
require 'util'

local config = get_config('config', {})
if not config.db then error('no db configuration') end
local db = db(config.db.dbname, config.db.user, config.db.password)

local tables = {
	users = [[
		id int unsigned not null auto_increment,
		last_seen int unsigned not null default '0',
		name varchar(255) not null,

		message_count int unsigned not null default '0',
		random_message varchar(1024),

		PRIMARY KEY (id),
		INDEX (name)
	]]
}

function remove()
	for tname in pairs(tables) do
		db.execute('drop table if exists `%s`', tname)
	end
end

function install(dont_clean)
	if not dont_clean then remove() end
	for tname, defn in pairs(tables) do
		db.execute('create table `%s` (\n'..defn..')', tname)
	end
end

dispatch(...) {
	install = install,
	remove = remove,
}

