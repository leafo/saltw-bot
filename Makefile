
.PHONY: test_server lint

test_server:
	ngircd -n --config test/ngircd.conf

lint: 
	moonc lint_config.moon
	git ls-files | grep '\.moon$$' | grep -v config.moon | grep -v stats_server | xargs -n 100 moonc -l
