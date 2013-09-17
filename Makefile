all: build

.PHONY: dev
dev: build
	lapis server development

.PHONY: prod
prod:
	lapis server production

.PHONY: build
build:
	moonc config.moon
	moonc views/*{/*,}.moon

.PHONY: clean
clean:
	rm -f config.lua
	rm -f views/*{/*,}.lua

.PHONY: cleaner
cleaner: clean
	rm -f nginx.conf.compiled
	rm -rf *_temp
	rm -rf logs
