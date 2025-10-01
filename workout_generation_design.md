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

## Complete Workout Style Specifications

Each style needs concrete block definitions with deterministic scaling rules.

### Style 1: Full Body

**Movement Patterns:**
- Warmup: dynamicStretch, mobilityDrill
- Main: squat, hinge, horizontalPush, horizontalPull, verticalPush
- Cooldown: staticStretch

**Compression Strategy:**
- Pattern priority (keep these first): squat > hinge > horizontalPush > horizontalPull > verticalPush
- If under 10min: Not viable for this style
- 10-20min: Take first 2 patterns only, reduce to 2 sets
- 20-30min: Take first 4 patterns, 3 sets

---

### Style 2: Upper/Lower Split

**Movement Patterns:**
- Warmup: dynamicStretch
- Main (Lower Day): squat, lunge, hinge, antiExtension
- Main (Upper Day): horizontalPush, verticalPush, horizontalPull, verticalPull
- Cooldown: staticStretch

**Note**: Generator should alternate between upper/lower based on workout history (future enhancement)

**Compression Strategy:**
- Lower day priority: squat > hinge > lunge > antiExtension
- Upper day priority: horizontalPush > horizontalPull > verticalPush > verticalPull
- Minimum viable: 10min with 2 patterns

---

### Style 3: Push/Pull/Legs

**Movement Patterns:**
- Warmup: dynamicStretch
- Main (Push Day): horizontalPush, verticalPush, antiExtension
- Main (Pull Day): horizontalPull, verticalPull, antiRotation
- Main (Legs Day): squat, lunge, hinge
- Cooldown: staticStretch

**Note**: Generator should rotate through push/pull/legs cycle (future enhancement)

**Compression Strategy:**
- Push priority: horizontalPush > verticalPush > antiExtension
- Pull priority: horizontalPull > verticalPull > antiRotation
- Legs priority: squat > hinge > lunge

---

### Style 4: Yoga Focused

**Movement Patterns:**
- Warmup: mobilityDrill
- Main: staticStretch (majority), dynamicStretch (transitions)
- Cooldown: staticStretch

**Compression Strategy:**
- Always viable down to 5 minutes (just do 2-3 key stretches)
- Focus on major muscle groups first: hamstrings, hip flexors, shoulders, spine
- Omit smaller muscle groups (wrists, ankles, neck) when time-constrained

---

### Style 5: Circuit/Metabolic

**Movement Patterns:**
- Warmup: dynamicStretch, jump (light plyometrics)
- Main: squat, horizontalPush, horizontalPull, steadyStateCardio (arranged as circuit)
- Cooldown: staticStretch, steadyStateCardio (cool-down pace)

**Compression Strategy:**
- Circuit structure (using Block.rounds): always maintain circuit format
- Reduce rounds first (4→3→2), then exercises (4→3→2)
- High reps (15), short rest (30s) stays constant
- Minimum viable: 8min (2 exercises × 2 rounds)

---

### Style 6: Endurance Dominant

**Movement Patterns:**
- Warmup: dynamicStretch
- Main: steadyStateCardio (primary), squat, hinge, horizontalPull (supporting strength)
- Cooldown: staticStretch, steadyStateCardio (cool-down)

**Compression Strategy:**
- Cardio is always primary focus (60-70% of main work time)
- Under 15min: cardio only, no strength
- 15-30min: cardio + 1-2 strength patterns
- Strength patterns are supplementary, cut first

---

### Style 7: Strongman/Functional

**Movement Patterns:**
- Warmup: dynamicStretch, mobilityDrill
- Main: carry, hinge, throw, crawl (functional movements with heavy loads)
- Cooldown: staticStretch

**Compression Strategy:**
- Pattern priority: carry > hinge > throw > crawl
- Low reps (5), long rest (90-180s) stays constant
- Minimum viable: 12min (heavy work needs adequate rest)
- Below 12min: not appropriate for this style

---

### Style 8: CrossFit/Mixed Modal

**Movement Patterns:**
- Warmup: dynamicStretch, jump
- Main: Mixed - combine strength (squat, hinge, horizontalPush) + conditioning (jump, throw, steadyStateCardio)
- Cooldown: staticStretch

**Compression Strategy:**
- Always include conditioning element (AMRAP/EMOM format)
- Under 15min: conditioning only (AMRAP format)
- 15-30min: 2 strength movements + conditioning
- Use Block.rounds for AMRAP tracking (future: time-based tracking)

---

### Style 9: Functional Movement

**Movement Patterns:**
- Warmup: mobilityDrill, dynamicStretch
- Main: Varied - emphasize movement quality over load (squat, lunge, carry, crawl, antiRotation)
- Cooldown: staticStretch, mobilityDrill

**Compression Strategy:**
- Pattern priority: squat > lunge > carry > crawl > antiRotation
- Emphasis on bodyweight and controlled movements
- Minimum viable: 8min

---

### Style 10: Senior Specific

**Movement Patterns:**
- Warmup: mobilityDrill, staticStretch (gentle)
- Main: squat (chair-assisted), lunge (supported), staticStretch (major focus), carry (light)
- Cooldown: staticStretch, mobilityDrill

**Compression Strategy:**
- Always prioritize safety: longer warmup/cooldown relative to other styles
- Stretching is primary focus (50-70% of main work)
- Low intensity, longer rest periods
- Minimum viable: 10min (mostly stretching)

---

### Style 11: Pilates Style

**Movement Patterns:**
- Warmup: mobilityDrill
- Main: antiExtension, antiRotation, antiLateralFlexion, rotation (core-focused, controlled movements)
- Cooldown: staticStretch

**Compression Strategy:**
- Pattern priority: antiExtension > antiRotation > rotation > antiLateralFlexion
- Higher reps (12-20), short rest (30s), controlled tempo
- Minimum viable: 8min

---

### Style 12: Athletic Conditioning

**Movement Patterns:**
- Warmup: dynamicStretch, mobilityDrill
- Main: jump, throw, squat, hinge (power development)
- Cooldown: staticStretch

**Compression Strategy:**
- Always include plyometric component (jump or throw)
- Pattern priority: jump > throw > squat > hinge
- Minimum viable: 10min (power work needs adequate rest)

---

### Style 13: Concurrent/Hybrid

**Movement Patterns:**
- Warmup: dynamicStretch
- Main: Mix of strength (squat, hinge, horizontalPush) AND endurance (steadyStateCardio) within same workout
- Cooldown: staticStretch, steadyStateCardio

**Compression Strategy:**
- Balance between strength and cardio (roughly 50/50 split of main work)
- Under 15min: reduce to 1 strength pattern + short cardio
- Cardio block should be contiguous (not interspersed)

---

## Workout Generator Algorithm

### High-Level Flow

```
1. User opens workout → calls workout.generateBlocks()
2. Determine duration (micro: 12min, baseline: 45min, full: 60min based on SessionType)
3. Get movement patterns from WorkoutStyle enum (style.warmupPatterns, etc.)
4. For each pattern:
   a. Query exercises (LoadExercisesService.loadExercisesForPattern)
   b. Apply fallback if no matches
   c. Score and select best exercise
   d. Create Block with appropriate sets/reps/rest
5. Validate total duration
6. Adjust if over/under target
7. Return List<Block>
```

### Detailed Algorithm Specification

#### Step 1: Pattern Selection

```
Input: WorkoutStyle, SessionType
Output: List of patterns to use

IF SessionType == micro:
  patterns = take first N patterns from style.mainWorkPatterns (per priority)
  N depends on style (see compression strategy tables)
ELSE IF SessionType == full:
  patterns = use all patterns from style.mainWorkPatterns
ELSE (baseline):
  patterns = use most patterns, may drop lowest priority
```

#### Step 2: Exercise Query with Fallbacks

```
FOR EACH pattern in patterns:

  1. PRIMARY QUERY:
     exercises = LoadExercisesService.loadExercisesForPattern(pattern, style.value)
     WHERE movementPatterns CONTAINS pattern
       AND workoutStyles CONTAINS style.value

  2. IF exercises.isEmpty:
     FALLBACK 1: Remove style filter
     exercises = load WHERE movementPatterns CONTAINS pattern ONLY

  3. IF exercises.isEmpty:
     FALLBACK 2: Use similar pattern
     similarPatterns = {
       'squat': ['lunge'],
       'hinge': ['squat'],
       'horizontalPush': ['verticalPush'],
       'horizontalPull': ['verticalPull'],
       // etc.
     }
     exercises = load WHERE movementPatterns CONTAINS similarPatterns[pattern]

  4. IF exercises.isEmpty:
     LOG WARNING: "No exercises found for pattern ${pattern}"
     SKIP this pattern, continue to next

  5. ELSE:
     PROCEED to exercise selection
```

#### Step 3: Exercise Scoring & Selection

```
FOR EACH exercise in candidates:
  score = 0

  // Prefer compound movements
  IF exercise.mechanic == 'compound':
    score += 10

  // Match user level (future enhancement)
  IF exercise.level == userLevel:
    score += 5

  // Has instructions
  IF exercise.instructions.isNotEmpty:
    score += 3

  // Variety bonus: penalize if used recently (future enhancement)
  IF NOT in recentlyUsedExercises:
    score += 2

selectedExercise = exercise with highest score (random tiebreaker if multiple tied)
```

#### Step 4: Block Assembly

```
FOR EACH selected exercise:

  sets = style.calculateSets(durationMinutes)
  reps = style.calculateReps(durationMinutes)
  rest = style.calculateRestSeconds(durationMinutes)

  block = Block(
    label: pattern,  // e.g., "squat", "horizontalPush"
    type: BlockType.main,
    items: [
      ExercisePrescriptionStep(
        exerciseId: exercise.name,
        displayName: exercise.name,
        sets: sets,
        reps: reps,
        restSecBetweenSets: rest,
      )
    ],
    rounds: 1  // Default, unless circuit-style workout
  )

  mainBlocks.add(block)
```

**Special Case: Circuit Workouts** (circuit_metabolic, crossfit_mixed)
```
// Instead of individual blocks, create ONE block with rounds
block = Block(
  label: "Circuit",
  type: BlockType.superset,  // Or use circuit type
  items: [exercise1Step, exercise2Step, exercise3Step],
  rounds: 3,  // Repeat the circuit 3 times
  restSecBetweenRounds: 60
)
```

#### Step 5: Duration Validation & Adjustment

```
totalDuration = sum of all blocks.estimateDurationSec()
targetDuration = durationMinutes * 60

IF totalDuration > (targetDuration * 1.10):  // Over by 10%+
  ADJUSTMENT STRATEGY 1: Reduce sets
    FOR EACH mainBlock:
      mainBlock.items[0].sets -= 1
      IF mainBlock.items[0].sets < 1:
        mainBlock.items[0].sets = 1  // Don't go below 1 set

  RECALCULATE totalDuration

  IF still over target:
    ADJUSTMENT STRATEGY 2: Reduce rest periods
    FOR EACH mainBlock:
      mainBlock.items[0].restSecBetweenSets -= 15
      IF rest < 30:
        rest = 30  // Minimum 30s rest

  RECALCULATE totalDuration

  IF still over target:
    ADJUSTMENT STRATEGY 3: Remove lowest-priority pattern
    Remove last mainBlock
    RECALCULATE totalDuration

ELSE IF totalDuration < (targetDuration * 0.90):  // Under by 10%+
  // Being under target is acceptable (better to finish early)
  // Optional: could add 1 set to exercises
  LOG INFO: "Workout duration under target, acceptable"

ELSE:
  // Within 10% of target, acceptable
  LOG INFO: "Workout duration within acceptable range"
```

#### Step 6: Return Complete Workout

```
finalBlocks = [
  warmupBlock,
  ...mainBlocks,
  cooldownBlock
]

RETURN finalBlocks
```

### Error Handling

**Scenario 1: No exercises found for critical pattern**
- Example: Style requires "squat" but no squat exercises exist
- Action: Use fallback pattern (lunge), log warning
- If no fallback works: Skip pattern, continue with remaining patterns
- Minimum: Must have at least 1 main pattern to generate workout

**Scenario 2: Duration impossible to meet**
- Example: Style requires 5 patterns with 4 sets each, but only 10min available
- Action: Follow compression strategy (reduce patterns, reduce sets)
- If still impossible: Generate minimal viable workout, warn user it's shorter than requested

**Scenario 3: All exercises filtered out**
- Example: User only has dumbbells, but all exercises require barbell
- Action: Remove equipment filter, fall back to ANY equipment
- Future enhancement: Better equipment matching

---

## Implementation Files

### File Structure

```
ascent/lib/
├── models/
│   └── workout/
│       ├── exercise.dart          # Exercise data model, fromJson
│       └── workout.dart           # Workout model with generateBlocks() method
├── constants_and_enums/
│   └── workout_enums/
│       └── workout_style_enum.dart  # Extended with pattern getters and calculation methods
└── services_and_utilities/
    └── exercises/
        └── load_exercises_service.dart  # Loads exercises from assets, caches by pattern
```

### File Descriptions

**`ascent/lib/models/workout/exercise.dart`**
- Represents a single exercise with all metadata (name, force, level, mechanic, equipment, muscles, instructions, category)
- Contains movementPatterns and workoutStyles arrays
- Provides fromJson() to deserialize from JSON files

**`ascent/lib/models/workout/workout.dart`** (moved from fitness_plan/)
- Represents a workout with date, type (micro/full), style, completion status
- NEW: blocks field (List<Block>?)
- NEW: generateBlocks() method - orchestrates workout generation using style patterns and LoadExercisesService
- Contains private helper methods: _generateWarmupBlock(), _generateMainWorkBlocks(), _generateCooldownBlock(), _selectBestExercise()
- Handles JSON serialization including blocks field

**`ascent/lib/constants_and_enums/workout_enums/workout_style_enum.dart`** (extended)
- Existing enum with 13 workout styles
- NEW: Pattern getters (warmupPatterns, mainWorkPatterns, cooldownPatterns)
- NEW: Calculation methods (calculateSets, calculateReps, calculateRestSeconds)
- All style-specific logic lives here (see style specification tables above)

**`ascent/lib/services_and_utilities/exercises/load_exercises_service.dart`**
- Static service for loading exercises from assets
- Main method: loadExercisesForPattern(pattern, style) returns List<Exercise>
- Implements pattern-based caching (Map<String, List<Exercise>>)
- Scans AssetManifest.json to find all exercise.json files
- Filters exercises by movementPattern and workoutStyle
- clearCache() method for testing

---

## Dependencies & Prerequisites

### Data Prerequisites
- Exercise JSON files must have movementPatterns and workoutStyles arrays populated
- Minimum 10 exercises per movement pattern (for variety)
- Each style should have exercises available for all required patterns

### Code Prerequisites
- Block, BlockStep models exist (already implemented)
- ExercisePrescriptionStep, WarmupStep, CooldownStep exist (already implemented)
- Block.estimateDurationSec() method works correctly
- SessionType enum with micro/full values exists

### Future Enhancements (Not in Initial Implementation)
- User equipment filtering
- User difficulty level matching
- Recently-used exercise tracking (avoid repetition)
- Upper/Lower and Push/Pull/Legs rotation tracking
- Time-based AMRAP/EMOM tracking for CrossFit style
- Adaptive scaling based on user feedback

---

## Testing Strategy

### Unit Tests
- LoadExercisesService caching behavior
- WorkoutStyle enum pattern getters return correct arrays
- WorkoutStyle calculation methods return expected values for different durations

### Integration Tests
- Generate workout for each style at micro/baseline/full durations
- Verify duration is within 10% of target
- Verify all blocks have valid exercise references
- Verify fallback logic works when exercises missing

### Manual Validation
- Generate 3 workouts per style (39 total)
- Human review: "Is this a logical workout?"
- Check variety: Do different generations pick different exercises?
