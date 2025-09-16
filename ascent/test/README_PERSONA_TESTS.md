# Onboarding Persona Distribution Test Suite

## Overview

This test suite runs 25 diverse user personas through the onboarding flow to analyze the distribution of fitness allocations and ensure the system behaves correctly across different user types.

## Files

- `onboarding_personas_test.dart` - Main test harness and allocation calculation logic
- `persona_definitions.dart` - 25 pre-defined personas with realistic data
- `results/` - Generated test outputs (created when tests run)
- `onboarding_workflow/` - Widget tests for UI components (moved from tests/)
- `fitness_plan/` - Fitness plan test data (moved from tests/)

## Personas Included

### Critical Medical Conditions (5)
1. **elderly_fall_history** - 75yo with fall history → Fall History Protocol
2. **cannot_stand_chair** - 68yo cannot stand from chair → Chair Stand Protocol
3. **glp1_obesity** - 45yo on GLP-1 with obesity → GLP-1 Protocol
4. **extreme_obesity** - 38yo BMI 42 → Extreme Obesity Protocol
5. **multiple_conditions** - 70yo fall history + obesity → Fall History Priority

### Age-Based Profiles (5)
6. **young_athlete** - 25yo competitive athlete
7. **middle_aged_beginner** - 42yo sedentary starter
8. **active_senior** - 68yo regular walker
9. **frail_elderly** - 82yo minimal activity
10. **teen_starter** - 16yo no fitness background

### Fitness Level Variants (5)
11. **deconditioned_adult** - 35yo severely unfit
12. **weekend_warrior** - 48yo inconsistent fitness
13. **former_athlete** - 55yo good strength, poor cardio
14. **yoga_practitioner** - 40yo flexible, weak strength
15. **marathon_runner** - 33yo excellent cardio, poor strength

### Health Conditions (5)
16. **post_surgery** - 52yo knee replacement recovery
17. **chronic_back_pain** - 46yo limited high-impact
18. **diabetes_type2** - 58yo insulin resistant
19. **underweight** - 28yo BMI 17, muscle building needed
20. **postpartum** - 32yo 6 months post-birth

### Lifestyle Variants (5)
21. **busy_executive** - 44yo max 2 sessions/week
22. **night_shift_worker** - 36yo poor sleep, irregular schedule
23. **homebound_parent** - 39yo no gym, limited equipment
24. **retiree** - 65yo lots of time, social motivation
25. **college_student** - 20yo irregular schedule, gym access

## Running the Tests

```bash
# Run all personas (generates reports)
flutter test test/onboarding_personas_test.dart

# Run specific test
flutter test test/onboarding_personas_test.dart --name "Run all 25 personas"
```

## Generated Reports

### `test/results/persona_review.txt` ⭐ **PRINTABLE FORMAT**
Clean, print-friendly format for manual review:
```
personaId: elderly_fall_history
description: 75-year-old with fall history and poor balance
answers: {age:"1949-01-15"; gender:"female"; height_cm:162.0; weight_kg:65.0; ...}

Output: {cardio: 10%, strength: 35%, balance: 35%, functional: 20%, flexibility: 0%}
Triggered Protocol: fall_history
Calculated: Age=76, BMI=24.8, Cooper=0.3mi, Pushups=0
--------------------------------------------------------------------------------
```

### `test/results/persona_distribution.json`
Complete detailed data including:
- All input answers for each persona
- Calculated values (age, BMI, percentiles)
- Final fitness allocations
- Triggered protocols
- Timestamps and metadata

### `test/results/persona_summary.csv`
Simplified spreadsheet format with key metrics:
- Persona ID and basic demographics
- Fitness test results
- Final allocation percentages
- Which protocol was triggered (if any)

## Analysis Questions

Use this data to answer:

1. **Protocol Distribution**: How often is each critical condition protocol triggered?
2. **Allocation Ranges**: What's the typical range for each fitness component?
3. **Age Effects**: How do allocations change across age groups?
4. **Protocol vs Base**: How different are protocol allocations from base calculations?
5. **Edge Cases**: Are there any unexpected results that need investigation?

## Customization

### Adding New Personas
1. Create new persona in `persona_definitions.dart`
2. Add to `getAllPersonas()` list
3. Run tests to see results

### Modifying Allocation Logic
1. Update calculation in `AllocationCalculator.calculateAllocation()`
2. Re-run tests to see impact across all personas
3. Compare before/after distributions

### Custom Analysis
- Import the generated JSON into analysis tools
- Filter personas by category or characteristics
- Create visualizations of distribution patterns

## Key Insights Expected

- **Fall history patients** should always get Balance=35%, Strength=35%
- **Extreme obesity** should prioritize Cardio=55%
- **Young athletes** should have minimal Balance allocation
- **Elderly** should have higher Balance regardless of protocol
- **Underweight** should get strength boosts in base calculation

This systematic approach ensures the allocation system works correctly across the full spectrum of user types and conditions.