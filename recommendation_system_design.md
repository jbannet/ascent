# Recommendation System Design

## Agreements & Decisions
- Add recommendation extractor to create non-numerical insights from fitness profile data
- Recommendations should appear in the onboarding summary view
- Extract actionable, personalized recommendations based on user's answers and calculated features
- Provide clear, motivating guidance without being prescriptive
- Each recommendation must tie to specific questions we ask or identify missing questions

## Recommendation Priority System (Decision Tree)

### Priority 1: SAFETY & RISK FACTORS (Check First - Highest Priority)
These take absolute priority - if present, must be addressed in recommendations

#### 1.1 Fall Risk (Critical - Priority 1a)

**INPUT:** [Q4A - Fall history] Answer = "Yes" (fallen in past 12 months)
**PRIORITY:** 1 (Critical)
**RECOMMENDATION:** "Multicomponent exercise reduces fall risk."
**SOURCE:** Sherrington et al. (2019) Cochrane Review -- by 23%

**INPUT:** [MISSING - Single-leg Balance Test] Stand duration < 10 seconds
**PRIORITY:** 1 (Critical)
**RECOMMENDATION:** "Daily balance exercises can offset a 2.5x higher fall risk."
**SOURCE:** Vellas et al. (1997)

**INPUT:** [Age Question] > 65 AND [Q4B - Fall risk factors] Any factor selected
**PRIORITY:** 2 (High)
**RECOMMENDATION:** "Incorporate tai chi or structured balance program."
**SOURCE:** Gillespie et al. (2012) Cochrane Database. - proven to reduce falls by 19-29%

#### 1.2 Injury Accommodations (Priority 1b)

**INPUT:** [Q1 - Injuries] Body part marked as injury (double-tap)
**PRIORITY:** 1 (Critical)
**RECOMMENDATION:** "Exercises modified to avoid [body part] - strengthen surrounding muscles when cleared."
**SOURCE:** ACSM exercise prescription guidelines

**INPUT:** [Height/Weight Questions] BMI > 30 AND [Q1 - Injuries] Any joint marked
**PRIORITY:** 2 (High)
**RECOMMENDATION:** "Start with non-weight bearing exercises to protect joints during weight loss."
**SOURCE:** Messier et al. (2013) JAMA

#### 1.3 Age-Related Safety (Priority 1c)

**INPUT:** [Age Question] > 70 
**PRIORITY:** 2 (High)
**RECOMMENDATION:** "Focus on functional movements that mimic daily activities for safety."
**SOURCE:** Pahor et al. (2014) JAMA

**INPUT:** [Age Question] 60-70
**PRIORITY:** 3 (Medium)
**RECOMMENDATION:** "Multimodal training essential: combine strength, balance, cardio, and flexibility."
**SOURCE:** WHO Guidelines (2020)

#### 1.4 Bone Health Risk (Priority 1d)

**INPUT:** [CALCULATED - osteoporosis_risk] = 1.0
**PRIORITY:** 2 (High)
**RECOMMENDATION:** "Weight-bearing and resistance exercises essential for bone density. Consider discussing bone density testing with your doctor."
**SOURCE:** OSTA validated risk assessment tool + Beck et al. (2017)

#### 1.5 Sedentary Lifestyle Risks (Priority 1e)

**INPUT:** [sedentary_job] "Yes" AND [current_exercise_days] < 3
**PRIORITY:** 3 (Medium)
**RECOMMENDATION:** "Counter prolonged sitting with movement breaks every hour - sitting increases mortality risk."
**SOURCE:** Ekelund et al. (2016)

**INPUT:** [sedentary_job] "Yes" AND [Q1 - Injuries] Back or neck marked
**PRIORITY:** 2 (High)
**RECOMMENDATION:** "Address postural issues with chest stretches, upper back strengthening, hip flexor mobility."
**SOURCE:** McGill (2007)

### Priority 2: CARDIOVASCULAR FITNESS (Major Health Impact)
After safety, cardiovascular fitness has the highest mortality impact

#### 2.1 Poor Cardiovascular Fitness (High Priority)

**INPUT:** [Q4 - 12-minute run] VO2max < 30 ml/kg/min or Cardio percentile < 20th
**PRIORITY:** 4 (Medium-High)
**RECOMMENDATION:** "Prioritize moderate cardio 150 min/week to reduce cardiovascular risks."
**SOURCE:** ACSM Guidelines (2021)

**INPUT:** [Q4 - 12-minute run] METs capacity < 5
**PRIORITY:** 4 (Medium-High)
**RECOMMENDATION:** "Start with low-intensity walking, gradually increase duration before intensity."
**SOURCE:** Myers et al. (2002) NEJM

### Priority 3: STRENGTH & MUSCLE HEALTH (Functional Independence)
Important for daily function and aging well

#### 3.1 Lower Body Weakness (Higher Priority - Fall Risk)

**INPUT:** [Q6 - Bodyweight squats OR Q6A - Chair stand] Count < 25th percentile
**PRIORITY:** 7 (Medium)
**RECOMMENDATION:** "Strengthen legs to improve mobility and reduce fall risk."
**SOURCE:** Rantanen et al. (2000)

**INPUT:** [Age Question] > 50 AND [Q5/Q6 strength tests] < 50th percentile
**PRIORITY:** 6 (Medium-Low)
**RECOMMENDATION:** "Combat age-related muscle loss with resistance training 2-3x weekly."
**SOURCE:** Cruz-Jentoft et al. (2019)

#### 3.2 Upper Body Weakness (Lower Priority)

**INPUT:** [Q5 - Push-ups] Count < 25th percentile for age/gender
**PRIORITY:** 8 (Lower)
**RECOMMENDATION:** "Include upper body strengthening 2-3x per week for functional tasks."
**SOURCE:** ACSM fitness assessment norms

### Priority 4: PLAN CONSTRUCTION GUIDANCE (Training Parameters)
How to structure the actual training plan

#### 4.1 Recovery & Frequency Guidelines

**INPUT:** [Age Question] > 50 OR [CALCULATED - recovery_days] > 2
**PRIORITY:** 9 (Lower)
**RECOMMENDATION:** "Allow 48-72 hours between strength sessions targeting same muscle groups."
**SOURCE:** Schoenfeld et al. (2019)

**INPUT:** [session_commitment] full_sessions < 2/week
**PRIORITY:** 10 (Lower)
**RECOMMENDATION:** "Combine cardio and strength in each session for time efficiency."
**SOURCE:** ACSM minimum recommendations

**INPUT:** [session_commitment] micro_sessions > full_sessions
**PRIORITY:** 9 (Lower)
**RECOMMENDATION:** "High-intensity intervals maximize benefits in minimal time."
**SOURCE:** Gibala et al. (2012)

#### 4.2 Equipment & Environment Adaptations

**INPUT:** [Q10 - Equipment] "No equipment" selected
**PRIORITY:** 11 (Lower)
**RECOMMENDATION:** "Bodyweight training effective for building strength in beginners."
**SOURCE:** Kotarsky et al. (2018)

**INPUT:** [Q11 - Training location] "At home only" selected
**PRIORITY:** 11 (Lower)
**RECOMMENDATION:** "Home workouts with resistance bands provide similar gains to weights."
**SOURCE:** Lopes et al. (2019)

#### 4.3 Performance Level Progressions

**INPUT:** [current_exercise_days] = 0 AND [MISSING - Training History] "Never"
**PRIORITY:** 12 (Lower)
**RECOMMENDATION:** "Start with 2-3 days/week, progress by 10% weekly to build habit safely."
**SOURCE:** ACSM progression guidelines

**INPUT:** [current_exercise_days] > 5 AND [MISSING - Training History] ">1 year"
**PRIORITY:** 13 (Lower)
**RECOMMENDATION:** "Vary training stimulus every 4-6 weeks to prevent plateau."
**SOURCE:** Kramer et al. (1997)

### Priority 5: MOTIVATION & ADHERENCE (Supporting Success)
Help users stick to the program

#### 5.1 Beginner Motivation

**INPUT:** [current_exercise_days] = 0 
**PRIORITY:** 14 (Supportive)
**RECOMMENDATION:** "Start slowly with 10-15 minutes, 3 days weekly. Consistency beats intensity for building habits."
**SOURCE:** Behavioral change research

**INPUT:** [primary_motivation] External motivation
**PRIORITY:** 15 (Supportive)
**RECOMMENDATION:** "Find a workout buddy.... [explain app link?]."
**SOURCE:** Behavioral activation research

#### 5.2 Advanced Engagement

**INPUT:** [current_exercise_days] > 5 AND [session_commitment] high variety
**PRIORITY:** 15 (Supportive)
**RECOMMENDATION:** "Keep workouts engaging with varied formats to prevent boredom."
**SOURCE:** Exercise adherence research


## Notes for Implementation:
1. Each recommendation should check multiple related inputs for context
2. Prioritize safety recommendations (fall risk, injuries) highest
3. Age-adjust all recommendations appropriately
4. Consider interaction between multiple conditions
5. Always frame positively - what TO do, not just what to avoid

---

## Implementation Plan

### 1. Create Recommendation Model
```dart
class FitnessRecommendation {
  final String category; // Priority, Approach, Equipment, Health, Time, Motivation
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final int priority; // For sorting (1=highest)
}
```

### 2. Create Recommendation Extractor Extension
```dart
extension RecommendationExtractor on FitnessProfile {
  List<FitnessRecommendation> extractRecommendations() {
    final recommendations = <FitnessRecommendation>[];

    // Check each condition from mappings above
    _addCardioRecommendations(recommendations);
    _addStrengthRecommendations(recommendations);
    _addBalanceRecommendations(recommendations);
    _addJointHealthRecommendations(recommendations);
    _addAgeRecommendations(recommendations);
    _addRecoveryRecommendations(recommendations);
    _addEquipmentRecommendations(recommendations);
    _addMotivationRecommendations(recommendations);
    _addSedentaryRecommendations(recommendations);

    // Sort by priority and return top 3-5
    recommendations.sort((a, b) => a.priority.compareTo(b.priority));
    return recommendations.take(5).toList();
  }
}
```

### 3. Update OnboardingSummaryView
Add a recommendations section after the category allocation:
- Card-based layout with icon, title, and description
- Subtle background colors matching recommendation category
- Maximum 3-5 most relevant recommendations shown

### 4. Visual Design
```
┌─────────────────────────────────┐
│ 💡 Your Personalized Insights   │
├─────────────────────────────────┤
│ ┌─────────────────────────────┐ │
│ │ 🎯 Priority Focus            │ │
│ │ Build cardiovascular         │ │
│ │ endurance for better health  │ │
│ └─────────────────────────────┘ │
│ ┌─────────────────────────────┐ │
│ │ 🏠 Home Training             │ │
│ │ Bodyweight exercises perfect │ │
│ │ for your equipment setup     │ │
│ └─────────────────────────────┘ │
│ ┌─────────────────────────────┐ │
│ │ ⚡ Micro Sessions            │ │
│ │ Quick 10-minute workouts     │ │
│ │ fit your busy schedule       │ │
│ └─────────────────────────────┘ │
└─────────────────────────────────┘
```

## Task Checklist
- [x] Map all recommendations to specific questions
- [x] Identify missing questions needed
- [x] Add sedentary job specific recommendations
- [x] Add motivation and adherence recommendations
- [ ] Create FitnessRecommendation model class
- [ ] Create recommendation_extractor.dart extension
- [ ] Implement extraction logic for each category
- [ ] Add recommendations section to OnboardingSummaryView
- [ ] Style recommendation cards with appropriate icons/colors
- [ ] Test with various fitness profiles

## Missing Questions to Add (Priority Order)
1. **Single-leg balance test** - Critical for fall risk assessment
2. **HRT/Estrogen use question** - For women, affects osteoporosis risk calculation
3. **Training history/experience** - Needed for beginner/intermediate/advanced classification
4. **Medical conditions checklist** - For condition-specific recommendations
5. **Flexibility assessment** - For mobility recommendations
6. **Heart rate recovery test** - For cardiovascular recovery assessment
7. **Mental health screen** - For exercise as therapy recommendations
8. **Weight history** - For detecting concerning weight loss

## Technical Notes
- Recommendations should be constructive and motivating
- Avoid medical advice or diagnoses
- Focus on what the user CAN do, not limitations
- Keep language clear and jargon-free
- Prioritize most impactful recommendations
- Use medical sources for credibility