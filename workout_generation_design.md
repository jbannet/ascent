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
- Use placeholder exercise IDs (no exercise database yet)
- Create service with switch statement for all 13 styles

### Constraints
- Must work with existing Workout, Block, and BlockStep models
- Duration estimation must account for warmup, exercises, cooldown, and rest periods
- Need flexibility to expand/shrink workout volume while maintaining quality
- No exercise database exists yet - use descriptive exercise IDs

## Plan

### Phase 1: Design & Documentation
- [x] Create workout_generation_design.md
- [ ] Document all 13 WorkoutStyle blueprints with specific exercises, sets, reps, duration allocations

### Phase 2: Model Updates
- [ ] Add `List<Block>? blocks` property to Workout model
- [ ] Update Workout JSON serialization (fromJson/toJson)
- [ ] Ensure backward compatibility

### Phase 3: Core Generation Service
- [ ] Create WorkoutGeneratorService (`/ascent/lib/services/workout_generator_service.dart`)
- [ ] Implement `generateWorkout(WorkoutStyle style, int durationMinutes)`
- [ ] Create private builder method for each of 13 styles
- [ ] Implement duration scaling logic

### Phase 4: Integration
- [ ] Update WeekOfWorkouts.fromProfile() to call generator
- [ ] Determine duration from SessionType (micro ≈ 12 min, full ≈ 45 min)
- [ ] Populate blocks property on each Workout

### Phase 5: Testing
- [ ] Create unit tests for all 13 WorkoutStyles
- [ ] Verify duration estimation matches targets
- [ ] Test micro and full session generation
- [ ] Validate Block structure (warmup + main + cooldown)

## WorkoutStyle Blueprints

Each blueprint defines the structure for one WorkoutStyle. All durations are guidelines that scale proportionally.

### 1. Full Body (fullBody)
**Philosophy**: Hit all major muscle groups in one session with compound movements

**Structure (45 min example)**:
- Warmup (8 min): Dynamic stretching, joint mobility (hips, shoulders, spine)
- Main Work (32 min):
  - Squat Pattern: Goblet Squat or Barbell Squat - 4 sets x 8-10 reps, 90s rest
  - Horizontal Push: Push-ups or Bench Press - 3 sets x 8-12 reps, 75s rest
  - Horizontal Pull: Rows - 3 sets x 10-12 reps, 75s rest
  - Hinge Pattern: Romanian Deadlift - 3 sets x 8-10 reps, 90s rest
  - Core: Plank variations - 3 sets x 30-45s, 45s rest
- Cooldown (5 min): Static stretching (quads, hamstrings, chest, back)

**Scaling**:
- 10-15 min: Warmup 2min, 2 exercises (squat + push), 3 sets each, 60s rest, cooldown 2min
- 30 min: Warmup 5min, 3 exercises, 3 sets each, 75s rest, cooldown 3min
- 60 min: Warmup 10min, 5 exercises, 4-5 sets each, 120s rest, cooldown 8min

---

### 2. Upper/Lower Split (upperLowerSplit)
**Philosophy**: Separate upper and lower body training (alternates between the two)

**Upper Day Structure (45 min)**:
- Warmup (7 min): Shoulder mobility, scapular activation, band pull-aparts
- Main Work (33 min):
  - Overhead Press - 4 sets x 6-8 reps, 120s rest
  - Pull-ups or Lat Pulldowns - 4 sets x 8-10 reps, 90s rest
  - Incline Dumbbell Press - 3 sets x 10-12 reps, 75s rest
  - Dumbbell Rows - 3 sets x 10-12 reps, 75s rest
  - Bicep Curls - 3 sets x 12-15 reps, 60s rest
  - Tricep Extensions - 3 sets x 12-15 reps, 60s rest
- Cooldown (5 min): Upper body stretching

**Lower Day Structure (45 min)**:
- Warmup (7 min): Hip mobility, glute activation, leg swings
- Main Work (33 min):
  - Back Squat or Front Squat - 4 sets x 6-8 reps, 150s rest
  - Romanian Deadlift - 4 sets x 8-10 reps, 120s rest
  - Walking Lunges - 3 sets x 12 steps per leg, 75s rest
  - Leg Curls - 3 sets x 12-15 reps, 60s rest
  - Calf Raises - 4 sets x 15-20 reps, 45s rest
- Cooldown (5 min): Lower body stretching

**Scaling**: Reduce exercises (upper: 3 main lifts, lower: 3 main lifts) for shorter durations

---

### 3. Push/Pull/Legs (pushPullLegs)
**Philosophy**: 3-way split focusing on push muscles, pull muscles, or legs

**Push Day (45 min)**:
- Warmup (7 min): Shoulder/chest warmup
- Main Work (33 min):
  - Bench Press - 4 sets x 6-8 reps, 120s rest
  - Overhead Press - 4 sets x 8-10 reps, 90s rest
  - Incline Dumbbell Press - 3 sets x 10-12 reps, 75s rest
  - Lateral Raises - 3 sets x 12-15 reps, 60s rest
  - Tricep Dips - 3 sets x 8-12 reps, 75s rest
  - Overhead Tricep Extension - 3 sets x 12-15 reps, 60s rest
- Cooldown (5 min): Push muscle stretching

**Pull Day (45 min)**:
- Warmup (7 min): Back/bicep warmup, scapular work
- Main Work (33 min):
  - Deadlift - 4 sets x 5-6 reps, 180s rest
  - Pull-ups - 4 sets x 6-10 reps, 90s rest
  - Barbell Rows - 3 sets x 8-10 reps, 90s rest
  - Face Pulls - 3 sets x 15-20 reps, 60s rest
  - Barbell Curls - 3 sets x 10-12 reps, 75s rest
  - Hammer Curls - 3 sets x 12-15 reps, 60s rest
- Cooldown (5 min): Pull muscle stretching

**Leg Day (45 min)**:
- Warmup (7 min): Hip mobility, ankle mobility, activation
- Main Work (33 min):
  - Squat - 4 sets x 6-8 reps, 150s rest
  - Romanian Deadlift - 4 sets x 8-10 reps, 120s rest
  - Leg Press - 3 sets x 12-15 reps, 90s rest
  - Leg Curls - 3 sets x 12-15 reps, 60s rest
  - Bulgarian Split Squats - 3 sets x 10-12 per leg, 75s rest
  - Calf Raises - 4 sets x 15-20 reps, 45s rest
- Cooldown (5 min): Leg stretching

---

### 4. Concurrent/Hybrid (concurrentHybrid)
**Philosophy**: Mix strength and cardio in the same session

**Structure (45 min)**:
- Warmup (6 min): Dynamic warmup with movement prep
- Main Work (34 min):
  - Strength Block 1: Squat - 3 sets x 8 reps, 90s rest
  - Cardio Block 1: Running/Rowing intervals - 5 min (30s hard / 30s easy)
  - Strength Block 2: Push-ups - 3 sets x 12 reps, 60s rest
  - Cardio Block 2: Jump rope or burpees - 4 min (20s on / 40s off)
  - Strength Block 3: Kettlebell Swings - 3 sets x 15 reps, 60s rest
  - Cardio Block 3: Bike sprints - 4 min (15s sprint / 45s recovery)
- Cooldown (5 min): Light cardio + stretching

**Scaling**: Alternate 1 strength exercise + 1 cardio burst throughout duration

---

### 5. Circuit/Metabolic (circuitMetabolic)
**Philosophy**: High-intensity circuits with minimal rest for metabolic conditioning

**Structure (45 min)**:
- Warmup (5 min): Dynamic movements, get heart rate up
- Main Work (35 min):
  - Circuit 1 (3 rounds): Kettlebell Swings x15, Push-ups x12, Box Jumps x10, Mountain Climbers x20, 60s rest between rounds
  - Rest 2 min
  - Circuit 2 (3 rounds): Thrusters x12, Burpees x10, Medicine Ball Slams x15, Plank x45s, 60s rest between rounds
  - Rest 2 min
  - Circuit 3 (3 rounds): Jump Squats x15, Dumbbell Rows x12 per arm, Battle Ropes x30s, Bicycle Crunches x20, 60s rest between rounds
- Cooldown (5 min): Walk down, stretching

**Scaling**:
- 10-15 min: 1 circuit, 3 rounds
- 30 min: 2 circuits, 3 rounds each
- 60 min: 4-5 circuits, 3-4 rounds each

---

### 6. Endurance Dominant (enduranceDominant)
**Philosophy**: Focus on cardiovascular endurance with sustained efforts

**Structure (45 min)**:
- Warmup (5 min): Progressive build from walk to easy jog
- Main Work (35 min):
  - Steady State Zone 2: 15 min at conversational pace (running, cycling, rowing)
  - Tempo Intervals: 4x 3 min at threshold pace, 2 min easy recovery between
  - Cool Jog: 5 min easy
- Cooldown (5 min): Walking, light stretching

**Scaling**:
- 10-15 min: Warmup 2min, 8-10min steady state, cooldown 2min
- 30 min: Warmup 4min, 22min mixed steady + intervals, cooldown 4min
- 60 min: Warmup 8min, 45min progressive long run with tempo, cooldown 7min

---

### 7. Strongman/Functional (strongmanFunctional)
**Philosophy**: Odd-object lifting, carries, and real-world strength movements

**Structure (45 min)**:
- Warmup (7 min): Movement prep, grip work
- Main Work (33 min):
  - Farmer's Carries - 4 sets x 40m, 90s rest
  - Atlas Stone Lifts (or Sandbag) - 4 sets x 5 reps, 120s rest
  - Sled Push/Pull - 4 sets x 30m, 90s rest
  - Yoke Walk - 3 sets x 20m, 120s rest
  - Tire Flips - 3 sets x 8 flips, 90s rest
- Cooldown (5 min): Mobility work

**Scaling**: Reduce number of events for shorter durations (2-3 events for micro)

---

### 8. CrossFit/Mixed Modal (crossfitMixed)
**Philosophy**: Constantly varied functional movements at high intensity

**Structure (45 min)**:
- Warmup (8 min): General warmup + specific skill work
- Main Work (32 min):
  - Strength: Back Squat - Work up to heavy 5 reps (12 min)
  - WOD (Workout of the Day): AMRAP 15 min:
    - 5 Pull-ups
    - 10 Push-ups
    - 15 Air Squats
- Cooldown (5 min): Stretching, breathing

**Scaling**: Adjust strength work time and WOD duration proportionally

---

### 9. Functional Movement (functionalMovement)
**Philosophy**: Natural movement patterns, mobility, and movement quality

**Structure (45 min)**:
- Warmup (8 min): Joint mobility sequence (ankles, hips, thoracic, shoulders)
- Main Work (32 min):
  - Crawling Patterns - 3 sets x 2 min, 60s rest
  - Turkish Get-ups - 3 sets x 3 per side, 90s rest
  - Single-leg Deadlift - 3 sets x 8 per leg, 75s rest
  - Bear Crawl to Push-up - 3 sets x 8 reps, 60s rest
  - Loaded Carries (various) - 3 sets x 40m, 75s rest
  - Ground-to-stand transitions - 3 sets x 5 reps, 60s rest
- Cooldown (5 min): Mobility flows

---

### 10. Yoga-Focused (yogaFocused)
**Philosophy**: Yoga-based practice with poses, flows, and breath work

**Structure (45 min)**:
- Warmup (7 min): Pranayama (breathing), gentle seated stretches
- Main Work (33 min):
  - Sun Salutation A - 5 rounds, flowing
  - Standing Sequence: Warrior I, II, Triangle, each side, 60s holds
  - Balance Series: Tree pose, Half Moon, each side, 45s holds
  - Floor Sequence: Pigeon pose, Seated Forward Fold, Supine Twist, 90-120s holds
  - Inversions: Downward Dog, Shoulder Stand, or Headstand practice - 3-5 min
- Cooldown (5 min): Savasana (corpse pose) with guided relaxation

**Scaling**: Reduce hold times and number of pose variations for shorter sessions

---

### 11. Senior-Specific (seniorSpecific)
**Philosophy**: Focus on functional fitness, fall prevention, balance, and joint health

**Structure (45 min)**:
- Warmup (8 min): Gentle joint mobility, seated/standing movements
- Main Work (32 min):
  - Chair-assisted Squats - 3 sets x 10 reps, 60s rest
  - Wall Push-ups - 3 sets x 12 reps, 60s rest
  - Standing Marches - 3 sets x 20 per leg, 45s rest
  - Single-leg Stands (with support) - 3 sets x 30s per leg, 45s rest
  - Seated Rows (bands) - 3 sets x 12 reps, 60s rest
  - Heel-to-Toe Walk - 3 sets x 10 steps, 45s rest
  - Sit-to-Stand - 3 sets x 10 reps, 60s rest
- Cooldown (5 min): Gentle stretching, breathing exercises

**Scaling**: Focus on 3-4 key movements for micro, ensure safety and proper form

---

### 12. Pilates Style (pilatesStyle)
**Philosophy**: Core-focused, controlled movements emphasizing mind-muscle connection

**Structure (45 min)**:
- Warmup (6 min): Breathing exercises, pelvic tilts, spinal articulation
- Main Work (34 min):
  - Hundred - 3 sets, 60s rest
  - Roll-ups - 3 sets x 8 reps, 60s rest
  - Single Leg Stretch - 3 sets x 10 per leg, 45s rest
  - Double Leg Stretch - 3 sets x 10 reps, 45s rest
  - Spine Stretch Forward - 3 sets x 8 reps, 45s rest
  - Swan/Back Extension - 3 sets x 8 reps, 60s rest
  - Side Leg Series - 2 sets x 10 per exercise per leg, 30s rest
  - Teaser - 3 sets x 6 reps, 60s rest
- Cooldown (5 min): Child's pose, spinal twists, relaxation

---

### 13. Athletic Conditioning (athleticConditioning)
**Philosophy**: Sport-specific conditioning with power, speed, and agility

**Structure (45 min)**:
- Warmup (8 min): Dynamic warmup, activation drills, movement prep
- Main Work (32 min):
  - Power: Box Jumps - 4 sets x 5 reps, 90s rest
  - Speed: Sprint intervals - 6x 40m, walk back recovery
  - Agility: Cone drills (5-10-5 shuttle) - 5 sets, 90s rest
  - Plyometrics: Broad Jumps - 4 sets x 5 reps, 75s rest
  - Conditioning: Sled sprints - 6 sets x 20m, 90s rest
  - Power Endurance: Medicine ball throws - 3 sets x 10 reps, 60s rest
- Cooldown (5 min): Light jog, dynamic stretching

**Scaling**: Reduce number of drills and sets for shorter durations

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

## Template System Architecture

### Overview
Instead of hardcoding specific exercises, we use a **template system** that defines workout structure abstractly, then fills slots with exercises from a database based on criteria matching.

### Core Components

#### 1. WorkoutTemplate (Abstract Structure)
Defines the high-level structure of a workout without specifying exact exercises.

```dart
class WorkoutTemplate {
  final WorkoutStyle style;
  final String? variation;              // 'upper', 'lower', 'push', 'pull', 'legs', etc.
  final WarmupTemplate warmup;
  final List<ExerciseSlot> exerciseSlots;
  final CooldownTemplate cooldown;
  final ScalingRules scalingRules;
}
```

#### 2. ExerciseSlot (Criteria-based Placeholder)
Describes what KIND of exercise should go here, not which specific one.

```dart
class ExerciseSlot {
  // Selection Criteria
  final MovementPattern? primaryPattern;     // e.g., squat, hinge, horizontalPush
  final List<MovementPattern>? secondaryPatterns; // alternatives
  final List<String> requiredTags;           // e.g., ['compound', 'bilateral']
  final List<String>? optionalTags;          // nice-to-have tags
  final List<String>? excludeTags;           // avoid these
  final List<String> targetMuscleGroups;     // primary muscles worked
  final EquipmentPreference equipmentPref;   // preferred, required, or avoided equipment
  final DifficultyRange? difficultyRange;    // min/max difficulty

  // Prescription (how to perform)
  final PrescriptionTemplate prescription;

  // Slot metadata
  final String label;                        // e.g., "Main Squat Movement"
  final int priority;                        // 1=essential, 2=important, 3=optional (for scaling)
}

class PrescriptionTemplate {
  final int sets;
  final RepScheme repScheme;                 // fixed number, range, or time-based
  final int restSecBetweenSets;
  final String? tempo;                       // e.g., "3-1-1-0"
  final List<String>? cues;                  // coaching cues
}

enum RepScheme {
  fixedReps(int reps),
  repRange(int min, int max),
  timeBased(int seconds),
  amrap(),                                   // as many reps as possible
  rpe(int targetRPE),                        // rate of perceived exertion
}
```

#### 3. Movement Patterns (Taxonomy)
Define standardized movement patterns for exercise classification.

```dart
enum MovementPattern {
  // Lower Body
  squat,                    // bilateral knee-dominant
  singleLegSquat,          // unilateral knee-dominant
  hinge,                   // hip-dominant (deadlift, RDL)
  singleLegHinge,          // single leg RDL, etc.
  lunge,                   // split stance patterns

  // Upper Body Push
  horizontalPush,          // bench press, push-ups
  verticalPush,            // overhead press

  // Upper Body Pull
  horizontalPull,          // rows
  verticalPull,            // pull-ups, lat pulldowns

  // Core & Stability
  antiExtension,           // plank, dead bug
  antiRotation,            // pallof press
  antiLateralFlexion,      // side plank
  rotation,                // wood chops

  // Functional/Athletic
  carry,                   // farmer's walks, suitcase carries
  throw,                   // medicine ball throws
  jump,                    // plyometrics
  crawl,                   // ground-based movement

  // Cardio/Conditioning
  steadyStateCardio,       // running, cycling at constant pace
  intervalCardio,          // HIIT, sprints

  // Mobility/Flexibility
  staticStretch,
  dynamicStretch,
  mobilityDrill,
}
```

#### 4. Exercise Tagging System
Standardized tags for filtering and matching exercises.

**Complexity Tags:**
- `compound` - Multi-joint movements
- `isolation` - Single-joint movements

**Limb Usage:**
- `bilateral` - Both limbs (back squat)
- `unilateral` - One limb (single-leg squat, single-arm row)
- `alternating` - Alternating sides (walking lunges)

**Body Region:**
- `upper` - Upper body dominant
- `lower` - Lower body dominant
- `core` - Core focused
- `fullBody` - Engages entire body

**Training Quality:**
- `power` - Explosive, max speed
- `strength` - Heavy resistance, lower reps
- `hypertrophy` - Muscle building focus
- `endurance` - Higher reps, sustained effort
- `mobility` - Range of motion focus
- `balance` - Stability challenge
- `coordination` - Complex movement patterns

**Equipment:**
- `barbell`, `dumbbell`, `kettlebell`, `cable`, `bands`
- `bodyweight`, `trx`, `rings`
- `machine`, `smith_machine`
- `cardio_equipment` (treadmill, bike, rower)
- `none` (no equipment needed)

**Safety/Experience:**
- `beginner` - Safe for novices
- `intermediate` - Requires some experience
- `advanced` - High skill requirement
- `requires_spotting` - Safety consideration

**Special Considerations:**
- `low_impact` - Joint-friendly
- `high_impact` - Jumping, plyometric
- `balance_challenge` - Stability required
- `grip_intensive` - Forearm/grip limiting

#### 5. Exercise Database Model

```dart
class Exercise {
  final String id;                          // unique identifier
  final String displayName;                 // "Barbell Back Squat"
  final String? commonName;                 // "Squat"
  final String description;

  // Classification
  final MovementPattern primaryPattern;
  final List<MovementPattern>? secondaryPatterns;
  final List<String> tags;
  final List<String> primaryMuscleGroups;   // main muscles
  final List<String> secondaryMuscleGroups; // synergists

  // Requirements
  final List<String> requiredEquipment;     // what you MUST have
  final List<String>? optionalEquipment;    // useful but not required
  final DifficultyLevel difficulty;
  final SpaceRequirement spaceNeeded;       // minimal, standard, large

  // Safety & Contraindications
  final List<String>? contraindications;    // injuries/conditions to avoid
  final bool requiresSpotting;

  // Media
  final String? videoUrl;
  final String? thumbnailUrl;
  final String? instructionUrl;

  // Variations & Progressions
  final String? easierVariation;            // regression
  final String? harderVariation;            // progression
  final List<String>? alternatives;         // similar exercises

  // Metadata
  final DateTime createdAt;
  final DateTime updatedAt;
  final int popularityScore;                // for ranking
}

enum DifficultyLevel {
  beginner,
  intermediate,
  advanced,
  elite,
}

enum SpaceRequirement {
  minimal,      // Can do in place
  standard,     // 6x6 ft
  large,        // Full gym space
}
```

#### 6. Exercise Selection Algorithm

```dart
class ExerciseSelector {
  Exercise selectExercise(
    ExerciseSlot slot,
    ExerciseDatabase database,
    UserContext context,
  ) {
    // Step 1: Filter by hard requirements
    var candidates = database.exercises.where((ex) {
      // Movement pattern match
      if (slot.primaryPattern != null &&
          ex.primaryPattern != slot.primaryPattern &&
          !ex.secondaryPatterns.contains(slot.primaryPattern)) {
        return false;
      }

      // Required tags
      if (!slot.requiredTags.every((tag) => ex.tags.contains(tag))) {
        return false;
      }

      // Excluded tags
      if (slot.excludeTags?.any((tag) => ex.tags.contains(tag)) ?? false) {
        return false;
      }

      // Equipment availability
      if (!context.hasEquipment(ex.requiredEquipment)) {
        return false;
      }

      // Difficulty range
      if (slot.difficultyRange != null &&
          !slot.difficultyRange.contains(ex.difficulty)) {
        return false;
      }

      // User contraindications (injuries, etc.)
      if (context.hasContraindication(ex.contraindications)) {
        return false;
      }

      return true;
    }).toList();

    // Step 2: Score remaining candidates
    candidates = candidates.map((ex) {
      double score = 0;

      // Prefer exercises matching target muscle groups
      final muscleOverlap = slot.targetMuscleGroups
          .where((mg) => ex.primaryMuscleGroups.contains(mg))
          .length;
      score += muscleOverlap * 10;

      // Prefer optional tags if present
      final optionalTagMatch = slot.optionalTags
          ?.where((tag) => ex.tags.contains(tag))
          .length ?? 0;
      score += optionalTagMatch * 5;

      // Prefer equipment user likes
      score += context.equipmentPreferenceScore(ex.requiredEquipment);

      // Variety bonus: penalize recently used exercises
      if (context.recentlyUsed(ex.id)) {
        score -= 20;
      }

      // Popularity/quality signal
      score += ex.popularityScore * 0.1;

      return (exercise: ex, score: score);
    }).toList();

    // Step 3: Sort by score and pick top candidate
    candidates.sort((a, b) => b.score.compareTo(a.score));

    if (candidates.isEmpty) {
      throw NoSuitableExerciseException(slot);
    }

    return candidates.first.exercise;
  }
}

class UserContext {
  final List<String> availableEquipment;
  final List<String> injuries;
  final DifficultyLevel experienceLevel;
  final List<String> recentExerciseIds;  // for variety
  final Map<String, double> equipmentPreferences;

  bool hasEquipment(List<String> required) { /* ... */ }
  bool hasContraindication(List<String>? contraindications) { /* ... */ }
  double equipmentPreferenceScore(List<String> equipment) { /* ... */ }
  bool recentlyUsed(String exerciseId) { /* ... */ }
}
```

#### 7. Scaling Rules

How templates adapt to different durations.

```dart
class ScalingRules {
  final DurationBreakpoints breakpoints;
  final Map<String, ScalingStrategy> strategies;
}

class DurationBreakpoints {
  final int micro;      // 10-15 min
  final int short;      // 20-25 min
  final int standard;   // 40-50 min
  final int long;       // 55-65 min
}

enum ScalingStrategy {
  // For micro: keep only priority 1 slots
  priorityFilter,

  // Reduce sets proportionally
  reduceSets,

  // Reduce rest periods
  reduceRest,

  // Combine slots into supersets/circuits
  combineSlots,

  // For long: add more sets
  addSets,

  // For long: add more exercises
  addSlots,
}
```

### Example: Full Body Template

```dart
final fullBodyTemplate = WorkoutTemplate(
  style: WorkoutStyle.fullBody,
  variation: null,
  warmup: WarmupTemplate(
    durationPercent: 0.15,
    activities: ['dynamic_stretching', 'joint_mobility'],
  ),
  exerciseSlots: [
    ExerciseSlot(
      label: "Main Squat Pattern",
      priority: 1,  // Essential
      primaryPattern: MovementPattern.squat,
      requiredTags: ['compound', 'bilateral', 'lower'],
      targetMuscleGroups: ['quads', 'glutes'],
      equipmentPref: EquipmentPreference.preferred(['barbell', 'dumbbell']),
      prescription: PrescriptionTemplate(
        sets: 4,
        repScheme: RepScheme.repRange(8, 10),
        restSecBetweenSets: 90,
      ),
    ),
    ExerciseSlot(
      label: "Horizontal Push",
      priority: 1,
      primaryPattern: MovementPattern.horizontalPush,
      requiredTags: ['compound', 'upper'],
      targetMuscleGroups: ['chest', 'triceps', 'anterior_delt'],
      equipmentPref: EquipmentPreference.any(),
      prescription: PrescriptionTemplate(
        sets: 3,
        repScheme: RepScheme.repRange(8, 12),
        restSecBetweenSets: 75,
      ),
    ),
    ExerciseSlot(
      label: "Horizontal Pull",
      priority: 1,
      primaryPattern: MovementPattern.horizontalPull,
      requiredTags: ['compound', 'upper'],
      targetMuscleGroups: ['lats', 'rhomboids', 'biceps'],
      equipmentPref: EquipmentPreference.any(),
      prescription: PrescriptionTemplate(
        sets: 3,
        repScheme: RepScheme.repRange(10, 12),
        restSecBetweenSets: 75,
      ),
    ),
    ExerciseSlot(
      label: "Hip Hinge",
      priority: 2,  // Important but can drop for micro
      primaryPattern: MovementPattern.hinge,
      requiredTags: ['compound', 'lower'],
      targetMuscleGroups: ['hamstrings', 'glutes', 'lower_back'],
      equipmentPref: EquipmentPreference.preferred(['barbell', 'dumbbell']),
      prescription: PrescriptionTemplate(
        sets: 3,
        repScheme: RepScheme.repRange(8, 10),
        restSecBetweenSets: 90,
      ),
    ),
    ExerciseSlot(
      label: "Core Stability",
      priority: 2,
      primaryPattern: MovementPattern.antiExtension,
      requiredTags: ['core', 'stability'],
      targetMuscleGroups: ['abs', 'obliques'],
      equipmentPref: EquipmentPreference.bodyweightFirst(),
      prescription: PrescriptionTemplate(
        sets: 3,
        repScheme: RepScheme.timeBased(45),
        restSecBetweenSets: 45,
      ),
    ),
  ],
  cooldown: CooldownTemplate(
    durationPercent: 0.10,
    activities: ['static_stretching', 'breath_work'],
  ),
  scalingRules: ScalingRules(
    breakpoints: DurationBreakpoints(
      micro: 12,
      short: 25,
      standard: 45,
      long: 60,
    ),
    strategies: {
      'micro': [ScalingStrategy.priorityFilter, ScalingStrategy.reduceSets],
      'long': [ScalingStrategy.addSets],
    },
  ),
);
```

### Example: Upper/Lower Split Templates

```dart
final upperLowerTemplates = [
  WorkoutTemplate(
    style: WorkoutStyle.upperLowerSplit,
    variation: 'upper',
    exerciseSlots: [
      ExerciseSlot(
        label: "Vertical Push",
        primaryPattern: MovementPattern.verticalPush,
        requiredTags: ['compound', 'upper'],
        targetMuscleGroups: ['delts', 'triceps'],
        // ...
      ),
      ExerciseSlot(
        label: "Vertical Pull",
        primaryPattern: MovementPattern.verticalPull,
        requiredTags: ['compound', 'upper'],
        targetMuscleGroups: ['lats', 'biceps'],
        // ...
      ),
      // ... more upper body slots
    ],
  ),
  WorkoutTemplate(
    style: WorkoutStyle.upperLowerSplit,
    variation: 'lower',
    exerciseSlots: [
      ExerciseSlot(
        label: "Squat Pattern",
        primaryPattern: MovementPattern.squat,
        requiredTags: ['compound', 'bilateral', 'lower'],
        targetMuscleGroups: ['quads', 'glutes'],
        // ...
      ),
      ExerciseSlot(
        label: "Hinge Pattern",
        primaryPattern: MovementPattern.hinge,
        requiredTags: ['compound', 'lower'],
        targetMuscleGroups: ['hamstrings', 'glutes'],
        // ...
      ),
      // ... more lower body slots
    ],
  ),
];
```

## Template → Workout Generation Flow

```
1. Select WorkoutTemplate based on WorkoutStyle (and variation if applicable)
2. Determine target duration → apply scaling rules to template
3. For each ExerciseSlot in scaled template:
   a. Query exercise database with slot criteria
   b. Filter by user context (equipment, injuries, preferences)
   c. Score candidates
   d. Select best match
4. Build Block structures:
   a. Warmup Block (from WarmupTemplate)
   b. Main Exercise Blocks (from selected exercises + prescriptions)
   c. Cooldown Block (from CooldownTemplate)
5. Validate total duration with Block.estimateDurationSec()
6. Return List<Block>
```

## Open Design Questions

### 1. Multi-day Variation Selection
For styles like Upper/Lower Split and Push/Pull/Legs that have multiple variations:
- **Option A**: Store separate templates with variation names, select randomly or in sequence
- **Option B**: Single template with conditional slots that activate based on day/context
- **Recommendation**: Option A (simpler, more explicit)

### 2. Exercise Database Seeding
Where/how to initially populate the exercise database:
- **Option A**: JSON/YAML files in assets, loaded at startup
- **Option B**: Hardcoded Dart lists as initial seed data
- **Option C**: Cloud database with local caching
- **Recommendation**: Start with Option A for flexibility

### 3. User Exercise History
Track which exercises were used recently for variety:
- Store last N workouts with exercise IDs
- Penalize exercises used in last 2-3 workouts
- Reset variety constraints after certain time period

### 4. Template Versioning
How to handle updates to templates over time:
- Version templates so user workouts remain consistent
- Allow A/B testing of different template structures
- Migration strategy when templates change

### 5. Custom Templates
Should users eventually create custom workout templates?
- Future feature consideration
- Would require UI for template builder
- Not in initial scope

## Next Steps
1. Finalize movement pattern taxonomy
2. Define complete tag vocabulary
3. Create initial exercise database schema
4. Implement template data structures
5. Build exercise selection algorithm
6. Create seed exercise database (even if small initially)
7. Implement workout generation with template + database
