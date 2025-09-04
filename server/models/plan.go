package models

import (
	"time"
)

type Goal string

const (
	GoalGetStronger           Goal = "get_stronger"
	GoalLoseFat               Goal = "lose_fat"
	GoalGeneralStrengthFitness Goal = "general_strength_fitness"
	GoalBuildMuscle           Goal = "build_muscle"
	GoalEndurance             Goal = "endurance"
	GoalMobilityHealth        Goal = "mobility_health"
)

type Plan struct {
	PlanID     string        `json:"plan_id"`
	UserID     string        `json:"user_id"`
	Goal       Goal          `json:"goal"`
	StartDate  time.Time     `json:"start_date"`
	Weeks      []PlannedWeek `json:"weeks"`
	Sessions   []Session     `json:"sessions"`
	NotesCoach string        `json:"notes_coach"`
}

type PlannedWeek struct {
	WeekNumber int           `json:"week_number"`
	StartDate  time.Time     `json:"start_date"`
	Days       []PlannedDay  `json:"days"`
}

type PlannedDay struct {
	Date      time.Time `json:"date"`
	SessionID string    `json:"session_id,omitempty"`
}