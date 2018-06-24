SHELL := /bin/bash
MAKEFLAGS := --silent

## Default is to run this in development mode for testing the website
default: test

## Setup this directory for development use (pull latest code, ensure dependencies are updated)
setup-devl: pull dep

## Make sure we have the latest code
pull: 
	git pull

## Update all dependencies -- we've removed "[prune] unused-packages = true" from Gopkg.toml
dep:
	dep ensure
	dep ensure -update

.ONESHELL:
## Run test suite
test: generate-all
	export JAEGER_SERVICE_NAME="Lectio Daemon Test Suite"
	export JAEGER_AGENT_HOST=yorktown
	export JAEGER_REPORTER_LOG_SPANS=true
	export JAEGER_SAMPLER_TYPE=const
	export JAEGER_SAMPLER_PARAM=1
	go test

TARGET_MAX_CHAR_NUM=20
## All targets should have a ## Help text above the target and they'll be automatically collected
## Show help, using auto generator from https://gist.github.com/prwhite/8168133
help:
	@echo ''
	@echo 'Usage:'
	@echo '  ${YELLOW}make${RESET} ${GREEN}<target>${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk '/^[a-zA-Z\-\_0-9]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")-1); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "  ${YELLOW}%-$(TARGET_MAX_CHAR_NUM)s${RESET} ${GREEN}%s${RESET}\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)

