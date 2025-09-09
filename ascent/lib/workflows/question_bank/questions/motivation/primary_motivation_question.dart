import 'package:flutter/material.dart';
import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../../onboarding_workflow/models/questions/question_option.dart';
import '../../views/question_types/single_choice_view.dart';
import '../onboarding_question.dart';
import '../../../../constants.dart';

/// Primary motivation question for understanding user's core fitness drivers.
/// 
/// This question identifies what primarily motivates the user to exercise,
/// which influences program design, messaging, and progress tracking preferences.
class PrimaryMotivationQuestion extends OnboardingQuestion {
  static const String questionId = 'primary_motivation';
  static final PrimaryMotivationQuestion instance = PrimaryMotivationQuestion._();
  PrimaryMotivationQuestion._();
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => PrimaryMotivationQuestion.questionId;
  
  @override
  String get questionText => 'What motivates you most to exercise?';
  
  @override
  String get section => 'motivation';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.singleChoice;
  
  @override
  List<QuestionOption> get options => [
    QuestionOption(
      value: AnswerConstants.physicalChanges,
      label: 'Seeing physical changes in my body',
      description: 'Visual progress through photos and measurements',
    ),
    QuestionOption(
      value: AnswerConstants.feelingStronger,
      label: 'Feeling stronger and more energetic',
      description: 'Focus on how exercise makes you feel',
    ),
    QuestionOption(
      value: AnswerConstants.performanceGoals,
      label: 'Achieving specific performance goals',
      description: 'Hitting targets like running times or lifting weights',
    ),
    QuestionOption(
      value: AnswerConstants.socialConnection,
      label: 'Social connection and community',
      description: 'Working out with others and group activities',
    ),
    QuestionOption(
      value: AnswerConstants.stressRelief,
      label: 'Stress relief and mental health',
      description: 'Using exercise to manage stress and mood',
    ),
    QuestionOption(
      value: AnswerConstants.healthLongevity,
      label: 'Health and longevity',
      description: 'Long-term health benefits and disease prevention',
    ),
  ];
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
  };
  
  
  //MARK: VALIDATION
  
  /// Validation is handled in the setter
  
  @override
  void fromJsonValue(dynamic json) {
    if (json is String) _primaryMotivation = json;
    else _primaryMotivation = null;
  }
  
  //MARK: ANSWER STORAGE
  
  String? _primaryMotivation;
  
  @override
  String? get answer => _primaryMotivation;
  
  /// Set the primary motivation (no validation needed - UI enforces valid options)
  void setPrimaryMotivation(String? value) => _primaryMotivation = value;
  
  /// Get the primary motivation as a typed String
  String? get primaryMotivation => _primaryMotivation;

  @override
  Widget buildAnswerWidget(
    Function() onAnswerChanged,
  ) {
    return SingleChoiceView(
      questionId: id,
      answers: {id: _primaryMotivation},
      onAnswerChanged: (questionId, value) {
        setPrimaryMotivation(value as String?);
        onAnswerChanged();
      },
      options: options,
    );
  }
}