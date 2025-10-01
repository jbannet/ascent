# Workout Generation with Time Allocations

## Agreements & Decisions

### Requirements
- Generate workouts based on WorkoutStyle (13 distinct styles)
- Support flexible duration targets (10-15 min for micro, 30-60 min for full)
- Workouts must dynamically scale to fit target duration
- Use existing Block/BlockStep architecture for workout structure

### Core Contract
```dart
List<Block> generateWorkout(WorkoutStyle style, int durationMinutes)
```
- **Input**: WorkoutStyle enum (one of 13), target duration in minutes
- **Output**: List of Block objects containing warmup, main work, and cooldown

### Technical Decisions
- Generate workouts based on WorkoutStyle (not Category)
- Each WorkoutStyle has one blueprint that scales to any duration
- Leverage existing Block.estimateDurationSec() for duration validation
- Create service with switch statement for all 13 styles
- **Exercise Schema Extension**: Add two fields to exercise database:
  - `movementPatterns: MovementPattern[]` - Array of movement patterns the exercise belongs to
  - `workoutStyles: string[]` - Array of WorkoutStyle.value strings this exercise fits (e.g., "full_body", "yoga_focused")
- Exercise selection queries by: `movementPatterns includes pattern AND workoutStyles includes style`

### Constraints
- Must work with existing Workout, Block, and BlockStep models
- Duration estimation must account for warmup, exercises, cooldown, and rest periods
- Need flexibility to expand/shrink workout volume while maintaining quality


## External Exercise Database Schema Mapping

The external exercise database uses a different schema. Here's how to map their fields to our MovementPattern system.

### Their Schema → Our System Mapping

#### Direct Field Mappings:
| Their Field | Our Field | Conversion |
|------------|-----------|------------|
| `level` | `DifficultyLevel` | "beginner" → beginner, "intermediate" → intermediate, "expert" → advanced |
| `mechanic` | `tags` | "compound" → tag: compound, "isolation" → tag: isolation |
| `equipment` | `requiredEquipment` | Direct mapping (see equipment table below) |
| `primaryMuscles` | `primaryMuscleGroups` | Direct array copy |
| `secondaryMuscles` | `secondaryMuscleGroups` | Direct array copy |
| `instructions` | `description` | Join array into single string |
| `images` | `thumbnailUrl`, `videoUrl` | First image → thumbnailUrl |

#### Equipment Mapping:
| Their Equipment | Our Equipment Tag |
|----------------|------------------|
| "body only" | bodyweight |
| "barbell" | barbell |
| "dumbbell" | dumbbell |
| "kettlebells" | kettlebell |
| "cable" | cable |
| "bands" | bands |
| "machine" | machine |
| "medicine ball" | medicine_ball |
| "exercise ball" | stability_ball |
| "e-z curl bar" | ez_bar |
| "foam roll" | foam_roller |
| "other" | other |

#### MovementPattern Inference Rules:

Use combination of `force`, `mechanic`, `primaryMuscles`, and `category` to infer MovementPattern:

| MovementPattern | Inference Rules |
|-----------------|----------------|
| **squat** | mechanic: compound AND primaryMuscles: [quadriceps OR glutes] AND force: push |
| **singleLegSquat** | mechanic: compound AND primaryMuscles: [quadriceps OR glutes] AND force: push AND name contains: ["single leg", "pistol", "step up", "step-up"] |
| **hinge** | mechanic: compound AND primaryMuscles: [hamstrings OR glutes OR lower back] AND (force: pull OR name contains: ["deadlift", "rdl", "good morning"]) |
| **singleLegHinge** | mechanic: compound AND primaryMuscles: [hamstrings OR glutes] AND name contains: ["single leg", "one leg"] |
| **lunge** | mechanic: compound AND primaryMuscles: [quadriceps OR glutes] AND name contains: ["lunge", "split squat", "bulgarian"] |
| **horizontalPush** | mechanic: compound AND primaryMuscles: [chest] AND force: push |
| **verticalPush** | mechanic: compound AND primaryMuscles: [shoulders] AND force: push AND name contains: ["overhead", "shoulder press", "military", "push press"] |
| **horizontalPull** | mechanic: compound AND (primaryMuscles: [lats OR middle back] OR secondaryMuscles: [lats OR middle back]) AND force: pull AND name contains: ["row", "inverted"] |
| **verticalPull** | mechanic: compound AND primaryMuscles: [lats] AND force: pull AND name contains: ["pull", "chin", "lat pulldown"] |
| **antiExtension** | (mechanic: compound OR isolation) AND primaryMuscles: [abdominals] AND (force: static OR name contains: ["plank", "dead bug", "ab wheel"]) |
| **antiRotation** | (mechanic: compound OR isolation) AND primaryMuscles: [abdominals] AND name contains: ["pallof", "bird dog", "anti-rotation"] |
| **antiLateralFlexion** | (mechanic: compound OR isolation) AND primaryMuscles: [abdominals] AND name contains: ["side plank", "suitcase carry"] |
| **rotation** | (mechanic: compound OR isolation) AND primaryMuscles: [abdominals] AND name contains: ["wood chop", "russian twist", "rotation"] |
| **carry** | mechanic: compound AND name contains: ["carry", "farmer", "suitcase", "overhead walk"] |
| **throw** | mechanic: compound AND category: plyometrics AND name contains: ["throw", "wall ball", "slam"] |
| **jump** | mechanic: compound AND category: plyometrics AND name contains: ["jump", "box jump", "broad jump"] |
| **crawl** | mechanic: compound AND name contains: ["crawl", "bear", "crab"] |
| **steadyStateCardio** | category: cardio AND name contains: ["run", "jog", "bike", "cycle", "row", "swim", "elliptical"] WITHOUT ["sprint", "interval", "hiit"] |
| **intervalCardio** | category: cardio AND (name contains: ["sprint", "interval", "hiit", "tabata"] OR category: plyometrics) |
| **staticStretch** | category: stretching AND force: static |
| **dynamicStretch** | category: stretching AND force: null AND name contains: ["dynamic", "swing", "circle"] |
| **mobilityDrill** | category: stretching AND name contains: ["mobility", "90/90", "hip opener", "thoracic"] |

#### Additional Tag Inference:
| Tag | Inference Rule |
|-----|---------------|
| bilateral | NOT name contains: ["single", "one arm", "one leg", "unilateral", "alternating"] |
| unilateral | name contains: ["single", "one arm", "one leg", "unilateral"] |
| alternating | name contains: ["alternating", "walking"] |
| upper | primaryMuscles contains: [chest, shoulders, lats, middle back, biceps, triceps, traps, forearms] |
| lower | primaryMuscles contains: [quadriceps, hamstrings, glutes, calves, adductors, abductors] |
| core | primaryMuscles contains: [abdominals, lower back] |
| fullBody | (upper muscles AND lower muscles) OR category: [strongman, olympic weightlifting] |
| power | category: [plyometrics, olympic weightlifting] |
| strength | category: [powerlifting, strength, strongman] |
| endurance | category: cardio |
| mobility | category: stretching |
| beginner | level: beginner |
| intermediate | level: intermediate |
| advanced | level: expert |
| low_impact | category: stretching OR (category: cardio AND NOT category: plyometrics) |
| high_impact | category: plyometrics |

### Example Conversion:

**Their Exercise:**
```json
{
  "id": "barbell-squat",
  "name": "Barbell Squat",
  "force": "push",
  "level": "intermediate",
  "mechanic": "compound",
  "equipment": "barbell",
  "primaryMuscles": ["quadriceps", "glutes"],
  "secondaryMuscles": ["hamstrings", "calves", "lower back"],
  "category": "strength"
}
```

**Our Exercise:**
```dart
Exercise(
  id: "barbell-squat",
  displayName: "Barbell Squat",
  primaryPattern: MovementPattern.squat,
  secondaryPatterns: null,
  tags: ["compound", "bilateral", "lower", "strength", "intermediate"],
  primaryMuscleGroups: ["quadriceps", "glutes"],
  secondaryMuscleGroups: ["hamstrings", "calves", "lower back"],
  requiredEquipment: ["barbell"],
  difficulty: DifficultyLevel.intermediate,
  // ... rest of fields
)
```

---

## Movement Patterns Reference

Movement patterns are the building blocks of workouts. Each workout style selects a specific combination of these patterns.

### Lower Body Patterns
- **squat** - Knee-dominant pushing movement (back squat, goblet squat, front squat, single-leg squat, pistol squat, step-ups)
- **hinge** - Hip-dominant pulling movement (deadlift, RDL, good mornings, single-leg RDL)
- **lunge** - Split stance movement (forward lunge, reverse lunge, walking lunges, Bulgarian split squat)

### Upper Body Push Patterns
- **horizontalPush** - Pressing away from chest (bench press, push-ups, dumbbell press)
- **verticalPush** - Pressing overhead (overhead press, push press, handstand push-up)

### Upper Body Pull Patterns
- **horizontalPull** - Pulling toward torso (rows: barbell, dumbbell, cable, inverted)
- **verticalPull** - Pulling from overhead (pull-ups, chin-ups, lat pulldowns)

### Core & Stability Patterns
- **antiExtension** - Resisting spinal extension (plank, dead bug, ab wheel)
- **antiRotation** - Resisting rotation (Pallof press, bird dog)
- **antiLateralFlexion** - Resisting side bend (side plank, suitcase carry)
- **rotation** - Controlled rotational movement (wood chops, Russian twists, landmine rotations)

### Functional/Athletic Patterns
- **carry** - Loaded carrying movement (farmer's walk, suitcase carry, overhead carry)
- **throw** - Throwing or explosive release (medicine ball throws, wall balls)
- **jump** - Plyometric jumping movement (box jumps, broad jumps, jump squats)
- **crawl** - Ground-based locomotion (bear crawl, crab walk)

### Cardio/Conditioning Patterns
- **steadyStateCardio** - Constant pace aerobic work (jogging, cycling, rowing)

### Mobility/Flexibility Patterns
- **staticStretch** - Holding stretch positions (hamstring stretch, quad stretch)
- **dynamicStretch** - Active stretching through movement (leg swings, arm circles)
- **mobilityDrill** - Joint mobility work (90/90 hip stretch, thoracic rotations)
---

## Complete Workout Generation Flow


---

## Movement Patterns Mapping

Maps our MovementPatterns to exercises in the external database using their schema fields.

### Lower Body Patterns
- **squat** → mechanic: compound, primaryMuscles: [quadriceps, glutes], force: push
- **hinge** → mechanic: compound, primaryMuscles: [hamstrings, glutes, lower back], force: pull
- **lunge** → mechanic: compound, primaryMuscles: [quadriceps, glutes], force: push (split stance indicator TBD)

### Upper Body Push Patterns
- **horizontalPush** → mechanic: compound, primaryMuscles: [chest], force: push
- **verticalPush** → mechanic: compound, primaryMuscles: [shoulders], force: push

### Upper Body Pull Patterns
- **horizontalPull** → mechanic: compound, primaryMuscles: [lats, middle back], force: pull
- **verticalPull** → mechanic: compound, primaryMuscles: [lats], force: pull

### Core & Stability Patterns
- **antiExtension** → primaryMuscles: [abdominals, lower back], force: static
- **antiRotation** → primaryMuscles: [abdominals, lower back] (rotation resistance indicator TBD)
- **antiLateralFlexion** → primaryMuscles: [abdominals, lower back] (lateral flexion resistance indicator TBD)
- **rotation** → primaryMuscles: [abdominals, lower back] (active rotation indicator TBD)

### Functional/Athletic Patterns
- **carry** → (carrying movement indicator TBD)
- **throw** → category: plyometrics (throwing indicator TBD)
- **jump** → category: plyometrics (jumping indicator TBD)
- **crawl** → (crawling indicator TBD)

### Cardio/Conditioning Patterns
- **steadyStateCardio** → category: cardio (steady state indicator TBD)

### Mobility/Flexibility Patterns
- **staticStretch** → category: stretching, force: static
- **dynamicStretch** → category: stretching (dynamic indicator TBD)
- **mobilityDrill** → category: stretching (mobility drill indicator TBD)

---
## Duration Scaling Rules

### General Guidelines:
- **Warmup**: 12-18% of total duration
- **Main Work**: 70-75% of total duration
- **Cooldown**: 10-12% of total duration

### Scaling Strategy:
1. **10-15 min (Micro)**:
   - Warmup: 2-3 min
   - 1-2 main exercise blocks or simplified circuits
   - Shorter rest periods (30-60s)
   - Cooldown: 1-2 min

2. **30 min**:
   - Warmup: 5 min
   - 3-4 main exercises/blocks
   - Standard rest periods (60-90s)
   - Cooldown: 3-4 min

3. **45 min (baseline)**:
   - Warmup: 6-8 min
   - Full workout as designed above
   - Standard rest periods (60-120s)
   - Cooldown: 5 min

4. **60 min (Full)**:
   - Warmup: 8-10 min
   - Add 1-2 more exercises or increase sets
   - Longer rest periods (90-180s)
   - Cooldown: 7-8 min


---

## Exercise Database Schema Extension

Each exercise is stored as a JSON file with the following schema:

```json
{
  "name": "string (required)",
  "force": "pull" | "push" | "static" | null,
  "level": "beginner" | "intermediate" | "expert",
  "mechanic": "compound" | "isolation" | null,
  "equipment": "body only" | "machine" | "kettlebells" | "dumbbell" | "cable" | "barbell" | "bands" | "medicine ball" | "exercise ball" | "e-z curl bar" | "foam roll" | null,
  "primaryMuscles": [
    "abdominals" | "hamstrings" | "calves" | "shoulders" | "adductors" | "glutes" | "quadriceps" | "biceps" | "forearms" | "abductors" | "triceps" | "chest" | "lower back" | "traps" | "middle back" | "lats" | "neck"
  ],
  "secondaryMuscles": [
    "abdominals" | "hamstrings" | "calves" | "shoulders" | "adductors" | "glutes" | "quadriceps" | "biceps" | "forearms" | "abductors" | "triceps" | "chest" | "lower back" | "traps" | "middle back" | "lats" | "neck"
  ],
  "instructions": ["string array of step-by-step instructions"],
  "category": "strength" | "cardio" | "stretching" | "plyometrics" | "strongman" | "powerlifting" | "olympic weightlifting",
  "movementPatterns": [
    "squat" | "hinge" | "lunge" | "horizontalPush" | "verticalPush" | "horizontalPull" | "verticalPull" | "antiExtension" | "antiRotation" | "antiLateralFlexion" | "rotation" | "carry" | "throw" | "jump" | "crawl" | "steadyStateCardio" | "staticStretch" | "dynamicStretch" | "mobilityDrill" | "functional_movement"
  ],
  "workoutStyles": [
    "full_body" | "upper_lower_split" | "push_pull_legs" | "concurrent_hybrid" | "circuit_metabolic" | "endurance_dominant" | "strongman_functional" | "crossfit_mixed" | "functional_movement" | "yoga_focused" | "senior_specific" | "pilates_style" | "athletic_conditioning"
  ]
}
```

### Example Exercise JSON

```json
{
  "name": "Barbell Squat",
  "force": "push",
  "level": "intermediate",
  "mechanic": "compound",
  "equipment": "barbell",
  "primaryMuscles": ["quadriceps", "glutes"],
  "secondaryMuscles": ["hamstrings", "calves", "lower back"],
  "instructions": [
    "Stand with feet shoulder-width apart",
    "Lower into a squat by bending knees and hips",
    "Keep chest up and core tight",
    "Push through heels to return to standing"
  ],
  "category": "strength",
  "movementPatterns": ["squat"],
  "workoutStyles": ["full_body", "upper_lower_split", "push_pull_legs", "concurrent_hybrid", "functional_movement"]
}
```

-------------------------------------------------------------
-------------------------------------------------------------
-------------------------------------------------------------
-------------------------------------------------------------
