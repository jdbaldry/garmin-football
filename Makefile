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
	steps=()
	function cleanup { set -x; IFS=';' eval "$${steps[*]}"; };
	trap cleanup EXIT
	tmp="$$(mktemp -d)"
	steps+=("rmdir $${tmp}")
	trap "rmdir $${tmp}" EXIT
	sudo jmtpfs -o umask=0022,gid=100,uid=1000,allow_other "$${tmp}"
	steps+=("sudo umount $${tmp}")
	mv $< "$${tmp}/Primary/GARMIN/Apps/"

.PHONY: simulate
simulate: ## Run the built PRG file in the Garmin Connect IQ simulator. Requires the simulator to be running.
simulate: FootballApp.prg bin/iq sdk/bin/monkeydo
	set -m
	trap "pkill simulator" EXIT
	./bin/iq simulator &
	./bin/iq monkeydo $< fenix6pro ""

.PHONY: import
import: ## Import the latest logs from the Football app.
import:
	steps=()
	function cleanup { set -x; IFS=';' eval "$${steps[*]}"; };
	trap cleanup EXIT
	tmp="$$(mktemp -d)"
	steps+=("rmdir $${tmp}")
	sudo jmtpfs -o umask=0022,gid=100,uid=1000,allow_other "$${tmp}"
	steps+=("sudo umount $${tmp}")
	cp "$${tmp}/Primary/GARMIN/Apps/LOGS/FOOTBALLAPP.TXT" "$$(date +%Y-%m-%d).txt"

.PHONY: truncate
truncate: ## Truncate the Football app logs on the Garmin device.
	steps=()
	function cleanup { set -x; IFS=';' eval "$${steps[*]}"; };
	trap cleanup EXIT
	tmp="$$(mktemp -d)"
	steps+=("rmdir $${tmp}")
	sudo jmtpfs -o umask=0022,gid=100,uid=1000,allow_other "$${tmp}"
	steps+=("sudo umount $${tmp}")
	read -rp "Are you sure you wish to truncate the logs? " TRUNCATE
	if [[ "${TRUNCATE}" == "yes" ]]; then
		: >"$${tmp}/Primary/GARMIN/Apps/LOGS/FOOTBALLAPP.TXT"
	else
		echo "Not truncating file"

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
