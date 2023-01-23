# Garmin football

Garmin football watch app and templated HTML that is served at https://football.jdb.sh.

This project targets the `fenix6pro` device and currently requires hardcoded players to function.

At this time, I have no intent to develop this into a published Garmin app.

## Development

```
$ make
Usage:
  make <target>

Targets:
  help                                           Display this help.
  sdk                                            Copy in the active SDK that can only be download by the sdkmanager to the HOME directory.
  src/FootballDelegate.mc                        Generate source file from template.
  FootballApp.prg                                Build the app PRG.
  mount                                          Mount the Garmin device to $(MOUNT_DIR).
  umount                                         Unmount the Garmin device from $(MOUNT_DIR).
  deploy                                         Deploy the built PRG file to a Garmin device.
  simulate                                       Run the built PRG file in the Garmin Connect IQ simulator. Requires the simulator to be running.
  import                                         Import the latest logs from the Football app.
  truncate                                       Truncate the Football app logs on the Garmin device.
  website                                        Build the website pages.
  TAGS                                           Generate a TAGS file for Emacs Xref.
```
