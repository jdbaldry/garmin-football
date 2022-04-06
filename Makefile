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
MOUNT_DIR := /tmp/garmin

FootballApp.prg: ## Build the app PRG.
FootballApp.prg: bin/iq sdk/bin/monkeyc FootballApp.jungle manifest.xml $(SRC_FILES) $(RESOURCE_FILES)
	rm -f $@
	./bin/iq monkeyc -o FootballApp.prg -d fenix6pro -f FootballApp.jungle -y developer_key.der


$(MOUNT_DIR):
	mkdir -p $(MOUNT_DIR)

$(MOUNT_DIR)/Primary: | $(MOUNT_DIR)
	sudo jmtpfs -o umask=0022,gid=100,uid=1000,allow_other $(MOUNT_DIR)
	touch $@

.PHONY: mount
mount: ## Mount the Garmin device to $(MOUNT_DIR).
mount: $(MOUNT_DIR)/Primary

.PHONY: umount
umount: ## Unmount the Garmin device from $(MOUNT_DIR).
umount:
	sudo umount $(MOUNT_DIR)

.PHONY: deploy
deploy: ## Deploy the built PRG file to a Garmin device.
deploy: FootballApp.prg mount
	mv $< "$(MOUNT_DIR)/Primary/GARMIN/Apps/"

.PHONY: simulate
simulate: ## Run the built PRG file in the Garmin Connect IQ simulator. Requires the simulator to be running.
simulate: FootballApp.prg bin/iq sdk/bin/monkeydo
	set -m
	trap "pkill simulator" EXIT
	./bin/iq simulator &
	./bin/iq monkeydo $< fenix6pro ""

.PHONY: import
import: ## Import the latest logs from the Football app.
import: mount
	cp "$(MOUNT_DIR)/Primary/GARMIN/Apps/LOGS/FootballApp.TXT" "$$(date +%Y-%m-%d).txt"

.PHONY: truncate
truncate: ## Truncate the Football app logs on the Garmin device.
truncate: mount
	read -rp "Are you sure you wish to truncate the logs? " TRUNCATE
	if [[ "$${TRUNCATE}" == "yes" ]]; then
		: >"$(MOUNT_DIR)/Primary/GARMIN/Apps/LOGS/FootballApp.TXT"
	else
		echo "Not truncating file"
	fi

GO_FILES := $(wildcard *.go)
%.html: %.txt $(GO_FILES) match-report.html.tpl
	go run ./

stats.html: stats.html.tpl style.css table.js $(GO_FILES) $(wildcard *.txt)
	go run ./

index.html: index.html.tpl style.css table.js $(GO_FILES) $(wildcard *.txt)
	go run ./

.PHONY: match-reports
match-reports: match-report.html.tpl

.PHONY: website
website: ## Build the website pages.
website: $(wildcard *.html)
