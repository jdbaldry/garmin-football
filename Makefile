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
sdk: $(CURRENT_SDK) $(HOME)/.Garmin/ConnectIQ/current-sdk.cfg
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

SRC_FILES := $(wildcard src/*)
RESOURCE_FILES := $(shell find resources -type f -print)

FootballApp.prg: ## Build the app PRG.
FootballApp.prg: bin/iq sdk/bin/monkeyc FootballApp.jungle manifest.xml $(SRC_FILES) $(RESOURCE_FILES)
	rm -f $@
	./bin/iq monkeyc -o FootballApp.prg -d fenix6pro -f FootballApp.jungle -y developer_key.der

.PHONY: deploy
deploy: ## Deploy the built PRG file to a Garmin device.
deploy:  FootballApp.prg
	tmp="$$(mktemp -d)"
	trap "rmdir $${tmp}" EXIT
	sudo jmtpfs -o umask=0022,gid=100,uid=1000,allow_other "$${tmp}"
	mv $< "$${tmp}/Primary/GARMIN/Apps/"
	sudo umount "$${tmp}"

.PHONY: simulate
simulate: ## Run the built PRG file in the Garmin Connect IQ simulator. Requires the simulator to be running.
simulate: FootballApp.prg bin/iq sdk/bin/monkeydo
	set -m
	trap "pkill simulator" EXIT
	./bin/iq simulator &
	./bin/iq monkeydo $< fenix6pro ""
