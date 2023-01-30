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
	// If Players has players from both teams, the Team should be teamBoth.
	Players []string
	// Team is the team that the Player or Players belong to.
	// Team should be one of teamA, teamB, or teamBoth.
	Team int
	// Type is the type of event represented as a string.
	// For example, "Goal", "Own goal", or "Keeper".
	Type string
}

// MatchReport is a report of a match.
type MatchReport struct {
	// A has the present state of teamA.
	A Team
	// B has the present state of teamB.
	B Team
	// Date is the date of the match in the format YYYY-MM-DD.
	Date string
	// Next the date of the next match in the format YYYY-MM-DD or the empty string if
	// there is no next match.
	Next string
	// Prev the date of the previous match in the format YYYY-MM-DD or the empty string if
	// there is no previous match.
	Prev string
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
	// A is a map of player names to their match statistics for players in teamA.
	A map[string]Stats
	// B is a map of player names to their match statistics for players in teamB.
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
// Links to previous and next match reports are empty and must be filled out
// afterwards.
func reportMatch(events []Event) (match Report) {
	match = Report{
		MatchReport{
			A: Team{
				Captain: "",
				Keeper:  "",
				Players: []string{},
				Score:   0,
			},
			B: Team{
				Captain: "",
				Keeper:  "",
				Players: []string{},
				Score:   0,
			},
			Date:   "",
			Next:   "",
			Prev:   "",
			Events: []MatchEvent{},
		},
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

	for i, event := range events {
		switch event.Kind {
		case "A":
			switch event.Value {
			case "started":
				if !started {
					start = event.Timestamp.Time
					durationsLastUpdated = event.Timestamp.Time
					started = true
				}

				match.MatchReport.Date = event.Timestamp.Format("2006-01-02")

				match.MatchReport.Events = append(match.MatchReport.Events, MatchEvent{
					Minute:  event.Timestamp.Sub(start).Minutes(),
					Player:  "",
					Players: []string{},
					Team:    teamBoth,
					Type:    "Kickoff",
				})
			case "paused":
				for _, player := range match.MatchReport.A.Players {
					stats := updateDurations(
						player,
						match.MatchReport.A.Keeper,
						match.StatsReport.A[player],
						event.Timestamp.Time,
						durationsLastUpdated,
					)
					match.StatsReport.A[player] = stats
				}

				for _, player := range match.MatchReport.B.Players {
					stats := updateDurations(
						player,
						match.MatchReport.B.Keeper,
						match.StatsReport.B[player],
						event.Timestamp.Time,
						durationsLastUpdated,
					)
					match.StatsReport.B[player] = stats
				}

				durationsLastUpdated = event.Timestamp.Time

				match.MatchReport.Events = append(match.MatchReport.Events, MatchEvent{
					Minute:  event.Timestamp.Sub(start).Minutes(),
					Player:  "",
					Players: []string{},
					Team:    teamBoth,
					Type:    "Paused",
				})
			case "stopped":
				for _, player := range match.MatchReport.A.Players {
					stats := updateDurations(
						player,
						match.MatchReport.A.Keeper,
						match.StatsReport.A[player],
						event.Timestamp.Time,
						durationsLastUpdated,
					)
					match.StatsReport.A[player] = stats
				}

				for _, player := range match.MatchReport.B.Players {
					stats := updateDurations(
						player,
						match.MatchReport.B.Keeper,
						match.StatsReport.B[player],
						event.Timestamp.Time,
						durationsLastUpdated,
					)
					match.StatsReport.B[player] = stats
				}

				durationsLastUpdated = event.Timestamp.Time

				match.MatchReport.Events = append(match.MatchReport.Events, MatchEvent{
					Minute:  event.Timestamp.Sub(start).Minutes(),
					Player:  "",
					Players: []string{},
					Team:    teamBoth,
					Type:    "Full time",
				})
			case "saved":
			default:
				log.Printf("Unrecognized activity value: %q\n", event.Value)
			}

		case "C":
			switch event.Team {
			case teamA:
				match.MatchReport.A.Captain = event.Player
			case teamB:
				match.MatchReport.B.Captain = event.Player
			default:
				log.Printf("Unrecognized team value: %q\n", event.Team)
			}

		case "T":
			switch event.Team {
			case teamA:
				match.MatchReport.A.Players = event.Players
				for _, player := range event.Players {
					match.StatsReport.A[player] = Stats{
						InGoal:      0,
						Outfield:    0,
						Conceded:    0,
						Goals:       0,
						OwnGoals:    0,
						RedCards:    0,
						YellowCards: 0,
					}
				}
			case teamB:
				match.MatchReport.B.Players = event.Players
				for _, player := range event.Players {
					match.StatsReport.B[player] = Stats{
						InGoal:      0,
						Outfield:    0,
						Conceded:    0,
						Goals:       0,
						OwnGoals:    0,
						RedCards:    0,
						YellowCards: 0,
					}
				}
			default:
				log.Printf("Unrecognized team value: %q\n", event.Team)
			}

		case "K":
			for _, player := range match.MatchReport.A.Players {
				stats := updateDurations(
					player,
					match.MatchReport.A.Keeper,
					match.StatsReport.A[player],
					event.Timestamp.Time,
					durationsLastUpdated,
				)
				match.StatsReport.A[player] = stats
			}

			for _, player := range match.MatchReport.B.Players {
				stats := updateDurations(
					player,
					match.MatchReport.B.Keeper,
					match.StatsReport.B[player],
					event.Timestamp.Time,
					durationsLastUpdated,
				)
				match.StatsReport.B[player] = stats
			}

			durationsLastUpdated = event.Timestamp.Time

			// Group together double keeper changes.
			// TODO: should consider some reasonable delta as the same keeper change.
			if i+1 < len(events) && events[i+1].Kind == "K" {
				continue
			}

			if i-1 >= 0 && events[i-1].Kind == "K" {
				match.MatchReport.A.Keeper = events[i-1].Player
				match.MatchReport.B.Keeper = event.Player
				match.MatchReport.Events = append(match.MatchReport.Events, MatchEvent{
					Minute:  event.Timestamp.Sub(start).Minutes(),
					Player:  "",
					Players: []string{match.MatchReport.A.Keeper, match.MatchReport.B.Keeper},
					Team:    teamBoth,
					Type:    "Keeper",
				})
			} else {
				switch event.Team {
				case teamA:
					match.MatchReport.A.Keeper = event.Keeper
				case teamB:
					match.MatchReport.B.Keeper = event.Keeper
				default:
					log.Printf("Unrecognized team value: %q\n", event.Team)
				}
				match.MatchReport.Events = append(match.MatchReport.Events, MatchEvent{
					Minute: event.Timestamp.Sub(start).Minutes(),
					Player: event.Player,
					Team:   event.Team,
					Type:   "Keeper",
				})
			}

		case "G":
			match.MatchReport.Events = append(match.MatchReport.Events, MatchEvent{
				Minute:  event.Timestamp.Sub(start).Minutes(),
				Player:  event.Player,
				Players: []string{},
				Team:    event.Team,
				Type:    "Goal",
			})

			switch event.Team {
			case teamA:
				match.MatchReport.A.Score++

				stats := match.StatsReport.A[event.Player]
				stats.Goals++
				match.StatsReport.A[event.Player] = stats

				stats = match.StatsReport.B[event.Keeper]
				stats.Conceded++
				match.StatsReport.B[event.Keeper] = stats
			case teamB:
				match.MatchReport.B.Score++

				stats := match.StatsReport.B[event.Player]
				stats.Goals++
				match.StatsReport.B[event.Player] = stats

				stats = match.StatsReport.A[event.Keeper]
				stats.Conceded++
				match.StatsReport.A[event.Keeper] = stats
			default:
				log.Printf("Unrecognized team value: %q\n", event.Team)
			}

		case "OG":
			match.MatchReport.Events = append(match.MatchReport.Events, MatchEvent{
				Minute:  event.Timestamp.Sub(start).Minutes(),
				Player:  event.Player,
				Players: []string{},
				Team:    event.Team,
				Type:    "Own goal",
			})

			switch event.Team {
			case teamA:
				match.MatchReport.B.Score++

				stats := match.StatsReport.A[event.Player]
				stats.OwnGoals++
				match.StatsReport.A[event.Player] = stats

				stats = match.StatsReport.A[event.Keeper]
				stats.Conceded++
				match.StatsReport.A[event.Keeper] = stats
			case teamB:
				match.MatchReport.A.Score++

				stats := match.StatsReport.B[event.Player]
				stats.OwnGoals++
				match.StatsReport.B[event.Player] = stats

				stats = match.StatsReport.A[event.Keeper]
				stats.Conceded++
				match.StatsReport.B[event.Keeper] = stats
			default:
				log.Printf("Unrecognized team value: %q\n", event.Team)
			}

		case "RC":
			match.MatchReport.Events = append(match.MatchReport.Events, MatchEvent{
				Minute:  event.Timestamp.Sub(start).Minutes(),
				Player:  event.Player,
				Players: []string{},
				Team:    event.Team,
				Type:    "Red card",
			})

			switch event.Team {
			case teamA:
				stats := match.StatsReport.A[event.Player]
				stats.RedCards++
				match.StatsReport.A[event.Player] = stats
			case teamB:
				stats := match.StatsReport.B[event.Player]
				stats.RedCards++
				match.StatsReport.B[event.Player] = stats
			default:
				log.Printf("Unrecognized team value: %q\n", event.Team)
			}

		case "YC":
			match.MatchReport.Events = append(match.MatchReport.Events, MatchEvent{
				Minute:  event.Timestamp.Sub(start).Minutes(),
				Player:  event.Player,
				Players: []string{},
				Team:    event.Team,
				Type:    "Yellow card",
			})

			switch event.Team {
			case teamA:
				stats := match.StatsReport.A[event.Player]
				stats.YellowCards++
				match.StatsReport.A[event.Player] = stats
			case teamB:
				stats := match.StatsReport.B[event.Player]
				stats.YellowCards++
				match.StatsReport.B[event.Player] = stats
			default:
				log.Printf("Unrecognized team value: %q\n", event.Team)
			}

		default:
			log.Printf("Unrecognized event type: %q\n", event.Kind)
		}
	}

	return match
}
