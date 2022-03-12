# Garmin football

Garmin football watch app and templated HTML that serves football.jdb.sh.

This project targets the `fenix6pro` device and currently requires hardcoded players to function.

At this time, I have no intent to develop this into a published Garmin app.

## Development

The HTML uses [Go templates](https://pkg.go.dev/text/template) and development requires Go 1.17.

If you have Go installed, you can build the web pages with:

```console
$ go run ./
```

If the run is successful, no output should be logged.
