
.PHONY: test_server lint

test_server:
	ngircd -n --config test/ngircd.conf

lint: 
	git ls-files | grep '\.moon$$' | grep -v config.moon | xargs -n 100 moonc -l
