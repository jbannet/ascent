# Workout Duration Refactor

## Agreements & Decisions
- Workout should take `durationMinutes` as a parameter, not derive it from SessionType
- WarmupBlock and CooldownBlock should only store total duration, not patterns
- Remove the pattern division complexity for now (no abstraction exists for it yet)
- Keep duration calculations simple: just percentage-based allocation

## Plan
- [x] Update Workout constructor to accept `durationMinutes` parameter
- [x] Remove SessionType duration logic from Workout class
- [x] Simplify WarmupBlock to only store total duration (remove patterns)
- [x] Simplify CooldownBlock to only store total duration (remove patterns)
- [x] Update `_generateWarmupBlock()` to single-line duration calculation
- [x] Update `_generateCooldownBlock()` to single-line duration calculation
- [x] Update any calling code that creates Workout instances

## Notes
- Current code: 3-4 lines per duration calculation
- Target: 1 line per duration calculation
- Warmup = 15% of total, Cooldown = 12% of total, Main work = 73%

## Results
- WarmupBlock: Reduced from 12 lines to 1 line
- CooldownBlock: Reduced from 12 lines to 1 line
- WarmupBlock class: Reduced from 35 lines to 26 lines
- CooldownBlock class: Reduced from 35 lines to 26 lines
- Removed patterns abstraction from warmup/cooldown blocks
- Added durationMinutes to Workout constructor and JSON serialization
- Fixed all calling code:
  - week_of_workouts.dart: Added duration based on SessionType
  - workout_style_picker_view.dart: Added duration based on SessionType
  - warmup_card.dart: Simplified to show generic guidance
  - cooldown_card.dart: Simplified to show generic guidance
  - sample_plan_data.dart: Added duration to all 15 test workouts
  - plan_serialization_test.dart: Added duration to 3 test workouts
  - workout_generation_test.dart: Added duration to 5 test workouts
- All changes pass flutter analyze with 0 errors (15 info/warnings unrelated to this change)