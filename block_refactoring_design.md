# Block Refactoring Design

## Agreements & Decisions
- Workout is a series of blocks
- Block should be an abstract parent class
- Eliminate the "BlockStep" abstraction layer (unnecessary nesting)
- Create concrete block types: WarmupBlock, CooldownBlock, ExerciseBlock, RestBlock
- Remove all "*Step" classes (BlockStep, WarmupStep, CooldownStep, ExercisePrescriptionStep, RestStep)

## Current Structure (Problem)
```
Workout
  └─ List<Block>
      └─ List<BlockStep>  ← Unnecessary wrapper!
          ├─ WarmupStep
          ├─ CooldownStep
          ├─ ExercisePrescriptionStep
          └─ RestStep
```

## New Structure (Solution)
```
Workout
  └─ List<Block>  ← Block is abstract
      ├─ WarmupBlock
      ├─ CooldownBlock
      ├─ ExerciseBlock
      └─ RestBlock
```

## Plan
- [x] Create design document
- [x] Make Block an abstract parent class with common interface
- [x] Create WarmupBlock class (holds pattern + duration directly)
- [x] Create CooldownBlock class (holds pattern + duration directly)
- [x] Create ExerciseBlock class (holds exerciseId, sets, reps, rest directly)
- [x] Create RestBlock class (holds duration directly)
- [x] Update Workout class to use new block structure
- [x] Delete old step files (block_step.dart, warmup_step.dart, cooldown_step.dart, exercise_prescription_step.dart, rest_step.dart)
- [x] Update workout_session_view.dart to work with blocks directly
- [x] Update widget files (warmup_card, cooldown_card, exercise_card, rest_card) to accept blocks
- [x] Update workout_overview_card.dart to work with new block structure
- [x] Test the refactored code

## Technical Notes
- Each block type implements: `estimateDurationSec()`, `toJson()`, `fromJson()`
- Block needs a `label` field for display purposes
- Need type discrimination in JSON serialization/deserialization
- ExerciseBlock replaces the confusing "ExercisePrescriptionStep" naming

## Results
✅ **Refactoring Complete!**

- Eliminated the unnecessary `BlockStep` abstraction layer
- Simplified architecture: `Workout` → `List<Block>` (where Block is abstract parent)
- Created concrete block types: `WarmupBlock`, `CooldownBlock`, `ExerciseBlock`, `RestBlock`
- Each block IS the thing itself (no wrapper needed)
- Updated all UI widgets to work with new block structure
- All tests passing with `flutter analyze` (no errors, only pre-existing warnings)

**Key improvements:**
1. More intuitive: blocks ARE steps, not containers of steps
2. Less nesting: one less abstraction layer
3. Better naming: `ExerciseBlock` vs `ExercisePrescriptionStep`
4. Cleaner code: blocks directly contain their data
5. Type safety maintained with abstract parent + concrete subclasses
