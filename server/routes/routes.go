package routes

import (
	"fitness-server/config"
	"fitness-server/handlers"
	"fitness-server/middleware"

	"github.com/go-chi/chi/v5"
	chiMiddleware "github.com/go-chi/chi/v5/middleware"
)

func SetupRoutes(cfg *config.Config) *chi.Mux {
	r := chi.NewRouter()

	r.Use(chiMiddleware.Logger)
	r.Use(chiMiddleware.Recoverer)
	r.Use(middleware.CORS())

	r.Get("/health", handlers.HealthCheck)

	r.Route("/api", func(r chi.Router) {
		r.Route("/user", func(r chi.Router) {
			r.Post("/register", handlers.RegisterUser)
			r.Post("/login", handlers.LoginUser)
		})

		r.Route("/onboarding", func(r chi.Router) {
			r.Post("/submit", handlers.SubmitOnboardingAnswers)
		})

		r.Route("/plan", func(r chi.Router) {
			r.Post("/generate", handlers.GenerateFitnessPlan)
			r.Get("/{userID}", handlers.GetUserPlan)
		})
	})

	return r
}