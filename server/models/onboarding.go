package models

type OnboardingAnswers struct {
	UserID  string                 `json:"user_id"`
	Answers map[string]interface{} `json:"answers"`
}

type OnboardingSubmission struct {
	Answers map[string]interface{} `json:"answers"`
}