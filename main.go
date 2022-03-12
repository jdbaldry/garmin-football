package main

import (
	"bufio"
	"encoding/json"
	"log"
	"os"
	"path/filepath"
	"strings"
	"text/template"
	"time"
)

// Enum of possible teams.
const (
	TEAM_A = iota
	TEAM_B
	TEAM_BOTH // Used only by the MatchEvents for match reporting.
)

const (
	// logsGlob is a glob pattern for matching input log files.
	logsGlob = "*-*-*.txt"
	// matchReportTemplatePath is the template file for match reports.
	matchReportTemplatePath = "match-report.html.tpl"
	// statsTemplatePath is the template file for the stats page.
	statsTemplatePath = "stats.html.tpl"
)

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
	// Ts is the timestamp for the log in RFC3339 format with precision to the second.
	// It is present on all events.
	Ts Time

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

func main() {
	matchReportTemplate, err := template.ParseFiles(matchReportTemplatePath)
	if err != nil {
		log.Fatalf("Failed to parse match report template file: %v\n", err)
	}

	statsTemplate, err := template.ParseFiles(statsTemplatePath)
	if err != nil {
		log.Fatalf("Failed to parse template file: %v\n", err)
	}
	statsFile, err := os.Create("stats.html")
	if err != nil {
		log.Fatalf("Failed to open stats file: %v\n", err)
	}

	paths, _ := filepath.Glob(logsGlob)

	var rawOverall = make(map[string]RawStats)
	for _, p := range paths {
		f, err := os.Open(p)
		if err != nil {
			log.Printf("Failed to open file %q, skipping match report: %v\n", p, err)
			continue
		}
		op := strings.TrimSuffix(p, ".txt") + ".html"
		of, err := os.Create(op)
		if err != nil {
			log.Fatalf("Failed to open match report output file %q, skipping match report: %v\n", op, err)
		}

		events := []Event{}
		scanner := bufio.NewScanner(f)
		for scanner.Scan() {
			e := &Event{}
			if err := json.Unmarshal(scanner.Bytes(), e); err != nil {
				log.Printf("Failed to unmarshal line %q, skipping line: %v\n", scanner.Text(), err)
				continue
			}
			events = append(events, *e)
		}
		if err := scanner.Err(); err != nil {
			log.Printf("Error reading lines from file %q, skipping match report: %v\n", p, err)
			continue
		}

		match := reportMatch(events)
		updatePlayerStats(rawOverall, match)
		if err := matchReportTemplate.Execute(of, match); err != nil {
			log.Printf("Failed to execute template for match report %q, skipping match report: %v\n", op, err)
		}
	}

	computed := computeStats(rawOverall)
	if err := statsTemplate.Execute(statsFile, computed); err != nil {
		log.Fatalf("Failed to execute template: %v\n", err)
	}
}
