
.PHONY: test_server lint test_db start


start:
	LAPIS_SHOW_QUERIES=1 LAPIS_ENVIRONMENT=twitch luajit main.lua

test_server:
	ngircd -n --config test/ngircd.conf

lint:
	tup
	git ls-files | grep '\.moon$$' | grep -v config.moon | grep -v stats_server | xargs -n 100 moonc -l

test_db:
	tup
	-dropdb -U postgres saltw_test
	createdb -U postgres saltw_test
	lapis migrate test

init_db:
	tup
	-dropdb -U postgres saltw
	createdb -U postgres saltw
	lapis migrate

checkpoint:
	mkdir -p dev_backup
	pg_dump -F c -U postgres twitch_bot > dev_backup/$$(date +%F_%H-%M-%S).dump

restore_checkpoint:
	-dropdb -U postgres twitch_bot
	createdb -U postgres twitch_bot
	pg_restore -U postgres -d twitch_bot $$(find dev_backup | grep \.dump | sort -V | tail -n 1)
