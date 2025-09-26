

#### 1.1 Fall Risk (Critical - Priority 1a)

**INPUT:** Stand duration < 10 seconds
**PRIORITY:** 1 (Critical)
**RECOMMENDATION:** "Daily balance exercises can offset a 2.5x higher fall risk."
**SOURCE:** Vellas et al. (1997)
**RECOMMENDATION:** "Incorporate tai chi or structured balance program."
**SOURCE:** Gillespie et al. (2012) Cochrane Database. - proven to reduce falls by 19-29%

#### 1.2 Injury Accommodations (Priority 1b)

**INPUT:** [Q1 - Injuries] Body part marked as injury (double-tap)
**PRIORITY:** 1 (Critical)
**RECOMMENDATION:** "Modify exercises to protect [body part]. If something hurts, stop."
**SOURCE:** ACSM exercise prescription guidelines


#### 1.3 Age-Related Safety (Priority 1c)

**INPUT:** prioritize_functional <=.3 
**PRIORITY:** 1 (High)
**RECOMMENDATION:** "Focus on functional movements that mimic daily activities for safety."
**SOURCE:** Pahor et al. (2014) JAMA

#### 1.4 Bone Health Risk (Priority 1d)

**INPUT:** [CALCULATED - osteoporosis_risk] = 1.0
**PRIORITY:** 2 (High)
**RECOMMENDATION:** "Weight-bearing and resistance exercises essential for bone density. Consider discussing bone density testing with your doctor."
**SOURCE:** OSTA validated risk assessment tool + Beck et al. (2017)

#### 1.5 Sedentary Lifestyle Risks (Priority 1e)

**INPUT:** [sedentary_job] "Yes" AND [current_exercise_days] < 3
**PRIORITY:** 3 (Medium)
**RECOMMENDATION:** "Counter prolonged sitting with regular movement breaks - sitting increases mortality risk."
**SOURCE:** Ekelund et al. (2016)

**INPUT:** [sedentary_job] "Yes" AND [Q1 - Injuries] Back or neck marked
**PRIORITY:** 2 (High)
**RECOMMENDATION:** "Address postural issues with chest stretches, upper back strengthening, hip flexor mobility."
**SOURCE:** McGill (2007)

### Priority 2: CARDIOVASCULAR FITNESS (Major Health Impact)
After safety, cardiovascular fitness has the highest mortality impact

#### 2.1 Poor Cardiovascular Fitness (High Priority)

**INPUT:** [Q4 - distance/time run] VO2max < 30 ml/kg/min or Cardio percentile < 20th
**PRIORITY:** 4 (Medium-High)
**RECOMMENDATION:** "Prioritize moderate cardio 150 min/week to reduce cardiovascular risks."
**SOURCE:** ACSM Guidelines (2021)

**INPUT:** [Q4 - distance/time run] METs capacity < 5
**PRIORITY:** 4 (Medium-High)
**RECOMMENDATION:** "Start with low-intensity walking, gradually increase duration before intensity."
**SOURCE:** Myers et al. (2002) NEJM

### Priority 3: RECOVERY & LIFESTYLE FACTORS (Foundation for Training)
Poor sleep and nutrition undermine all fitness efforts

#### 3.1 Sleep Quality

**INPUT:** [sleep_hours] < 6
**PRIORITY:** 4 (Medium-High)
**RECOMMENDATION:** "Critical: Poor sleep increases injury risk by 70%. Prioritize 7-9 hours nightly."
**SOURCE:** Milewski et al. (2014) - Chronic lack of sleep and sports injuries

#### 3.2 Nutrition Quality

**INPUT:** [CALCULATED - diet_quality_score] < 70
**PRIORITY:** 6 (Medium-Low)
**RECOMMENDATION:** "Nutrition is one of the most important contributors to workout recovery and health. Avoid alcohol, sugars, and (we believe though not part of the standard guidelines) grains"
**SOURCE:** Position of the Academy of Nutrition and Dietetics on sports nutrition

### Priority 4: STRENGTH & MUSCLE HEALTH (Functional Independence)
Important for daily function and aging well

#### 4.1 Lower Body Weakness (Higher Priority - Fall Risk)

**INPUT:** [Q6 - Bodyweight squats OR Q6A - Chair stand] Count < 25th percentile
**PRIORITY:** 7 (Medium)
**RECOMMENDATION:** "Strengthen legs to improve mobility and reduce fall risk."
**SOURCE:** Rantanen et al. (2000)

**INPUT:** [Age Question] > 50 AND [Q5/Q6 strength tests] < 50th percentile
**PRIORITY:** 6 (Medium-Low)
**RECOMMENDATION:** "Combat age-related muscle loss with resistance training 2-3x weekly."
**SOURCE:** Cruz-Jentoft et al. (2019)

**INPUT:** [GLP-1 medications] "Yes"
**PRIORITY:** 5 (Medium)
**RECOMMENDATION:** "GLP-1 medications can cause muscle loss during weight loss. Prioritize resistance training 3x weekly to preserve lean muscle mass."
**SOURCE:** Wilding et al. (2021) NEJM, Wadden et al. (2021)




#### 4.2 Upper Body Weakness (Lower Priority)

**INPUT:** [Q5 - Push-ups] Count < 25th percentile for age/gender
**PRIORITY:** 8 (Lower)
**RECOMMENDATION:** "Include upper body strengthening 2-3x per week for functional tasks."
**SOURCE:** ACSM fitness assessment norms

### Priority 5: PLAN CONSTRUCTION GUIDANCE (Training Parameters)
How to structure the actual training plan

#### 5.1 Recovery & Frequency Guidelines

**INPUT:** [session_commitment] full_sessions < 3/week
**PRIORITY:** 10 (Lower)
**RECOMMENDATION:** "Combine cardio and strength in each session for time efficiency."
**SOURCE:** ACSM minimum recommendations

**INPUT:** [session_commitment] micro_sessions > full_sessions
**PRIORITY:** 9 (Lower)
**RECOMMENDATION:** "Use high-intensity intervals to maximize benefits and minimize time commitments."
**SOURCE:** Gibala et al. (2012)

#### 5.3 Performance Level Progressions

**INPUT:** [current_exercise_days] = 0 AND [MISSING - Training History] "Never"
**PRIORITY:** 12 (Lower)
**RECOMMENDATION:** "Start with 2-3 days/week, progress by 10% weekly to build habit safely."
**SOURCE:** ACSM progression guidelines

**INPUT:** [current_exercise_days] > 5 AND [MISSING - Training History] ">1 year"
**PRIORITY:** 13 (Lower)
**RECOMMENDATION:** "Vary training stimulus every 4-6 weeks to prevent plateau."
**SOURCE:** Kramer et al. (1997)

### Priority 6: MOTIVATION & ADHERENCE (Supporting Success)
Help users stick to the program

#### 6.1 Beginner Motivation

**INPUT:** [current_exercise_days] = 0 
**PRIORITY:** 14 (Supportive)
**RECOMMENDATION:** "Start slowly with 10-15 minutes, 3 days weekly. Consistency beats intensity for building habits."
**SOURCE:** Behavioral change research

**INPUT:** [primary_motivation] External motivation
**PRIORITY:** 15 (Supportive)
**RECOMMENDATION:** "Find a workout buddy. We can help you connect with them in the app so that you can motivate each other."
**SOURCE:** Behavioral activation research


  #### 7.1 Elite Cardio Performance
  **INPUT:** [cardio_fitness_percentile] > 0.5
  **PRIORITY:** 11 (Enhancement)
  **RECOMMENDATION:** "Your cardio fitness is better than **over half of your peers**! See gains
from polarized training: 80% easy, 20% hard."
  **SOURCE:** Seiler (2010)

  #### 7.2 Elite Upper Body Strength
  **INPUT:** [upper_body_strength_percentile] > 0.5
  **PRIORITY:** 11 (Enhancement)  
  **RECOMMENDATION:** "Your push-up performance puts you in the **top half for your peers**. Use variety to avoid peaks."
  **SOURCE:** ACSM Guidelines

  #### 7.3 Elite Combined Fitness
  **INPUT:** [cardio_fitness_percentile] > 0.75 AND [strength_fitness_percentile] > 0.75
  **PRIORITY:** 10 (Enhancement)
  **RECOMMENDATION:** "You're in the **top fitness quartile**! You can be proud that you're in an elite group, but excellence will make your gains more modest and harder to achieve. Find ways to stay motivated and not get discouraged."
  **SOURCE:** ACSM Fitness Assessment


## Implementation Details

### 1. Simplified Recommendation Approach

No data model needed - just use `List<String>` for recommendations.

### 2. Recommendations Extractor Extension

Create new file: `fitness_profile_extraction_extensions/recommendations.dart`

```dart
import '../fitness_profile.dart';

extension Recommendations on FitnessProfile {

  void calculateRecommendations() {
    final recommendations = <String>[];
    final age = AgeQuestion.instance.calculatedAge;
    final gender = GenderQuestion.instance.genderAnswer;

    // Add recommendations in priority order (highest priority first)
    // No need to sort since we're adding them in order

    // PRIORITY 1: Critical Safety
    if (prioritizeFunctional > 0.3) {
      recommendations.add(
        "Focus on functional movements that mimic daily activities for safety."
      );
    }

    if (injuriesMap != null) {
      for (final entry in injuriesMap!.entries) {
        if (entry.value == BodyPartConstants.avoid) {
          recommendations.add(
            "Modify exercises to protect ${entry.key}. If something hurts, stop."
          );
          break; // Only one injury recommendation
        }
      }
    }

    // PRIORITY 2: High Risk
    if (osteoporosisRisk == 1.0) {
      recommendations.add(
        "Weight-bearing and resistance exercises essential for bone density."
      );
    }

    // PRIORITY 3: Medium Risk
    if (sedentaryJob == 1.0 && currentExerciseDays < 3) {
      recommendations.add(
        "Counter prolonged sitting with movement breaks every hour."
      );
    }

    // PRIORITY 4: Cardio Deficiency
    final cardioPercentile = featuresMap['cardio_fitness_percentile'] ?? 0.0;
    if (cardioPercentile < 0.2) {
      recommendations.add(
        "Prioritize moderate cardio 150 min/week to reduce cardiovascular risks."
      );
    }

    // PRIORITY 5: GLP-1 Muscle Preservation
    if (onGLP1Medications == 1.0) {
      recommendations.add(
        "GLP-1 medications can cause muscle loss. Prioritize resistance training 3x weekly."
      );
    }

    // PRIORITY 6: Nutrition
    if (dietQualityScore < 70) {
      recommendations.add(
        "Improve diet quality for better recovery. Reduce alcohol, sugars, and grains."
      );
    }

    // PRIORITY 7: Strength Deficiency
    final strengthPercentile = featuresMap['strength_fitness_percentile'] ?? 0.0;
    if (strengthPercentile < 0.25) {
      recommendations.add(
        "Build foundational strength with 2-3 sessions weekly."
      );
    }

    // PRIORITY 11: Performance (for high achievers)
    if (cardioPercentile > 0.75) {
      final percentText = "top 25% for $age year-old ${gender}s";
      recommendations.add(
        "Your cardio fitness is in the **$percentText**! "
        "Maintain with polarized training: 80% easy, 20% hard."
      );
    } else if (cardioPercentile > 0.5) {
      final percent = (cardioPercentile * 100).round();
      recommendations.add(
        "Your cardio fitness is **better than $percent% of peers**! "
        "Add intervals for next level."
      );
    }

    // Store the list (already in priority order, no sorting needed)
    recommendationsList = recommendations;
  }
}
```

### 3. Integration with FitnessProfile

Add to `fitness_profile.dart`:

```dart
class FitnessProfile {
  // ... existing fields ...
  List<String>? recommendationsList;  // Transient field, not persisted

  // NO changes to calculateAllFeatures() - recommendations NOT called there
  // NO changes to toJson() - recommendations NOT stored
  // NO changes to fromJson() - recommendations NOT loaded

  // Recommendations are calculated on-demand when the view needs them
}
```

### 4. Display in OnboardingSummaryView

Update `onboarding_summary_view.dart`:

```dart
class OnboardingSummaryView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final fitnessProfile = context.watch<AppState>().profile;

    if (fitnessProfile == null) {
      // ... null handling ...
    }

    // Calculate recommendations fresh each time the view is shown
    // This ensures recommendations are always up-to-date with latest logic
    fitnessProfile.calculateRecommendations();

    return Scaffold(
      // ... existing widgets ...

      // Add after RiskFactorsSection
      RecommendationsSection(fitnessProfile: fitnessProfile),

      // ... rest of view ...
    );
  }
}
```


### 5. Simplified Recommendation Display

```dart
class RecommendationsSection extends StatelessWidget {
  final FitnessProfile fitnessProfile;

  @override
  Widget build(BuildContext context) {
    final recommendations = fitnessProfile.recommendationsList ?? [];

    // Take first 5 recommendations (already in priority order)
    final topRecs = recommendations.take(5).toList();

    if (topRecs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your Personalized Insights',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        // Simple cards for each recommendation text
        for (final text in topRecs)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                text,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
      ],
    );
  }
}
```

## Implementation Summary

### Key Design Decisions

1. **On-Demand Calculation**: Recommendations are calculated fresh each time the summary view is shown, not stored or persisted
   - Ensures recommendations always reflect latest logic
   - No migration issues when updating recommendation text
   - Keeps storage simple (only features are persisted)

2. **Priority-Based List**: Simple linear check through all conditions in priority order
   - Add all matching recommendations to a list
   - Sort once by priority at the end
   - UI takes top 5 (or more if desired)

3. **Separation of Concerns**:
   - **FitnessProfile**: Stores features (data layer)
   - **Recommendations extension**: Calculates recommendations from features
   - **View**: Triggers calculation and displays results (presentation layer)

4. **No Secondary Prioritization**: Each recommendation has its priority built-in
   - Simplifies the logic
   - Makes it clear which recommendations are most important

### Implementation Steps

1. Create `recommendations.dart` extension with `calculateRecommendations()`
2. Add `List<String>? recommendationsList` field to FitnessProfile (transient)
3. Call `calculateRecommendations()` in OnboardingSummaryView
4. Create simple RecommendationsSection widget to display text cards
5. Test with various profiles to ensure proper prioritization

### Simplification Benefits

- **No data model** - Just strings, much simpler
- **No sorting** - Add in priority order
- **No complex widgets** - Simple text cards
- **Easy to maintain** - Just update the text strings
- **Fast implementation** - Minimal code needed

