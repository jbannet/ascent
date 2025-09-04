package handlers

import (
	"encoding/json"
	"fitness-server/api"
	"net/http"
	"time"

	"github.com/google/uuid"
)

func RegisterUser(w http.ResponseWriter, r *http.Request) {
	var registration api.UserRegistration
	if err := json.NewDecoder(r.Body).Decode(&registration); err != nil {
		http.Error(w, "Invalid JSON", http.StatusBadRequest)
		return
	}

	user := api.User{
		Id:        uuid.New().String(),
		Email:     registration.Email,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(user)
}

func LoginUser(w http.ResponseWriter, r *http.Request) {
	var login api.UserLogin
	if err := json.NewDecoder(r.Body).Decode(&login); err != nil {
		http.Error(w, "Invalid JSON", http.StatusBadRequest)
		return
	}

	response := api.AuthResponse{
		Token: "sample-jwt-token",
		User: api.User{
			Id:    "sample-user-id",
			Email: login.Email,
		},
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}