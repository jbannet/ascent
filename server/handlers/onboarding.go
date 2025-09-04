package handlers

import (
	"encoding/json"
	"fitness-server/api"
	"net/http"
)

func SubmitOnboardingAnswers(w http.ResponseWriter, r *http.Request) {
	var submission api.OnboardingSubmission
	if err := json.NewDecoder(r.Body).Decode(&submission); err != nil {
		http.Error(w, "Invalid JSON", http.StatusBadRequest)
		return
	}

	userId := "sample-user-id"
	response := api.OnboardingResponse{
		Status:  "success",
		Message: "Onboarding answers processed successfully",
		UserId:  &userId,
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}