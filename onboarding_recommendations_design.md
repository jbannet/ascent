# Onboarding Recommendations Extractor Design

## Agreements & Decisions
- Add recommendation extractor to create non-numerical insights from fitness profile data
- Recommendations should appear in the onboarding summary view
- Extract actionable, personalized recommendations based on user's answers and calculated features
- Provide clear, motivating guidance without being prescriptive

## Recommendation Categories

### 1. Fitness Priority Recommendations
Based on percentile scores and fitness gaps:
- **Low Cardio Fitness (<30th percentile)**: "Focus on building cardiovascular endurance to improve overall health"
- **Low Strength (<30th percentile)**: "Prioritize strength training to build muscle and bone density"
- **Balance Issues**: "Include balance exercises to reduce fall risk and improve stability"
- **High Performer (>70th percentile in area)**: "Maintain your excellent [cardio/strength] fitness with consistent training"

### 2. Training Approach Recommendations
Based on age, fitness level, and recovery needs:
- **Age 60+**: "Low-impact exercises recommended to protect joints while building fitness"
- **High Recovery Needs**: "Allow adequate rest between intense sessions for optimal results"
- **Beginner Level**: "Start with bodyweight exercises to build a foundation"
- **Advanced Level**: "Progressive overload and varied training will help you continue improving"

### 3. Equipment & Location Recommendations
Based on equipment access and location preferences:
- **No Equipment**: "Your plan focuses on effective bodyweight exercises you can do anywhere"
- **Home Training**: "Home-friendly workouts designed for your available equipment"
- **Gym Access**: "Take advantage of gym equipment for progressive strength training"
- **Outdoor Preference**: "Weather-permitting outdoor activities included when possible"

### 4. Health & Safety Recommendations
Based on injuries, medical conditions, and risk factors:
- **Has Injuries**: "Exercises modified to work around your [body part] limitations"
- **Fall Risk > 0**: "Balance and stability exercises prioritized for safety"
- **Joint Health < 8**: "Joint-friendly, low-impact options emphasized"
- **Medical Conditions**: "Program adapted for your health considerations"

### 5. Time & Commitment Recommendations
Based on session availability:
- **Limited Time (<3 sessions/week)**: "Efficient full-body workouts to maximize limited time"
- **Micro Sessions**: "Quick 10-minute sessions perfect for busy schedules"
- **High Availability (>5 sessions)**: "Varied program to maintain engagement and prevent burnout"

## Implementation Plan

### 1. Create Recommendation Model
```dart
class FitnessRecommendation {
  final String category; // Priority, Approach, Equipment, Health, Time
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final int priority; // For sorting
}
```

### 2. Create Recommendation Extractor Extension
```dart
extension RecommendationExtractor on FitnessProfile {
  List<FitnessRecommendation> extractRecommendations() {
    final recommendations = <FitnessRecommendation>[];

    // Extract fitness priority recommendations
    _addFitnessPriorityRecommendations(recommendations);

    // Extract training approach recommendations
    _addTrainingApproachRecommendations(recommendations);

    // Extract equipment/location recommendations
    _addEquipmentLocationRecommendations(recommendations);

    // Extract health/safety recommendations
    _addHealthSafetyRecommendations(recommendations);

    // Extract time/commitment recommendations
    _addTimeCommitmentRecommendations(recommendations);

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
- [ ] Create FitnessRecommendation model class
- [ ] Create recommendation_extractor.dart extension
- [ ] Implement priority recommendation logic
- [ ] Implement approach recommendation logic
- [ ] Implement equipment/location recommendation logic
- [ ] Implement health/safety recommendation logic
- [ ] Implement time/commitment recommendation logic
- [ ] Add recommendations section to OnboardingSummaryView
- [ ] Style recommendation cards with appropriate icons/colors
- [ ] Test with various fitness profiles

## Technical Notes
- Recommendations should be constructive and motivating
- Avoid medical advice or diagnoses
- Focus on what the user CAN do, not limitations
- Keep language clear and jargon-free
- Prioritize most impactful recommendations