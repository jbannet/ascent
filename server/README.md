# Fitness App Go Server

A REST API server for the Ascent Fitness Flutter application.

## Setup

1. **Install Go dependencies:**
   ```bash
   cd server
   go mod tidy
   ```

2. **Set up environment variables:**
   ```bash
   cp .env.example .env
   # Edit .env with your database credentials
   ```

3. **Run the server:**
   ```bash
   go run main.go
   ```

## API Endpoints

### Health Check
- `GET /health` - Returns server health status

### User Management
- `POST /api/user/register` - Register a new user
- `POST /api/user/login` - User login

### Onboarding
- `POST /api/onboarding/submit` - Submit onboarding survey answers

### Fitness Plans  
- `POST /api/plan/generate` - Generate a new fitness plan
- `GET /api/plan/{userID}` - Get user's fitness plan

## Models

The server models match the Flutter app's Dart models:
- `Plan` - Fitness plans with weeks and sessions
- `Session` - Individual workout sessions with blocks
- `Block` - Exercise blocks (warmup, strength, cooldown)
- `User` - User profiles and authentication

## Database

Uses PostgreSQL with the following tables:
- `users` - User accounts
- `plans` - Fitness plans  
- `sessions` - Workout sessions
- `onboarding_answers` - Survey responses