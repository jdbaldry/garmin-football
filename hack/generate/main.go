package main

import (
	"flag"
	"os"
	"path/filepath"
	"strings"
	"text/template"

	log "github.com/golang/glog"
)

const (
	outPath      = "src/FootballDelegate.mc"
	templatePath = "src/FootballDelegate.mc.template"
)

func main() {
	teamA := flag.String("team-a", "a,b,c", "comma separated list of players")
	teamB := flag.String("team-b", "d,e,f", "comma separated list of players")
	flag.Parse()

	tmpl, err := template.New(filepath.Base(templatePath)).ParseFiles(templatePath)
	if err != nil {
		log.Fatalln(err)
	}

	out, err := os.Create(outPath)
	if err != nil {
		log.Fatalln(err)
	}

	if err := tmpl.Execute(out, struct {
		TeamA []string
		TeamB []string
	}{
		TeamA: strings.Split(*teamA, ","),
		TeamB: strings.Split(*teamB, ","),
	}); err != nil {
		log.Fatalln(err)
	}
}
