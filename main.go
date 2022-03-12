package main

import (
	"bufio"
	"encoding/json"
	"log"
	"os"
	"strings"
	"text/template"
	"time"
)

const (
	TEAM_A = iota
	TEAM_B
)

type Time struct{ time.Time }

func (t *Time) UnmarshalJSON(b []byte) error {
	s := string(b)
	parsed, err := time.Parse("2006-01-02 15:04:05", strings.Trim(s, `"`))
	if err != nil {
		return err
	}
	t.Time = parsed
	return nil
}

type Event struct {
	Ts Time

	Event   string
	Player  string
	Keeper  string
	Players []string
	Team    int
	Value   string
}

type Team struct {
	Captain string
	Players []string
	Score   int
}

type MatchEvent struct {
	Minute float64
	Player string
	Team   int
	Type   string
}

type MatchReport struct {
	A      Team
	B      Team
	Date   string
	Events []MatchEvent
}

type Stats struct {
	Outfield time.Duration

	Goals       int
	OwnGoals    int
	RedCards    int
	YellowCards int

	InGoal time.Duration

	Conceded int
}

type StatsReport struct {
	A map[string]Stats
	B map[string]Stats
}

type Report struct {
	MatchReport MatchReport
	StatsReport StatsReport
}

func main() {
	f, err := os.Open("2022-03-13.txt")
	if err != nil {
		log.Fatalf("Failed to open file: %v\n", err)
	}

	events := []Event{}
	scanner := bufio.NewScanner(f)
	for scanner.Scan() {
		e := &Event{}
		if err := json.Unmarshal(scanner.Bytes(), e); err != nil {
			log.Fatalf("Failed to unmarshal line: %v\n", err)
		}
		events = append(events, *e)
	}
	if err := scanner.Err(); err != nil {
		log.Fatalf("Error reading lines from file: %v\n", err)
	}

	var mr MatchReport
	var sr StatsReport
	sr.A = make(map[string]Stats)
	sr.B = make(map[string]Stats)
	var firstKO time.Time
	var secondHalf bool
	var lastKeeper struct {
		player string
		time   time.Time
	}
	for _, e := range events {
		switch e.Event {
		case "A":
			switch e.Value {
			case "started":
				if !secondHalf {
					firstKO = e.Ts.Time
				}
				lastKeeper.time = e.Ts.Time
				mr.Date = e.Ts.Format("2006-01-02")
				mr.Events = append(mr.Events, MatchEvent{
					Minute: e.Ts.Sub(firstKO).Minutes(),
					Type:   "Kickoff",
				})
			case "paused":
				secondHalf = true
				mr.Events = append(mr.Events, MatchEvent{
					Minute: e.Ts.Sub(firstKO).Minutes(),
					Type:   "Half time",
				})
			case "stopped":
				mr.Events = append(mr.Events, MatchEvent{
					Minute: e.Ts.Sub(firstKO).Minutes(),
					Type:   "Full time",
				})
			case "saved":
			default:
				log.Printf("Unrecognized activity value: %q\n", e.Value)
			}

		case "C":
			switch e.Team {
			case TEAM_A:
				mr.A.Captain = e.Player
			case TEAM_B:
				mr.B.Captain = e.Player
			default:
				log.Printf("Unrecognized team value: %q\n", e.Team)
			}

		case "T":
			switch e.Team {
			case TEAM_A:
				mr.A.Players = e.Players
				for _, player := range e.Players {
					sr.A[player] = Stats{}
				}
			case TEAM_B:
				mr.B.Players = e.Players
				for _, player := range e.Players {
					sr.B[player] = Stats{}
				}
			default:
				log.Printf("Unrecognized team value: %q\n", e.Team)
			}

		case "K":
			mr.Events = append(mr.Events, MatchEvent{
				Minute: e.Ts.Sub(firstKO).Minutes(),
				Player: e.Player,
				Team:   e.Team,
				Type:   "Keeper",
			})

		case "G":
			mr.Events = append(mr.Events, MatchEvent{
				Minute: e.Ts.Sub(firstKO).Minutes(),
				Player: e.Player,
				Team:   e.Team,
				Type:   "Goal",
			})
			switch e.Team {
			case TEAM_A:
				mr.A.Score++

				stats := sr.A[e.Player]
				stats.Goals++
				sr.A[e.Player] = stats

				stats = sr.B[e.Keeper]
				stats.Conceded++
				sr.B[e.Keeper] = stats
			case TEAM_B:
				mr.B.Score++

				stats := sr.B[e.Player]
				stats.Goals++
				sr.B[e.Player] = stats

				stats = sr.A[e.Keeper]
				stats.Conceded++
				sr.A[e.Keeper] = stats
			default:
				log.Printf("Unrecognized team value: %q\n", e.Team)
			}

		case "OG":
			mr.Events = append(mr.Events, MatchEvent{
				Minute: e.Ts.Sub(firstKO).Minutes(),
				Player: e.Player,
				Team:   e.Team,
				Type:   "Own goal",
			})
			switch e.Team {
			case TEAM_A:
				mr.B.Score++

				stats := sr.A[e.Player]
				stats.OwnGoals++
				sr.A[e.Player] = stats

				stats = sr.A[e.Keeper]
				stats.Conceded++
				sr.A[e.Keeper] = stats
			case TEAM_B:
				mr.A.Score++

				stats := sr.B[e.Player]
				stats.OwnGoals++
				sr.B[e.Player] = stats

				stats = sr.A[e.Keeper]
				stats.Conceded++
				sr.B[e.Keeper] = stats
			default:
				log.Printf("Unrecognized team value: %q\n", e.Team)
			}

		case "RC":
			mr.Events = append(mr.Events, MatchEvent{
				Minute: e.Ts.Sub(firstKO).Minutes(),
				Player: e.Player,
				Team:   e.Team,
				Type:   "Red card",
			})
			switch e.Team {
			case TEAM_A:
				stats := sr.A[e.Player]
				stats.RedCards++
				sr.A[e.Player] = stats
			case TEAM_B:
				stats := sr.B[e.Player]
				stats.RedCards++
				sr.B[e.Player] = stats
			default:
				log.Printf("Unrecognized team value: %q\n", e.Team)
			}

		case "YC":
			mr.Events = append(mr.Events, MatchEvent{
				Minute: e.Ts.Sub(firstKO).Minutes(),
				Player: e.Player,
				Team:   e.Team,
				Type:   "Yellow card",
			})
			switch e.Team {
			case TEAM_A:
				stats := sr.A[e.Player]
				stats.YellowCards++
				sr.A[e.Player] = stats
			case TEAM_B:
				stats := sr.B[e.Player]
				stats.YellowCards++
				sr.B[e.Player] = stats
			default:
				log.Printf("Unrecognized team value: %q\n", e.Team)
			}

		default:
			log.Printf("Unrecognized event type: %q\n", e.Event)
		}
	}

	t, err := template.ParseFiles("match-report.html")
	if err != nil {
		log.Fatalf("Failed to parse template file: %v\n", err)
	}

	if err := t.Execute(os.Stdout, Report{mr, sr}); err != nil {
		log.Fatalf("Failed to execute template: %v\n", err)
	}
}
