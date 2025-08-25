# Claude Onboarding Workflow Documentation

This document provides a comprehensive guide to understanding and working with the onboarding workflow system in the Ascent fitness app.

## 📁 Architecture Overview

The onboarding system is built around a dynamic question flow that adapts based on user responses. It follows a clean architecture pattern with clear separation of concerns.

### Core Principles
- **Dynamic Branching**: Questions appear/hide based on previous answers using conditional logic
- **Mutable State Management**: Direct mutations for performance (avoiding unnecessary copying)
- **JSON-Driven Configuration**: Questions loaded from JSON files for easy updates
- **Hybrid Storage**: Local storage (Hive) + Firebase for persistence
- **Widget Factory Pattern**: Type-safe widget creation from configuration

## 🏗️ Directory Structure

```
lib/onboarding_workflow/
├── models/                    # Data models
│   ├── answers/
│   │   └── onboarding_answers.dart    # User responses storage
│   └── questions/
│       ├── enum_question_type.dart    # Question type definitions
│       ├── question.dart             # Core question model
│       ├── question_condition.dart   # Conditional display logic
│       ├── question_list.dart        # Question collection
│       ├── question_option.dart      # Choice options
│       └── question_validation.dart  # Validation rules
├── providers/
│   └── onboarding_provider.dart      # State management (ChangeNotifier)
├── services/
│   ├── firebase/                     # Remote storage & sync
│   ├── local_storage/                # Hive database operations
│   └── load_configuration/           # JSON loading utilities
├── views/
│   ├── onboarding_survey_container.dart  # Main container
│   ├── question_view.dart                # Individual question display
│   └── summary_cards/                    # Progress summaries
├── widgets/
│   └── onboarding/
│       ├── onboarding_progress_bar.dart  # Progress indicator
│       └── question_input/               # Input widgets
│           ├── factory_question_inputs.dart  # Widget factory
│           ├── text_input_widget.dart
│           ├── number_input_widget.dart
│           ├── single_choice_widget.dart
│           ├── multiple_choice_widget.dart
│           ├── slider_widget.dart
│           ├── date_picker_widget.dart
│           └── ranking_widget.dart
└── config/
    └── initial_questions.json        # Default question configuration
```

## 🔄 Data Flow

### 1. Initialization Flow
```dart
OnboardingProvider.initialize()
├── Load local questions/answers from Hive
├── Check Firebase for newer question versions
├── Update local storage if Firebase version is newer
├── Clear answers if questions were updated (prevent mismatches)
└── Notify listeners
```

### 2. Question Navigation Flow
```dart
User Interaction → Widget → OnboardingProvider
                           ├── updateQuestionAnswer(id, value)
                           ├── saveAnswersIncomplete() (to Hive)
                           ├── nextQuestion() / prevQuestion()
                           └── notifyListeners()
```

### 3. Completion Flow
```dart
Last Question → markOnboardingCompleted()
              ├── _onboardingComplete = true
              ├── saveAnswersComplete() (to Firebase + Hive)
              └── notifyListeners()
```

## 📝 Core Models

### Question Model
The `Question` class is the core unit of the onboarding system:

```dart
class Question {
  final String id;                    // Unique identifier for answers/conditions
  final String question;              // Display text
  final String section;               // Grouping (e.g., "personal_info")
  final EnumQuestionType type;        // Widget type to render
  final List<QuestionOption>? options; // For choice questions
  final QuestionCondition? condition;  // When to show this question
  final String? subtitle;             // Additional context
  final Map<String, dynamic>? answerConfigurationSettings; // Widget config
}
```

**Key Methods:**
- `shouldShow(answers)`: Determines visibility based on conditions
- `buildAnswerWidget()`: Creates appropriate input widget via factory

### OnboardingAnswers Model
Stores user responses with **mutable operations** for performance:

```dart
class OnboardingAnswers {
  bool completed;                     // Completion status (mutable)
  final Map<String, dynamic> answers; // Question ID → Answer value
  
  // Direct mutations (preferred approach)
  void setAnswer(String questionId, dynamic value);
  void markCompleted(); // Sets completed = true directly
}
```

**Storage Format:** Answers are stored as `questionId → value` where value type depends on question:
- `String` for text input
- `double` for numbers/sliders  
- `String` for single choice (selected option value)
- `List<String>` for multiple choice (selected option values)
- `DateTime` for date pickers

### Question Types
```dart
enum EnumQuestionType {
  textInput,      // Free text entry
  numberInput,    // Numeric input with validation
  singleChoice,   // Radio buttons (one selection)
  multipleChoice, // Checkboxes (multiple selections)
  slider,         // Range slider with min/max/step
  datePicker      // Calendar selection
}
```

## 🎯 Conditional Logic System

Questions can be shown/hidden dynamically using `QuestionCondition`:

```dart
class QuestionCondition {
  final String questionId;  // Reference to previous question
  final String operator;    // Comparison method
  final dynamic value;      // Expected value
}
```

**Supported Operators:**
- `"equals"`: Exact match (`answer == value`)
- `"contains"`: List/string contains (`answer.contains(value)`)
- `"isNotEmpty"`: Answer exists and has content

**Example JSON Configuration:**
```json
{
  "id": "weight_goal",
  "question": "How much weight do you want to lose?",
  "type": "slider",
  "condition": {
    "question_id": "fitness_goals",
    "operator": "contains", 
    "value": "lose_weight"
  },
  "config": {
    "minValue": 5.0,
    "maxValue": 100.0,
    "unit": "lbs"
  }
}
```

## 🏭 Widget Factory Pattern

The `FactoryQuestionInputs` class creates widgets from questions:

```dart
// 1. Build configuration map from question + runtime context
final config = {
  'questionId': question.id,
  'title': question.question,
  'currentValue': currentAnswers[question.id],
  'onAnswerChanged': callback,
  ...question.answerConfigurationSettings, // Spread JSON config
};

// 2. Route to appropriate widget's fromConfig constructor
switch (question.type) {
  case EnumQuestionType.textInput:
    return TextInputWidget.fromConfig(config);
  // ...other types
}
```

**All input widgets follow the pattern:**
```dart
class SomeInputWidget extends StatefulWidget {
  // Constructor with required parameters
  SomeInputWidget({required this.questionId, required this.onAnswerChanged, ...});
  
  // Static factory for configuration-based creation
  static SomeInputWidget fromConfig(Map<String, dynamic> config) {
    // Validate required fields
    // Extract parameters from config
    // Return widget instance
  }
}
```

## 💾 Storage Architecture

### Dual Storage Strategy
- **Local Storage (Hive)**: Immediate persistence, offline access
- **Firebase Storage**: Cloud sync, version management, multi-device support

### Version Management
```dart
// Check for newer questions from Firebase
int localVersion = await LocalStorageService.getQuestionVersion();
int firebaseVersion = await FirebaseStorageService.getQuestionVersion();

if (localVersion < firebaseVersion) {
  // Update questions from Firebase
  // Clear answers to prevent mismatches with new questions
}
```

### Storage Keys (Constants)
```dart
// From AppConstants
static const String questionBoxName = 'questions';
static const String answerBoxName = 'answers'; 
static const String questionsStorageKey = 'questionsList';
static const String answersStorageKey = 'answersList';
```

## 🎨 UI Components

### Question Display Structure
Each question follows a consistent layout in `QuestionView`:

```dart
Column(
  children: [
    // 1. Reason Section (purple gradient with swoosh design)
    Container(
      // Purple gradient background
      child: Row([
        "🟣", // Purple emoji indicator
        "REASON: [explanation text]"
      ])
    ),
    
    // 2. Question Content
    // - Question text
    // - Input widget (from factory)
    
    // 3. Navigation
    // - Previous/Next buttons
  ]
)
```

### Progress Tracking
```dart
// OnboardingProvider provides:
double get percentComplete {
  return (answeredCount / questionCount) * 100;
}
```

## 🧪 Testing Strategy

Tests are organized by widget type with comprehensive coverage:

### Test Structure
```
tests/onboarding_workflow/widgets/onboarding/question_input/
├── test_helpers.dart              # Shared test utilities
├── test_single_choice_widget.dart
├── test_multiple_choice_widget.dart  
├── test_slider_widget.dart
├── test_number_input_widget.dart
├── test_date_picker_widget.dart
└── test_ranking_widget.dart
```

### Test Helpers Pattern
```dart
// Mock callbacks for different return types
class MockCallback { void call(String questionId, dynamic value); }
class MockMultipleChoiceCallback { void call(String questionId, List<String> values); }
class MockNumericCallback { void call(String questionId, double value); }
class MockDateCallback { void call(String questionId, DateTime value); }

// Test data factories
static List<SingleChoiceOption> createSingleChoiceOptions();
static Map<String, dynamic> createBasicConfig({...});
```

### Test Coverage Areas
- Widget creation and configuration
- User interaction (taps, text input, slider dragging)
- Validation and error states
- Callback invocation with correct parameters
- fromConfig constructor validation
- Dynamic updates and state changes

## 🔧 Development Patterns

### Configuration Over Code
Questions are defined in JSON rather than hardcoded:
```json
{
  "version": "1.0",
  "questions": [
    {
      "id": "user_name",
      "question": "What's your name?",
      "section": "personal_info",
      "type": "text_input",
      "config": {
        "isRequired": true,
        "minLength": 2,
        "placeholder": "Enter your full name"
      }
    }
  ]
}
```

### Mutable State for Performance
Unlike typical Flutter immutable patterns, this system uses direct mutations:
```dart
// Preferred: Direct mutation
void setAnswer(String questionId, dynamic value) => answers[questionId] = value;
void markCompleted() => completed = true;

// Avoided: Copying entire object for single field change
OnboardingAnswers copyWith({bool? completed}) => OnboardingAnswers(...);
```

### Error Handling Philosophy
- **Graceful Degradation**: Return empty objects rather than throwing exceptions
- **Local Fallbacks**: Use local storage when Firebase unavailable
- **Validation at Widget Level**: Each widget validates its own configuration

## 🚀 Common Tasks

### Adding a New Question Type
1. Add enum value to `EnumQuestionType`
2. Update `QuestionTypeExtension.fromJson()`
3. Create new widget following the pattern:
   ```dart
   class NewWidget extends StatefulWidget {
     static NewWidget fromConfig(Map<String, dynamic> config) { ... }
   }
   ```
4. Add case to `FactoryQuestionInputs.createWidget()`
5. Write comprehensive tests

### Modifying Question Flow
1. Update `config/initial_questions.json`
2. Add any new conditional logic to existing questions
3. Test the flow end-to-end
4. Update Firebase configuration if needed

### Debugging Common Issues
- **Question not showing**: Check `shouldShow()` logic and previous answer values
- **Widget creation failing**: Validate configuration keys in `fromConfig()`
- **Storage issues**: Check Hive box initialization and Firebase connectivity
- **Navigation stuck**: Verify question indices and completion logic

## 📋 Code Style Guidelines

### Naming Conventions
- **Files**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Variables/Methods**: `camelCase`
- **Constants**: `SCREAMING_SNAKE_CASE`
- **Question IDs**: `snake_case` (e.g., `user_name`, `fitness_goals`)

### Documentation Standards
- All public classes/methods have comprehensive dartdoc comments
- Include usage examples in complex methods
- Document the "why" not just the "what"
- Use `///` for public API documentation

### Import Organization
```dart
// 1. Flutter/Dart SDK
import 'package:flutter/material.dart';

// 2. External packages  
import 'package:provider/provider.dart';

// 3. Internal app imports
import '../models/questions/question.dart';
import '../services/local_storage/local_storage_service.dart';
```

This documentation should give you everything needed to understand and extend the onboarding workflow system effectively!