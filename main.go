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

const (
	TEAM_A = iota
	TEAM_B
	TEAM_BOTH // Used only by the MatchEvents for match reporting.
)

const (
	logsGlob            = "*-*-*.txt"
	matchReportTemplate = "match-report.html.tpl"
	statsTemplate       = "stats.html.tpl"
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
	Keeper  string
	Players []string
	Score   int
}

type MatchEvent struct {
	Minute  float64
	Player  string
	Players []string
	Team    int
	Type    string
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

type RawStats struct {
	Games    int
	Wins     int
	Losses   int
	Draws    int
	InGoal   time.Duration
	Outfield time.Duration
	Goals    int
	Conceded int
	OwnGoals int
	Reds     int
	Yellows  int
}

type HistoricStats struct {
	RawStats
	WinRatio float64
	GPG      float64
	GPH      float64
	CPG      float64
	CPH      float64
	OGPG     float64
	OGPH     float64
	YPG      float64
	RPG      float64
}

func main() {
	t, err := template.ParseFiles(matchReportTemplate)
	if err != nil {
		log.Fatalf("Failed to parse template file: %v\n", err)
	}

	var overall = make(map[string]HistoricStats)

	paths, _ := filepath.Glob(logsGlob)
	for _, p := range paths {
		f, err := os.Open(p)
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
		var durationsLastUpdated time.Time
		var secondHalf bool
		for i, e := range events {
			switch e.Event {
			case "A":
				switch e.Value {
				case "started":
					if !secondHalf {
						firstKO = e.Ts.Time
						durationsLastUpdated = e.Ts.Time
					}
					mr.Date = e.Ts.Format("2006-01-02")
					mr.Events = append(mr.Events, MatchEvent{
						Minute: e.Ts.Sub(firstKO).Minutes(),
						Team:   TEAM_BOTH,
						Type:   "Kickoff",
					})
				case "paused":
					elapsed := time.Duration(e.Ts.Sub(durationsLastUpdated).Nanoseconds())
					for _, p := range mr.A.Players {
						stats := sr.A[p]
						if p == mr.A.Keeper {
							stats.InGoal += elapsed
						} else {
							stats.Outfield += elapsed
						}
						sr.A[p] = stats
					}
					for _, p := range mr.B.Players {
						stats := sr.B[p]
						if p == mr.B.Keeper {
							stats.InGoal += elapsed
						} else {
							stats.Outfield += elapsed
						}
						sr.B[p] = stats
					}
					durationsLastUpdated = e.Ts.Time
					secondHalf = true
					mr.Events = append(mr.Events, MatchEvent{
						Minute: e.Ts.Sub(firstKO).Minutes(),
						Team:   TEAM_BOTH,
						Type:   "Paused",
					})
				case "stopped":
					for _, p := range mr.A.Players {
						stats := sr.A[p]
						if p == mr.A.Keeper {
							stats.InGoal += time.Duration(e.Ts.Sub(durationsLastUpdated).Nanoseconds())
						} else {
							stats.Outfield += time.Duration(e.Ts.Sub(durationsLastUpdated).Nanoseconds())
						}
						sr.A[p] = stats
					}
					for _, p := range mr.B.Players {
						stats := sr.B[p]
						if p == mr.B.Keeper {
							stats.InGoal += time.Duration(e.Ts.Sub(durationsLastUpdated).Nanoseconds())
						} else {
							stats.Outfield += time.Duration(e.Ts.Sub(durationsLastUpdated).Nanoseconds())
						}
						sr.B[p] = stats
					}
					durationsLastUpdated = e.Ts.Time
					mr.Events = append(mr.Events, MatchEvent{
						Minute: e.Ts.Sub(firstKO).Minutes(),
						Team:   TEAM_BOTH,
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
				for _, p := range mr.A.Players {
					stats := sr.A[p]
					if p == mr.A.Keeper {
						stats.InGoal += time.Duration(e.Ts.Sub(durationsLastUpdated).Nanoseconds())
					} else {
						stats.Outfield += time.Duration(e.Ts.Sub(durationsLastUpdated).Nanoseconds())
					}
					sr.A[p] = stats
				}
				for _, p := range mr.B.Players {
					stats := sr.B[p]
					if p == mr.B.Keeper {
						stats.InGoal += time.Duration(e.Ts.Sub(durationsLastUpdated).Nanoseconds())
					} else {
						stats.Outfield += time.Duration(e.Ts.Sub(durationsLastUpdated).Nanoseconds())
					}
					sr.B[p] = stats
				}
				durationsLastUpdated = e.Ts.Time
				// Group together double keeper changes.
				// TODO: should consider some reasonable delta as the same keeper change.
				if i+1 < len(events) && events[i+1].Event == "K" {
					continue
				}
				if i-1 >= 0 && events[i-1].Event == "K" {
					mr.A.Keeper = events[i-1].Player
					mr.B.Keeper = e.Player
					mr.Events = append(mr.Events, MatchEvent{
						Minute:  e.Ts.Sub(firstKO).Minutes(),
						Players: []string{mr.A.Keeper, mr.B.Keeper},
						Team:    TEAM_BOTH,
						Type:    "Keeper",
					})
				} else {
					switch e.Team {
					case TEAM_A:
						mr.A.Keeper = e.Keeper
					case TEAM_B:
						mr.B.Keeper = e.Keeper
					default:
						log.Printf("Unrecognized team value: %q\n", e.Team)
					}
					mr.Events = append(mr.Events, MatchEvent{
						Minute: e.Ts.Sub(firstKO).Minutes(),
						Player: e.Player,
						Team:   e.Team,
						Type:   "Keeper",
					})
				}

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

		for p, s := range sr.A {
			stats := overall[p]
			stats.Games++
			if mr.A.Score > mr.B.Score {
				stats.Wins++
			} else if mr.A.Score == mr.B.Score {
				stats.Draws++
			} else {
				stats.Losses++
			}
			stats.Goals += s.Goals
			stats.OwnGoals += s.OwnGoals
			stats.Conceded += s.Conceded
			stats.InGoal += s.InGoal
			stats.Outfield += s.Outfield
			stats.Yellows += s.YellowCards
			stats.Reds += s.RedCards
			overall[p] = stats
		}
		for p, s := range sr.B {
			stats := overall[p]
			stats.Games++
			if mr.B.Score > mr.A.Score {
				stats.Wins++
			} else if mr.B.Score == mr.A.Score {
				stats.Draws++
			} else {
				stats.Losses++
			}
			stats.Goals += s.Goals
			stats.OwnGoals += s.OwnGoals
			stats.Conceded += s.Conceded
			stats.InGoal += s.InGoal
			stats.Outfield += s.Outfield
			stats.Yellows += s.YellowCards
			stats.Reds += s.RedCards
			overall[p] = stats
		}

		op := strings.TrimSuffix(p, ".txt") + ".html"
		of, err := os.Create(op)
		if err != nil {
			log.Fatalf("Failed to open match report %q: %v\n", op, err)
		}

		if err := t.Execute(of, Report{mr, sr}); err != nil {
			log.Fatalf("Failed to execute template: %v\n", err)
		}
	}

	var computed = make(map[string]HistoricStats)
	for p, raw := range overall {
		if raw.Games < 3 || p == "" {
			continue
		}
		computed[p] = HistoricStats{
			RawStats: raw.RawStats,
			WinRatio: float64(raw.Wins) / float64(raw.Games),
			GPG:      float64(raw.Goals) / float64(raw.Games),
			GPH:      float64(raw.Goals) / raw.Outfield.Hours(),
			CPG:      float64(raw.Conceded) / float64(raw.Games),
			CPH:      float64(raw.Conceded) / raw.InGoal.Hours(),
			OGPG:     float64(raw.OwnGoals) / float64(raw.Games),
			OGPH:     float64(raw.OwnGoals) / raw.Outfield.Hours(),
			YPG:      float64(raw.Yellows) / float64(raw.Games),
			RPG:      float64(raw.Reds) / float64(raw.Games),
		}
	}

	t, err = template.ParseFiles(statsTemplate)
	if err != nil {
		log.Fatalf("Failed to parse template file: %v\n", err)
	}
	f, err := os.Create("stats.html")
	if err != nil {
		log.Fatalf("Failed to open stats file: %v\n", err)
	}
	if err := t.Execute(f, computed); err != nil {
		log.Fatalf("Failed to execute template: %v\n", err)
	}

}
