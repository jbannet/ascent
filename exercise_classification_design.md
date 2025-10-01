# Exercise Classification Update

## Agreements & Decisions
- Update all 873 exercise.json files in `/Users/jonathanbannet/MyProjects/fitness_app/ascent/assets/exercises/*/exercise.json`
- Add two new fields to each exercise:
  1. `movementPatterns` (array of strings)
  2. `workoutStyles` (array of strings)
- Classifications based on existing fields: name, force, mechanic, equipment, primaryMuscles, secondaryMuscles, instructions, category
- Create summary report showing distribution and exercises with <10 count

## Movement Patterns List
- squat, hinge, lunge
- horizontalPush, verticalPush
- horizontalPull, verticalPull
- antiExtension, antiRotation, antiLateralFlexion, rotation
- carry, throw, jump, crawl
- steadyStateCardio
- staticStretch, dynamicStretch, mobilityDrill

## Workout Styles List
- full_body, upper_lower_split, push_pull_legs
- concurrent_hybrid, circuit_metabolic, endurance_dominant
- strongman_functional, crossfit_mixed, functional_movement
- yoga_focused, senior_specific, pilates_style, athletic_conditioning

## Plan
- [x] Read sample exercise.json files to understand structure
- [x] Create Python script to analyze and update all exercises
- [ ] Process all 873 exercises with classifications
- [ ] Generate summary report
- [ ] Verify updates were successful

## Notes
- Will use intelligent classification based on exercise characteristics
- Multiple patterns/styles can apply to a single exercise
- Summary will highlight underrepresented categories
