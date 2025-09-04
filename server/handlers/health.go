package handlers

import (
	"encoding/json"
	"fitness-server/api"
	"net/http"
)

func HealthCheck(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	
	response := api.HealthStatus{
		Status: "healthy",
		Server: "fitness-server",
	}
	
	json.NewEncoder(w).Encode(response)
}