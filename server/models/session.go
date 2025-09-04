package models

type Session struct {
	ID     string  `json:"id"`
	Title  string  `json:"title"`
	Blocks []Block `json:"blocks"`
}

type BlockType string

const (
	BlockTypeWarmup   BlockType = "warmup"
	BlockTypeStrength BlockType = "strength"
	BlockTypeCooldown BlockType = "cooldown"
	BlockTypeCardio   BlockType = "cardio"
)

type Block struct {
	Label                 *string     `json:"label,omitempty"`
	Type                  BlockType   `json:"type"`
	Rounds                int         `json:"rounds"`
	RestSecBetweenRounds  int         `json:"rest_sec_between_rounds"`
	Items                 []BlockStep `json:"items"`
}

type BlockStepKind string

const (
	BlockStepKindExercisePrescription BlockStepKind = "exercise_prescription"
	BlockStepKindRest                 BlockStepKind = "rest"
	BlockStepKindWarmup               BlockStepKind = "warmup"
	BlockStepKindCooldown             BlockStepKind = "cooldown"
)

type BlockStep struct {
	Kind                   BlockStepKind           `json:"kind"`
	ExercisePrescription   *ExercisePrescription   `json:"exercise_prescription,omitempty"`
	RestStep              *RestStep               `json:"rest_step,omitempty"`
	WarmupStep            *WarmupStep             `json:"warmup_step,omitempty"`
	CooldownStep          *CooldownStep           `json:"cooldown_step,omitempty"`
}

type ExercisePrescription struct {
	ExerciseName string      `json:"exercise_name"`
	RepSpec      RepSpec     `json:"rep_spec"`
	Intensity    Intensity   `json:"intensity"`
}

type RepKind string

const (
	RepKindReps     RepKind = "reps"
	RepKindTime     RepKind = "time"
	RepKindDistance RepKind = "distance"
)

type RepSpec struct {
	Kind     RepKind `json:"kind"`
	Reps     *int    `json:"reps,omitempty"`
	TimeSec  *int    `json:"time_sec,omitempty"`
	Distance *string `json:"distance,omitempty"`
}

type IntensityMode string

const (
	IntensityModeRPE        IntensityMode = "rpe"
	IntensityModePercentage IntensityMode = "percentage"
	IntensityModeWeight     IntensityMode = "weight"
)

type Intensity struct {
	Mode       IntensityMode `json:"mode"`
	RPE        *float64      `json:"rpe,omitempty"`
	Percentage *float64      `json:"percentage,omitempty"`
	Weight     *float64      `json:"weight,omitempty"`
}

type RestStep struct {
	DurationSec int `json:"duration_sec"`
}

type WarmupStep struct {
	Description string `json:"description"`
	DurationSec int    `json:"duration_sec"`
}

type CooldownStep struct {
	Description string `json:"description"`
	DurationSec int    `json:"duration_sec"`
}