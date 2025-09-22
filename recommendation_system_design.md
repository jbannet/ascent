# Recommendation System Design

## Agreements & Decisions
- Add recommendation extractor to create non-numerical insights from fitness profile data
- Recommendations should appear in the onboarding summary view
- Extract actionable, personalized recommendations based on user's answers and calculated features
- Provide clear, motivating guidance without being prescriptive
- Each recommendation must tie to specific questions we ask or identify missing questions

## Input → Recommendation Mappings (Evidence-Based)

## Cardiovascular Fitness Indicators

### INPUT: [Q4 - 12-minute run] Distance < 0.8 miles OR calculated VO2max < 30 ml/kg/min
**RECOMMENDATION:** "Focus on building cardiovascular base with moderate-intensity aerobic exercise"
**SOURCE:** ACSM Guidelines (2021) - VO2max below 30 indicates increased mortality risk; 150 min/week moderate cardio recommended

### INPUT: [Q4 - 12-minute run] Cardio percentile < 20th percentile for age/gender
**RECOMMENDATION:** "Prioritize cardiovascular improvement - your fitness is below average for your age group"
**SOURCE:** Cooper Institute normative data; low cardio fitness associated with 2-3x higher all-cause mortality

### INPUT: [Q4 - 12-minute run] Calculated METs capacity < 5
**RECOMMENDATION:** "Start with low-intensity activities like walking; gradually increase duration before intensity"
**SOURCE:** Myers et al. (2002) NEJM - Each 1-MET increase = 12% reduction in mortality risk

### INPUT: [MISSING - Heart Rate Recovery Test] HR drop < 12 bpm at 1 minute post-exercise
**RECOMMENDATION:** "Include interval training to improve heart rate recovery"
**SOURCE:** Cole et al. (1999) NEJM - Poor HR recovery (<12 bpm) predicts mortality

## Strength & Muscle Health Indicators

### INPUT: [Q5 - Push-ups] Count < 25th percentile for age/gender
**RECOMMENDATION:** "Upper body strength needs attention - include push exercises 2-3x per week"
**SOURCE:** ACSM fitness assessment norms; low upper body strength correlates with functional decline

### INPUT: [Q6 - Bodyweight squats OR Q6A - Chair stand] Count < 25th percentile
**RECOMMENDATION:** "Strengthen lower body to improve mobility and reduce fall risk"
**SOURCE:** Rantanen et al. (2000) - Low leg strength predicts disability and mortality in older adults

### INPUT: [Age Question] > 50 AND [Q5/Q6 strength tests] < 50th percentile
**RECOMMENDATION:** "Combat age-related muscle loss with resistance training 2-3x per week"
**SOURCE:** Cruz-Jentoft et al. (2019) - Sarcopenia affects 10-27% over 60; resistance training is primary intervention

## Balance & Fall Risk Indicators

### INPUT: [MISSING - Single-leg Balance Test] Stand duration < 10 seconds
**RECOMMENDATION:** "Critical: Include daily balance exercises to reduce fall risk"
**SOURCE:** Vellas et al. (1997) - <10 sec single leg stand = 2.5x increased fall risk

### INPUT: [Q4A - Fall history] Answer = "Yes" (fallen in past 12 months)
**RECOMMENDATION:** "Multicomponent exercise including balance, strength, and gait training recommended"
**SOURCE:** Sherrington et al. (2019) Cochrane Review - Reduces falls by 23%

### INPUT: [Age Question] > 65 AND [Q4B - Fall risk factors] Any factor selected
**RECOMMENDATION:** "Consider tai chi or structured balance program - proven to reduce falls by 19-29%"
**SOURCE:** Gillespie et al. (2012) Cochrane Database

## Joint Health & Impact Tolerance

### INPUT: [CALCULATED - joint_health_score from Q1/Q2/age] < 7/10
**RECOMMENDATION:** "Low-impact exercises (swimming, cycling, elliptical) to protect joints"
**SOURCE:** OARSI Guidelines (2019) - Low-impact exercise reduces pain and improves function in osteoarthritis

### INPUT: [Height/Weight Questions] BMI > 30 AND [Q1 - Injuries] Any joint marked
**RECOMMENDATION:** "Non-weight bearing exercises initially; each 5% weight loss reduces knee stress by 20%"
**SOURCE:** Messier et al. (2013) JAMA - Weight loss + exercise superior to either alone for knee OA

### INPUT: [Q1 - Injuries] Body part marked as injury (double-tap)
**RECOMMENDATION:** "Avoid exercises involving [body part]; strengthen surrounding muscles when cleared"
**SOURCE:** ACSM exercise prescription guidelines for post-injury rehabilitation

## Age-Related Recommendations

### INPUT: [Age Question] 18-30 AND [current_exercise_days] = 0
**RECOMMENDATION:** "Build fitness habits now - peak bone density achieved by 30"
**SOURCE:** NIH Osteoporosis Prevention - Peak bone mass critical for later life

### INPUT: [Age Question] 40-50
**RECOMMENDATION:** "Include flexibility work - flexibility declines 8-10% per decade after 30"
**SOURCE:** ACSM Guidelines on flexibility and aging

### INPUT: [Age Question] 60-70
**RECOMMENDATION:** "Multimodal training essential: strength, balance, cardio, and flexibility"
**SOURCE:** WHO Guidelines (2020) - Multicomponent exercise reduces disability risk by 30%

### INPUT: [Age Question] > 70
**RECOMMENDATION:** "Focus on functional fitness - exercises that mimic daily activities"
**SOURCE:** Pahor et al. (2014) JAMA - Structured exercise reduces major mobility disability by 18%

## Recovery & Training Frequency

### INPUT: [Age Question] > 50 OR [CALCULATED - recovery_days] > 2
**RECOMMENDATION:** "Allow 48-72 hours between strength sessions for same muscle groups"
**SOURCE:** Schoenfeld et al. (2019) - Older adults need longer recovery for protein synthesis

### INPUT: [session_commitment] full_sessions < 2/week
**RECOMMENDATION:** "Combine cardio and strength in each session for time efficiency"
**SOURCE:** ACSM minimum recommendations - 2 days/week minimum for health benefits

### INPUT: [session_commitment] micro_sessions > full_sessions
**RECOMMENDATION:** "High-intensity intervals maximize benefits in minimal time"
**SOURCE:** Gibala et al. (2012) - 3x10min HIIT/week = similar benefits to 150min moderate exercise

## Medical Conditions & Special Populations

### INPUT: [MISSING - Medical Conditions Checklist] Diabetes selected
**RECOMMENDATION:** "Combine aerobic and resistance training - improves glucose control by 0.67% HbA1c"
**SOURCE:** Umpierre et al. (2011) JAMA - Combined training superior for glycemic control

### INPUT: [MISSING - Medical Conditions Checklist] Hypertension selected
**RECOMMENDATION:** "Regular aerobic exercise can reduce BP by 5-8 mmHg"
**SOURCE:** Cornelissen & Smart (2013) - Meta-analysis of exercise and blood pressure

### INPUT: [MISSING - Medical Conditions Checklist] Osteoporosis selected
**RECOMMENDATION:** "Weight-bearing and resistance exercises to maintain bone density"
**SOURCE:** Beck et al. (2017) - High-intensity resistance training improves bone density

### INPUT: [MISSING - Mental Health Screen] Depression/anxiety = "Often" or "Most days"
**RECOMMENDATION:** "Regular exercise comparable to medication for mild-moderate depression"
**SOURCE:** Cooney et al. (2013) Cochrane - Exercise reduces depression symptoms (SMD -0.62)

## Equipment & Environment Constraints

### INPUT: [Q10 - Equipment] "No equipment" selected
**RECOMMENDATION:** "Bodyweight training can achieve significant strength gains in beginners"
**SOURCE:** Kotarsky et al. (2018) - Bodyweight training effective for 8 weeks in untrained

### INPUT: [Q11 - Training location] "At home only" selected
**RECOMMENDATION:** "Resistance bands provide similar strength gains to weights in some populations"
**SOURCE:** Lopes et al. (2019) - Elastic resistance comparable to conventional resistance

### INPUT: [session_commitment] average_session_duration < 30 minutes
**RECOMMENDATION:** "Circuit training combines cardio and strength benefits efficiently"
**SOURCE:** Klika & Jordan (2013) ACSM - 7-minute circuit provides health benefits

## Performance Level Adaptations

### INPUT: [current_exercise_days] = 0 AND [MISSING - Training History] "Never" selected
**RECOMMENDATION:** "Start with 2-3 days/week, progress by 10% weekly in duration/intensity"
**SOURCE:** ACSM progression guidelines - 10% rule reduces injury risk

### INPUT: [current_exercise_days] 3-5 AND [MISSING - Training History] "6-12 months"
**RECOMMENDATION:** "Periodize training with 3-4 week blocks focusing on different attributes"
**SOURCE:** Rhea & Alderman (2004) - Periodization superior to linear progression

### INPUT: [current_exercise_days] > 5 AND [MISSING - Training History] ">1 year"
**RECOMMENDATION:** "Vary training stimulus every 4-6 weeks to prevent plateau"
**SOURCE:** Kramer et al. (1997) - Variation necessary for continued adaptation

## Weight Management Indicators

### INPUT: [Height/Weight Questions] BMI > 25 AND [fitness_goals] "Lose weight" selected
**RECOMMENDATION:** "Combine 250+ min/week cardio with strength training for optimal fat loss"
**SOURCE:** Donnelly et al. (2009) ACSM Position Stand - >250 min/week for significant weight loss

### INPUT: [Height/Weight Questions] BMI < 18.5
**RECOMMENDATION:** "Focus on strength training with adequate protein to build lean mass"
**SOURCE:** Churchward-Venne et al. (2012) - Resistance training + protein for healthy weight gain

### INPUT: [MISSING - Weight History Question] >5% loss in 6 months unintentional
**RECOMMENDATION:** "Consult physician; maintain activity but monitor energy levels"
**SOURCE:** Clinical red flag for underlying conditions requiring medical evaluation

## Flexibility & Mobility

### INPUT: [MISSING - Flexibility Test] Sit-and-reach < 25th percentile
**RECOMMENDATION:** "Include 10 minutes daily stretching, hold stretches 30-60 seconds"
**SOURCE:** ACSM Guidelines - 30-60 second holds, 2-3 days/week minimum

### INPUT: [sedentary_job] Answer = "Yes"
**RECOMMENDATION:** "Focus on hip flexor, chest, and upper back mobility. Take movement breaks every hour."
**SOURCE:** Page (2012) - Address "upper crossed syndrome" from prolonged sitting

---

## Motivation & Adherence Recommendations

### INPUT: [current_exercise_days] = 0 AND [MISSING - Training History] \"Never\" selected
**RECOMMENDATION:** "Start slowly with just 10-15 minutes, 3 days a week. Consistency matters more than intensity when building the habit."
**SOURCE:** Behavioral change research - habit formation takes average 66 days

### INPUT: [current_exercise_days] = 0 AND [MISSING - Training History] Previously active
**RECOMMENDATION:** "You've done this before - start at 50% of your previous level and build back gradually over 4-6 weeks."
**SOURCE:** Detraining and retraining research

### INPUT: [current_exercise_days] > 5 AND [session_commitment] high variety
**RECOMMENDATION:** "Keep workouts engaging with varied formats: intervals, circuits, challenges. Variety prevents boredom."
**SOURCE:** Exercise adherence and variety research

### INPUT: [sedentary_job] \"Yes\" AND [session_commitment] limited time
**RECOMMENDATION:** "Every minute counts - take stairs, walk during calls, do desk stretches. Your micro-workouts add up to major health benefits."
**SOURCE:** NEAT (non-exercise activity thermogenesis) research

### INPUT: [primary_motivation] External motivation OR low commitment signals
**RECOMMENDATION:** "On tough days, commit to just showing up for 5 minutes. You can always do more, but honor the minimum."
**SOURCE:** Behavioral activation research - minimum effective dose for habit maintenance

## Sedentary Lifestyle Specific

### INPUT: [sedentary_job] \"Yes\"
**RECOMMENDATION:** "Take movement breaks every hour. Set phone reminders to stand, stretch, or walk for 2-3 minutes."
**SOURCE:** Healy et al. (2008) - Breaking up sedentary time improves metabolic markers

### INPUT: [sedentary_job] \"Yes\" AND [current_exercise_days] < 3
**RECOMMENDATION:** "Prioritize short, frequent movement over long workouts. Your body needs to counteract prolonged sitting daily."
**SOURCE:** Ekelund et al. (2016) - Light activity throughout day reduces mortality risk from sitting

### INPUT: [sedentary_job] \"Yes\" AND [Q1 - Injuries] Back or neck marked
**RECOMMENDATION:** "Focus on posture-correcting exercises: chest stretches, upper back strengthening, and hip flexor mobility."
**SOURCE:** McGill (2007) - Specific exercises for office worker postural dysfunction

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
2. **Training history/experience** - Needed for beginner/intermediate/advanced classification
3. **Medical conditions checklist** - For condition-specific recommendations
4. **Flexibility assessment** - For mobility recommendations
5. **Heart rate recovery test** - For cardiovascular recovery assessment
6. **Mental health screen** - For exercise as therapy recommendations
7. **Weight history** - For detecting concerning weight loss

## Technical Notes
- Recommendations should be constructive and motivating
- Avoid medical advice or diagnoses
- Focus on what the user CAN do, not limitations
- Keep language clear and jargon-free
- Prioritize most impactful recommendations
- Use medical sources for credibility