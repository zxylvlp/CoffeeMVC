all:
	coffee -c -o lib/ src/
	cp -r src/static src/views src/refLibs lib/
	node lib/run.js
clean:
	rm -r lib/*
