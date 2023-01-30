package main

import (
	"bufio"
	"encoding/json"
	"flag"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"strings"
	"text/template"
	"time"
)

// Enum of possible teams.
const (
	teamA = iota
	teamB
	teamBoth // Used only by the MatchEvents for match reporting.
)

const (
	// matchReportTemplatePath is the template file for match reports.
	matchReportTemplatePath = "match-report.html.tpl"
	// statsTemplatePath is the template file for the stats page.
	statsTemplatePath = "stats.html.tpl"
	// indexTemplatePath is the template file for the index page.
	indexTemplatePath = "index.html.tpl"
)

// Map of the lower cased locale's abbreviated weekday name (%a) in coreutils date.
//
//nolint:gochecknoglobals
var days = map[string]string{
	"mon": "Monday",
	"tue": "Tuesday",
	"wed": "Wednesday",
	"thu": "Thursday",
	"fri": "Friday",
	"sat": "Saturday",
	"sun": "Sunday",
}

// Time is a custom time structure that handles unmarshaling RFC3339 time strings
// with precision to the second.
type Time struct{ time.Time }

// UnmarshalJSON unmarshals RFC3339 time strings that have precision to the second.
func (t *Time) UnmarshalJSON(b []byte) error {
	s := string(b)

	parsed, err := time.Parse("2006-01-02 15:04:05", strings.Trim(s, `"`))
	if err != nil {
		return err
	}

	t.Time = parsed

	return nil
}

// Event is an event from a JSON structured log file.
type Event struct {
	// Timestamp is the timestamp for the log in RFC3339 format with precision to the second.
	// It is present on all events.
	Timestamp Time
	// Kind is the kind of the Event.
	// Kind is extracted from the "event" member.
	// It is present on all events.
	Kind string `json:"event"`
	// Player is the primary subject of the Event.
	// It is present on most kinds of events, including "G", "OG", "C", "K", "YC", and "RC".
	Player string
	// Keeper is the secondary subject of the Event.
	// It is only present on the goal events "G" and "OG".
	Keeper string
	// Players is present when there are multiple subjects of equal import.
	// It is present on "T", team events.
	Players []string
	// Team is the integer representation of the team.
	// It is present on all events that have a Player or Players subject.
	Team int
	// Value is the primary subject of non-player events such as "A", activity events.
	Value string
}

// Page is a file and its title.
type Page struct {
	Path  string
	Title string
}

func main() {
	flag.Parse()

	if flag.NArg() != 1 {
		log.Println("Argument <DAY> required but not provided")
		log.Println("Usage:")
		log.Fatalf("  %s <DAY>\n", os.Args[0])
	}

	day := flag.Args()[0]

	matchReportTemplate, err := template.ParseFiles(matchReportTemplatePath)
	if err != nil {
		log.Fatalf("Failed to parse match report template file: %v\n", err)
	}

	indexTemplate, err := template.ParseFiles(indexTemplatePath)
	if err != nil {
		log.Fatalf("Failed to parse template file: %v\n", err)
	}

	indexFile, err := os.Create(filepath.Join(day, "index.html"))
	if err != nil {
		log.Fatalf("Failed to open index file: %v\n", err)
	}

	statsTemplate, err := template.ParseFiles(statsTemplatePath)
	if err != nil {
		log.Fatalf("Failed to parse template file: %v\n", err)
	}

	statsFile, err := os.Create(filepath.Join(day, "stats.html"))
	if err != nil {
		log.Fatalf("Failed to open stats file: %v\n", err)
	}

	// logsGlob is a glob pattern for matching input log files.
	logsGlob := filepath.Join(day, "*-*-*.txt")

	var (
		rawOverall = make(map[string]RawStats)
		pages      []Page
	)

	paths, _ := filepath.Glob(logsGlob)
	for i, p := range paths {
		f, err := os.Open(p)
		if err != nil {
			log.Printf("Failed to open file %q, skipping match report: %v\n", p, err)
			continue
		}

		outputPath := strings.TrimSuffix(p, ".txt") + ".html"

		outputFile, err := os.Create(outputPath)
		if err != nil {
			log.Fatalf("Failed to open match report output file %q, skipping match report: %v\n", outputPath, err)
		}

		events := []Event{}

		scanner := bufio.NewScanner(f)
		for scanner.Scan() {
			var event *Event
			if err := json.Unmarshal(scanner.Bytes(), event); err != nil {
				log.Printf("Failed to unmarshal line %q, skipping line: %v\n", scanner.Text(), err)

				continue
			}

			events = append(events, *event)
		}

		if err := scanner.Err(); err != nil {
			log.Printf("Error reading lines from file %q, skipping match report: %v\n", p, err)

			continue
		}

		match := reportMatch(events)
		if i > 0 {
			match.MatchReport.Prev = strings.TrimSuffix(paths[i-1], ".txt") + ".html"
		}

		if i < len(paths)-1 {
			match.MatchReport.Next = strings.TrimSuffix(paths[i+1], ".txt") + ".html"
		}

		pages = append(pages, Page{
			Path:  filepath.Base(outputPath),
			Title: fmt.Sprintf("%s %s vs. %s", match.MatchReport.Date, match.MatchReport.A.Captain, match.MatchReport.B.Captain),
		})

		updatePlayerStats(rawOverall, match)

		if err := matchReportTemplate.Execute(outputFile, match); err != nil {
			log.Printf("Failed to execute template for match report %q, skipping match report: %v\n", outputPath, err)
		}
	}

	if err := indexTemplate.Execute(indexFile, struct {
		Pages []Page
		Day   string
	}{
		Pages: pages,
		Day:   days[day],
	}); err != nil {
		log.Fatalf("Failed to execute template: %v\n", err)
	}

	computed := computeStats(rawOverall)
	if err := statsTemplate.Execute(statsFile, computed); err != nil {
		log.Fatalf("Failed to execute template: %v\n", err)
	}
}
