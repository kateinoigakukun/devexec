PREFIX?=/usr/local

build:
		swift build -c release
install: build
		mkdir -p "$(PREFIX)/bin"
		cp -f ".build/release/devexec" "$(PREFIX)/bin/devexec"
