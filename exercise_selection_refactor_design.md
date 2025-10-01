# Exercise Selection Refactor

## Problem
`_selectBestExercise()` had hardcoded compound preference logic. Compound vs isolation should be specified per movement pattern in the workout template, not in the Workout class.

## Solution Implemented

### 1. Created PatternWithPreference class
**File:** `lib/constants_and_enums/workout_enums/pattern_with_preference.dart`
- Pairs MovementPattern with optional compound/isolation preference
- `preferCompound`: true = compound, false = isolation, null = no preference

### 2. Updated WorkoutStyle template
**File:** `lib/constants_and_enums/workout_enums/workout_style_enum.dart`
- Changed `mainWorkPatterns` from `List<MovementPattern>` to `List<PatternWithPreference>`
- Defined compound/isolation preference for each pattern in all 13 workout styles
- Examples:
  - Circuit Metabolic: all compound movements
  - Pilates: all isolation core work
  - Full Body: mix of compound and isolation
  - Endurance Dominant: compound squats, isolation hinges

### 3. Updated LoadExercisesService
**File:** `lib/services_and_utilities/exercises/load_exercises_service.dart`
- Added optional `preferCompound` parameter to `getExercises()`
- Filters exercises by mechanic (compound/isolation) when preference specified
- Falls back to all exercises if filtered list is empty

### 4. Updated Workout class
**File:** `lib/models/workout/workout.dart`
- Added `dart:math` import for Random
- Updated `_generateMainWorkBlocks()` to:
  - Use `PatternWithPreference` instead of `MovementPattern`
  - Pass `preferCompound` to service
  - Select random exercise from filtered list
- **Removed `_selectBestExercise()` - 20 lines of complex scoring logic deleted**

## Benefits
- ✅ Compound/isolation logic moved to template (where it belongs)
- ✅ Service handles filtering (single responsibility)
- ✅ Random exercise selection adds workout variety
- ✅ Graceful fallback if no exercises match preference
- ✅ Removed 20 lines of complex scoring code
- ✅ More granular control (e.g., compound squats + isolation hinges in same workout)

## Results
- All tests pass
- 0 errors in flutter analyze
- Cleaner separation of concerns
- Template now has full control over exercise selection criteria
