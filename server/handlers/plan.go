package handlers

import (
	"encoding/json"
	"fitness-server/api"
	"net/http"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/google/uuid"
)

func GenerateFitnessPlan(w http.ResponseWriter, r *http.Request) {
	var request api.PlanGenerationRequest
	
	if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
		http.Error(w, "Invalid JSON", http.StatusBadRequest)
		return
	}

	notesCoach := "Welcome to your personalized fitness plan!"
	sessionId := "session-1"
	samplePlan := api.Plan{
		PlanId:     uuid.New().String(),
		UserId:     request.UserId,
		Goal:       request.Goal,
		StartDate:  time.Now(),
		NotesCoach: &notesCoach,
		Weeks: []api.PlannedWeek{
			{
				WeekNumber: 1,
				StartDate:  time.Now(),
				Days: []api.PlannedDay{
					{
						Date:      time.Now(),
						SessionId: &sessionId,
					},
				},
			},
		},
		Sessions: []api.Session{
			{
				Id:    "session-1",
				Title: "Upper Body Strength",
				Blocks: []api.Block{
					{
						Type:                api.BlockTypeWarmup,
						Rounds:              1,
						RestSecBetweenRounds: 0,
						Items: []api.BlockStep{
							{
								Kind: api.BlockStepKindWarmup,
								WarmupStep: &api.WarmupStep{
									Description: "Dynamic arm swings",
									DurationSec: 300,
								},
							},
						},
					},
					{
						Type:                api.BlockTypeStrength,
						Rounds:              3,
						RestSecBetweenRounds: 90,
						Items: []api.BlockStep{
							{
								Kind: api.BlockStepKindExercisePrescription,
								ExercisePrescription: &api.ExercisePrescription{
									ExerciseName: "Push-ups",
									RepSpec: api.RepSpec{
										Kind: api.Reps,
										Reps: intPtr(10),
									},
									Intensity: api.Intensity{
										Mode: api.Rpe,
										Rpe:  float32Ptr(7.0),
									},
								},
							},
						},
					},
				},
			},
		},
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(samplePlan)
}

func GetUserPlan(w http.ResponseWriter, r *http.Request) {
	userID := chi.URLParam(r, "userID")
	
	if userID == "" {
		http.Error(w, "User ID required", http.StatusBadRequest)
		return
	}

	response := map[string]interface{}{
		"user_id": userID,
		"message": "Plan retrieval not yet implemented",
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func intPtr(i int) *int {
	return &i
}

func float32Ptr(f float32) *float32 {
	return &f
}