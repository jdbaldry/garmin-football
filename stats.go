package main

import (
	"fmt"
	"log"
	"time"
)

// They are all monotonically increasing values.
type RawStats struct {
	// Games is the number of games a player has played.
	Games int
	// Wins is the number of games where the players team has won.
	Wins int
	// Losses is the number of games where the players team has lost.
	Losses int
	// Draws is the number of games where the players team has drawn.
	Draws int
	// InGoal is the cumulative time spent playing in goal.
	InGoal time.Duration
	// Outfield is the cumulative time spent playing out of goal.
	Outfield time.Duration
	// Goals is the number of goals scored by the player whilst out field.
	// It is assumed that scoring goals whilst in goal is not allowed.
	Goals int
	// Conceded is the number of goals conceded by the player whilst in goal.
	Conceded int
	// OwnGoals is the number of own goals scored by the player whilst out field.
	OwnGoals int
	// RedCards is the number of red cards the player has received.
	RedCards int
	// YellowCards is the number of yellow cards the player has received.
	YellowCards int
}

// HistoricStats are historical stats for a player including those that require computation
// from RawStats.
type HistoricStats struct {
	RawStats
	// WinRatio is wins / games.
	WinRatio float64
	// GPG is goals / games.
	GPG float64
	// GPH is goals / hours spent out field.
	GPH float64
	// CPG is conceded / games.
	CPG float64
	// CPH is goals / hours spent in goal.
	CPH float64
	// OGPG is own goals / games.
	OGPG float64
	// OGPH is own goals / hours spent out field.
	OGPH float64
	// YPG is yellow cards / games.
	YPG float64
	// RPG is red cards / games.
	RPG float64
}

// updateStats updates a player's stats with the events from a match report.
func updateStats(player string, team int, stats RawStats, match Report) (RawStats, error) {
	var (
		matchStats Stats
		won        bool
	)

	switch team {
	case teamA:
		matchStats = match.StatsReport.A[player]
		won = match.MatchReport.A.Score > match.MatchReport.B.Score
	case teamB:
		matchStats = match.StatsReport.B[player]
		won = match.MatchReport.B.Score > match.MatchReport.A.Score
	default:
		return stats, fmt.Errorf("invalid team: %q", team)
	}

	stats.Games++

	switch {
	case won:
		stats.Wins++
	case match.MatchReport.A.Score == match.MatchReport.B.Score:
		stats.Draws++
	default:
		stats.Losses++
	}

	stats.Goals += matchStats.Goals
	stats.OwnGoals += matchStats.OwnGoals
	stats.Conceded += matchStats.Conceded
	stats.InGoal += matchStats.InGoal
	stats.Outfield += matchStats.Outfield
	stats.YellowCards += matchStats.YellowCards
	stats.RedCards += matchStats.RedCards

	return stats, nil
}

// updatePlayerStats updates all player stats with the events from a match report.
// If there is an error when updating an individuals players stats, it is logged rather
// instead of being returned.
func updatePlayerStats(playerStats map[string]RawStats, match Report) {
	for player := range match.StatsReport.A {
		stats, err := updateStats(player, teamA, playerStats[player], match)
		if err != nil {
			log.Printf("Failed to update stats for player %q: %v\n", player, err)
		}

		playerStats[player] = stats
	}

	for player := range match.StatsReport.B {
		stats, err := updateStats(player, teamB, playerStats[player], match)
		if err != nil {
			log.Printf("Failed to update stats for player %q: %v\n", player, err)
		}

		playerStats[player] = stats
	}
}

// computeStats computes historic stats for all players from their raw stats.
func computeStats(raw map[string]RawStats) map[string]HistoricStats {
	computed := make(map[string]HistoricStats)

	for p, stats := range raw {
		if p == "" || p == "Other" || (stats.Games < 3 && p != "Archie") {
			continue
		}
		computed[p] = HistoricStats{
			RawStats: stats,
			WinRatio: float64(stats.Wins) / float64(stats.Games),
			GPG:      float64(stats.Goals) / float64(stats.Games),
			GPH:      float64(stats.Goals) / stats.Outfield.Hours(),
			CPG:      float64(stats.Conceded) / float64(stats.Games),
			CPH:      float64(stats.Conceded) / stats.InGoal.Hours(),
			OGPG:     float64(stats.OwnGoals) / float64(stats.Games),
			OGPH:     float64(stats.OwnGoals) / stats.Outfield.Hours(),
			YPG:      float64(stats.YellowCards) / float64(stats.Games),
			RPG:      float64(stats.RedCards) / float64(stats.Games),
		}
	}

	return computed
}
