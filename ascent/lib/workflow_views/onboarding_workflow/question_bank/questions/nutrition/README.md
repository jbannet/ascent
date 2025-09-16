# Nutrition Onboarding Flow

A 4-question progressive nutrition onboarding experience that builds a cumulative diet quality visualization. This replaces judgmental single-question approaches with an engaging, educational flow that makes users feel positive about building their nutrition profile.

## Overview

This system provides:

- **4 Sequential Questions**: Sugary treats, sodas, grains, and alcohol consumption
- **Progressive Chart Visualization**: Single persistent graph with 4 bars that builds as users answer
- **Positive Reinforcement**: Non-judgmental messaging focused on personalization
- **Privacy Handling**: Special "prefer not to say" option for alcohol question
- **Mobile-Optimized Design**: Follows existing BaseQuestionView patterns
- **Animation System**: Smooth transitions and chart building animations

## Files Structure

```
nutrition/
├── README.md                           # This documentation
├── sugary_treats_question.dart         # Question 1: Daily sweet treats (0-10)
├── sodas_question.dart                 # Question 2: Daily sodas/sweet drinks (0-10)  
├── grains_question.dart                # Question 3: Daily grain servings (0-10)
├── alcohol_question.dart               # Question 4: Weekly alcohol (0-20+, privacy option)
├── nutrition_questions_integration.dart # Integration helper and utilities
└── views/
    ├── diet_quality_chart.dart         # Persistent 4-bar chart widget
    ├── diet_quality_summary.dart       # Final completion summary
    └── nutrition_onboarding_demo.dart  # Demo implementation (remove after integration)
```

## Key Features

### 1. Progressive Chart Visualization

The `DietQualityChart` widget shows a persistent 4-bar chart that:

- Starts empty and builds as users answer questions
- Uses distinctive colors for each metric (treats=coral, sodas=yellow, grains=green, alcohol=purple)  
- Animates new bars with elastic animation for engagement
- Shows healthy vs. less-healthy ranges with color intensity
- Includes sleeping kettlebell mascot for encouragement

### 2. Positive Scoring System

Unlike traditional "diet assessment" approaches, this system:

- Uses **non-judgmental language** ("sweet treats you enjoy" vs "junk food")
- Provides **educational context** (examples of what counts)
- Focuses on **personalization benefits** ("helps us customize your plan")
- Shows **progress building** rather than scoring/grading
- Celebrates **completion** with encouragement

### 3. Privacy-First Alcohol Question

The alcohol question includes:

- **Slider input** for numeric answers (0-20 drinks/week)
- **"Prefer not to say" button** that completely hides the slider
- **Private data messaging** to reassure users
- **Visual feedback** when privacy mode is selected
- **Validation** that accepts both numeric and privacy answers

### 4. Mobile-Optimized UX

Following established app patterns:

- **BaseQuestionView structure** with reason sections and gradient swoosh styling
- **Material Design colors** (purple primary, teal accents) 
- **Quick single-tap answers** preferred (sliders vs. complex inputs)
- **Progress indicators** and completion feedback
- **Haptic feedback** on important interactions

## Usage

### Basic Integration

```dart
import 'package:ascent/workflows/question_bank/questions/nutrition/nutrition_questions_integration.dart';

// Get all questions in order
final questions = NutritionQuestionsIntegration.nutritionQuestions;

// Check if user completed nutrition flow
final isComplete = answers.isNutritionComplete;

// Get completion progress (0.0 to 1.0)
final progress = answers.nutritionProgress;

// Get structured nutrition data
final profile = answers.nutritionProfile;
```

### Individual Question Usage

```dart
import 'package:ascent/workflows/question_bank/questions/nutrition/sugary_treats_question.dart';

// Render a question
Widget buildQuestion(Map<String, dynamic> currentAnswers, Function onAnswerChanged) {
  return SugaryTreatsQuestion.instance.renderQuestionView(
    currentAnswers: currentAnswers,
    onAnswerChanged: onAnswerChanged,
    accentColor: theme.colorScheme.primary,
  );
}

// Get typed answer
final treatsCount = SugaryTreatsQuestion.instance.getSugaryTreatsCount(answers);
```

### Chart Integration

```dart
import 'package:ascent/workflows/question_bank/views/nutrition/diet_quality_chart.dart';

// Show progressive chart
DietQualityChart(
  nutritionData: {
    'sugary_treats': 2,
    'sodas': 1, 
    'grains': null, // Not answered yet
    'alcohol': null,
  },
  activeMetrics: ['sugary_treats', 'sodas'], // Show these bars
  currentQuestionId: 'grains', // Highlight this question
  encouragementMessage: 'Great progress! Keep building your profile. 🌟',
)
```

## Question Details

### 1. Sugary Treats Question (`sugary_treats`)

- **Range**: 0-10 treats per day
- **Healthy Range**: 0-2 (shown in full color)
- **Examples**: Cookies, candy, pastries, ice cream
- **Messaging**: "Sweet treats you enjoy" (positive framing)

### 2. Sodas Question (`sodas`) 

- **Range**: 0-10 drinks per day
- **Healthy Range**: 0-1 (shown in full color)
- **Examples**: Regular sodas, energy drinks, sweetened juices
- **Note**: Diet sodas and water don't count

### 3. Grains Question (`grains`)

- **Range**: 0-10 servings per day  
- **Healthy Range**: 3-8 (shown in full color)
- **Examples**: Bread, rice, pasta, cereal
- **Note**: Higher values can be healthy (unlike treats/sodas)

### 4. Alcohol Question (`alcohol`)

- **Range**: 0-20+ drinks per week
- **Healthy Range**: 0-7 (shown in full color)
- **Privacy**: "Prefer not to say" option hides numeric input
- **Examples**: Standard drink definitions provided

## Animation System

The chart uses a two-controller animation system:

1. **Chart Controller** (800ms): Overall chart fade-in and scale
2. **Bar Controller** (600ms): Individual bar elastic animation when new metrics are added

```dart
// Animation triggers
void didUpdateWidget(DietQualityChart oldWidget) {
  if (widget.activeMetrics.length > oldWidget.activeMetrics.length) {
    _barController.reset();
    _barController.forward(); // Animate new bar
  }
}
```

## Color System

Following the app's established color palette:

```dart
static const List<DietMetric> metrics = [
  DietMetric(id: 'sugary_treats', color: Color(0xFFFF6F61)), // restGoalCoral
  DietMetric(id: 'sodas', color: Color(0xFFE9C46A)),         // congratulationsYellow  
  DietMetric(id: 'grains', color: Color(0xFF29AD8F)),        // continueGreen
  DietMetric(id: 'alcohol', color: Color(0xFF8A4FD3)),       // basePurple
];
```

## Data Flow

```
User Input → Question Validation → Chart Update → Answer Storage → Next Question
     ↓
 Progress Tracking → Completion Check → Summary View → Continue to Fitness Planning
```

## Integration Points

### With Existing Onboarding

```dart
// Add to question sequence in initial_questions.json or provider
final nutritionQuestionIds = [
  'sugary_treats',
  'sodas', 
  'grains',
  'alcohol',
];

// Check completion before proceeding
if (NutritionQuestionsIntegration.areAllQuestionsCompleted(answers)) {
  // Show summary or continue to next onboarding section
}
```

### With Fitness Planning

```dart
// Use nutrition data in fitness plan generation
final nutritionProfile = answers.nutritionProfile;

if (nutritionProfile['grains'] < 3) {
  // Recommend pre-workout snacks
}

if (nutritionProfile['alcohol_private'] != true && nutritionProfile['alcohol'] > 7) {
  // Adjust recovery recommendations  
}
```

## Testing

The demo widget (`nutrition_onboarding_demo.dart`) provides a complete working example:

```dart
// To test the flow
Navigator.push(context, MaterialPageRoute(
  builder: (context) => NutritionOnboardingDemo(),
));
```

## Accessibility

- **Semantic labels** on all interactive elements
- **High contrast** color combinations (4.5:1 ratio minimum)
- **Keyboard navigation** support through Flutter widgets
- **Screen reader** friendly with descriptive text
- **Focus management** between questions

## Performance Notes

- **Lazy loading** of chart animations
- **Efficient rebuilds** using AnimatedBuilder
- **Memory management** with proper controller disposal
- **Smooth 60fps** animations on target devices

## Future Enhancements

Potential future improvements:

1. **Detailed nutritional breakdowns** (vitamins, macros)
2. **Photo-based food logging** integration  
3. **Meal planning recommendations** based on profile
4. **Progress tracking** over time
5. **Social sharing** of achievements
6. **Gamification elements** (streaks, badges)

---

This nutrition onboarding system transforms a potentially sensitive topic into an engaging, educational experience that users want to complete. The progressive visualization and positive messaging approach leads to higher completion rates and more accurate self-reporting.