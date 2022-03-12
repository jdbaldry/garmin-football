.ONESHELL:
.DELETE_ON_ERROR:
export SHELL     := bash
export SHELLOPTS := pipefail:errexit
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rule

# Adapted from https://www.thapaliya.com/en/writings/well-documented-makefiles/
.PHONY: help
help: ## Display this help.
help:
	@awk 'BEGIN {FS = ": ##"; printf "Usage:\n  make <target>\n\nTargets:\n"} /^[a-zA-Z0-9_\.\-\/%]+: ##/ { printf "  %-45s %s\n", $$1, $$2 }' $(MAKEFILE_LIST)


CURRENT_SDK = $(shell cat "$(HOME)/.Garmin/ConnectIQ/current-sdk.cfg")
sdk: ## Copy in the active SDK that can only be download by the sdkmanager to the HOME directory.
sdk: $(CURRENT_SDK)
	rsync -av --delete-excluded --include-from - --exclude '*' $< $@ <<-EOF
		bin/
		bin/api.mir
		bin/api.db
		bin/monkeyc
		bin/monkeydo
		bin/monkeybrains.jar
		bin/shell
		bin/simulator
		share/
		share/simulator/
		share/simulator/**
	EOF
	touch $@
