package main

import (
	"log"
	"time"
)

// Team is a representation of a team.
type Team struct {
	// Captain is the captain of the team for a match.
	Captain string
	// Keeper is the keeper of the team at a point in time.
	// It may change throughout the match.
	Keeper string
	// Players is the list of players in the team including the captain and keeper.
	Players []string
	// Score is the number of goals scored by the team at a point in time.
	// It will increase monotonically throughout the match when a player on the team
	// scores a goal or a player from the opposing team scores an own goal.
	Score int
}

// MatchEvent is a representation of an event in a match report.
type MatchEvent struct {
	// Minute is the number of minutes since the match began.
	Minute float64
	// Player is the subject of the match event when there is a single subject.
	Player string
	// Players is the subject of the match event when there are multiple subjects.
	// Unlike the log Event events, there is no secondary subject so this field may
	// be used to represent groups of players or primary and secondary subjects, or
	// even to represent players from both teams.
	// If Players has players from both teams, the Team should be TEAM_BOTH.
	Players []string
	// Team is the team that the Player or Players belong to.
	// Team should be one of TEAM_A, TEAM_B, or TEAM_BOTH.
	Team int
	// Type is the type of event represented as a string.
	// For example, "Goal", "Own goal", or "Keeper".
	Type string
}

// MatchReport is a report of a match.
type MatchReport struct {
	// A has the present state of TEAM_A.
	A Team
	// B has the present state of TEAM_B.
	B Team
	// Date is typically the date of the match in the format YYYY-MM-DD.
	Date string
	// Events are all the events that occurred during the match.
	Events []MatchEvent
}

// Stats track the statistics for a player.
type Stats struct {
	// InGoal is the time spent playing in goal.
	InGoal time.Duration
	// Outfield is the time spent playing out of goal.
	Outfield time.Duration

	// Conceded is the number of goals conceded whilst in goal.
	Conceded int
	// Goals is the number of goals scored by a player.
	// Goals are assumed to be only scored whilst out of goal.
	// TODO: Support keepers scoring own goals.
	Goals int
	// OwnGoals is the number of own goals scored by a player.
	// OwnGoals are assumed to be only scored whilst out of goal.
	OwnGoals int
	// RedCards is the number of red cards a player has received.
	RedCards int
	// YellowCards is the number of yellow cards a player has received.
	YellowCards int
}

// StatsReport is the complete statistics for all players of both teams.
type StatsReport struct {
	// A is a map of player names to their match statistics for players in TEAM_A.
	A map[string]Stats
	// B is a map of player names to their match statistics for players in TEAM_B.
	B map[string]Stats
}

// Report is a full report of a match, including the match events in a MatchReport
// and the player statistics in a StatsReport.
type Report struct {
	MatchReport MatchReport
	StatsReport StatsReport
}

func updateDurations(player string, keeper string, stats Stats, currentTime time.Time, lastUpdated time.Time) Stats {
	elapsed := time.Duration(currentTime.Sub(lastUpdated).Nanoseconds())
	if player == keeper {
		stats.InGoal += elapsed
	} else {
		stats.Outfield += elapsed
	}
	return stats
}

// reportMatch transforms a log of structured events into a match report.
func reportMatch(events []Event) (match Report) {
	match = Report{
		MatchReport{},
		StatsReport{
			A: make(map[string]Stats),
			B: make(map[string]Stats),
		},
	}

	// Whether or not the match has previously started.
	var started bool
	// The time of the initial kick off.
	var start time.Time
	// The time when the "in goal" and "out field" durations were
	// last updated.
	var durationsLastUpdated time.Time
	for i, e := range events {
		switch e.Kind {
		case "A":
			switch e.Value {
			case "started":
				if !started {
					start = e.Ts.Time
					durationsLastUpdated = e.Ts.Time
					started = true
				}

				match.MatchReport.Date = e.Ts.Format("2006-01-02")

				match.MatchReport.Events = append(match.MatchReport.Events, MatchEvent{
					Minute: e.Ts.Sub(start).Minutes(),
					Team:   TEAM_BOTH,
					Type:   "Kickoff",
				})
			case "paused":
				for _, p := range match.MatchReport.A.Players {
					stats := updateDurations(p, match.MatchReport.A.Keeper, match.StatsReport.A[p], e.Ts.Time, durationsLastUpdated)
					match.StatsReport.A[p] = stats
				}
				for _, p := range match.MatchReport.B.Players {
					stats := updateDurations(p, match.MatchReport.B.Keeper, match.StatsReport.B[p], e.Ts.Time, durationsLastUpdated)
					match.StatsReport.B[p] = stats
				}
				durationsLastUpdated = e.Ts.Time

				match.MatchReport.Events = append(match.MatchReport.Events, MatchEvent{
					Minute: e.Ts.Sub(start).Minutes(),
					Team:   TEAM_BOTH,
					Type:   "Paused",
				})
			case "stopped":
				for _, p := range match.MatchReport.A.Players {
					stats := updateDurations(p, match.MatchReport.A.Keeper, match.StatsReport.A[p], e.Ts.Time, durationsLastUpdated)
					match.StatsReport.A[p] = stats
				}
				for _, p := range match.MatchReport.B.Players {
					stats := updateDurations(p, match.MatchReport.B.Keeper, match.StatsReport.B[p], e.Ts.Time, durationsLastUpdated)
					match.StatsReport.B[p] = stats
				}
				durationsLastUpdated = e.Ts.Time

				match.MatchReport.Events = append(match.MatchReport.Events, MatchEvent{
					Minute: e.Ts.Sub(start).Minutes(),
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
				match.MatchReport.A.Captain = e.Player
			case TEAM_B:
				match.MatchReport.B.Captain = e.Player
			default:
				log.Printf("Unrecognized team value: %q\n", e.Team)
			}

		case "T":
			switch e.Team {
			case TEAM_A:
				match.MatchReport.A.Players = e.Players
				for _, player := range e.Players {
					match.StatsReport.A[player] = Stats{}
				}
			case TEAM_B:
				match.MatchReport.B.Players = e.Players
				for _, player := range e.Players {
					match.StatsReport.B[player] = Stats{}
				}
			default:
				log.Printf("Unrecognized team value: %q\n", e.Team)
			}

		case "K":
			for _, p := range match.MatchReport.A.Players {
				stats := updateDurations(p, match.MatchReport.A.Keeper, match.StatsReport.A[p], e.Ts.Time, durationsLastUpdated)
				match.StatsReport.A[p] = stats
			}
			for _, p := range match.MatchReport.B.Players {
				stats := updateDurations(p, match.MatchReport.B.Keeper, match.StatsReport.B[p], e.Ts.Time, durationsLastUpdated)
				match.StatsReport.B[p] = stats
			}
			durationsLastUpdated = e.Ts.Time

			// Group together double keeper changes.
			// TODO: should consider some reasonable delta as the same keeper change.
			if i+1 < len(events) && events[i+1].Kind == "K" {
				continue
			}
			if i-1 >= 0 && events[i-1].Kind == "K" {
				match.MatchReport.A.Keeper = events[i-1].Player
				match.MatchReport.B.Keeper = e.Player
				match.MatchReport.Events = append(match.MatchReport.Events, MatchEvent{
					Minute:  e.Ts.Sub(start).Minutes(),
					Players: []string{match.MatchReport.A.Keeper, match.MatchReport.B.Keeper},
					Team:    TEAM_BOTH,
					Type:    "Keeper",
				})
			} else {
				switch e.Team {
				case TEAM_A:
					match.MatchReport.A.Keeper = e.Keeper
				case TEAM_B:
					match.MatchReport.B.Keeper = e.Keeper
				default:
					log.Printf("Unrecognized team value: %q\n", e.Team)
				}
				match.MatchReport.Events = append(match.MatchReport.Events, MatchEvent{
					Minute: e.Ts.Sub(start).Minutes(),
					Player: e.Player,
					Team:   e.Team,
					Type:   "Keeper",
				})
			}

		case "G":
			match.MatchReport.Events = append(match.MatchReport.Events, MatchEvent{
				Minute: e.Ts.Sub(start).Minutes(),
				Player: e.Player,
				Team:   e.Team,
				Type:   "Goal",
			})
			switch e.Team {
			case TEAM_A:
				match.MatchReport.A.Score++

				stats := match.StatsReport.A[e.Player]
				stats.Goals++
				match.StatsReport.A[e.Player] = stats

				stats = match.StatsReport.B[e.Keeper]
				stats.Conceded++
				match.StatsReport.B[e.Keeper] = stats
			case TEAM_B:
				match.MatchReport.B.Score++

				stats := match.StatsReport.B[e.Player]
				stats.Goals++
				match.StatsReport.B[e.Player] = stats

				stats = match.StatsReport.A[e.Keeper]
				stats.Conceded++
				match.StatsReport.A[e.Keeper] = stats
			default:
				log.Printf("Unrecognized team value: %q\n", e.Team)
			}

		case "OG":
			match.MatchReport.Events = append(match.MatchReport.Events, MatchEvent{
				Minute: e.Ts.Sub(start).Minutes(),
				Player: e.Player,
				Team:   e.Team,
				Type:   "Own goal",
			})
			switch e.Team {
			case TEAM_A:
				match.MatchReport.B.Score++

				stats := match.StatsReport.A[e.Player]
				stats.OwnGoals++
				match.StatsReport.A[e.Player] = stats

				stats = match.StatsReport.A[e.Keeper]
				stats.Conceded++
				match.StatsReport.A[e.Keeper] = stats
			case TEAM_B:
				match.MatchReport.A.Score++

				stats := match.StatsReport.B[e.Player]
				stats.OwnGoals++
				match.StatsReport.B[e.Player] = stats

				stats = match.StatsReport.A[e.Keeper]
				stats.Conceded++
				match.StatsReport.B[e.Keeper] = stats
			default:
				log.Printf("Unrecognized team value: %q\n", e.Team)
			}

		case "RC":
			match.MatchReport.Events = append(match.MatchReport.Events, MatchEvent{
				Minute: e.Ts.Sub(start).Minutes(),
				Player: e.Player,
				Team:   e.Team,
				Type:   "Red card",
			})
			switch e.Team {
			case TEAM_A:
				stats := match.StatsReport.A[e.Player]
				stats.RedCards++
				match.StatsReport.A[e.Player] = stats
			case TEAM_B:
				stats := match.StatsReport.B[e.Player]
				stats.RedCards++
				match.StatsReport.B[e.Player] = stats
			default:
				log.Printf("Unrecognized team value: %q\n", e.Team)
			}

		case "YC":
			match.MatchReport.Events = append(match.MatchReport.Events, MatchEvent{
				Minute: e.Ts.Sub(start).Minutes(),
				Player: e.Player,
				Team:   e.Team,
				Type:   "Yellow card",
			})
			switch e.Team {
			case TEAM_A:
				stats := match.StatsReport.A[e.Player]
				stats.YellowCards++
				match.StatsReport.A[e.Player] = stats
			case TEAM_B:
				stats := match.StatsReport.B[e.Player]
				stats.YellowCards++
				match.StatsReport.B[e.Player] = stats
			default:
				log.Printf("Unrecognized team value: %q\n", e.Team)
			}

		default:
			log.Printf("Unrecognized event type: %q\n", e.Kind)
		}
	}
	return match
}
