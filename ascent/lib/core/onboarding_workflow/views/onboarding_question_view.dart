import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../../question_bank/questions/onboarding_question.dart';

/// Widget that renders an OnboardingQuestion using its self-rendering capability.
/// 
/// This replaces the old QuestionView that used complex switch statements
/// to render different question types. Now questions know how to render themselves.
class OnboardingQuestionView extends StatelessWidget {
  final OnboardingQuestion question;
  final Color? accentColor;

  const OnboardingQuestionView({
    super.key,
    required this.question,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OnboardingProvider>();
    
    // Let the question render itself using its self-rendering capability
    return question.renderQuestionView(
      currentAnswers: _buildCurrentAnswersMap(provider),
      onAnswerChanged: (questionId, value) => provider.updateQuestionAnswer(questionId, value),
      accentColor: accentColor,
    );
  }
  
  /// Build a map of current answers for the question rendering system
  Map<String, dynamic> _buildCurrentAnswersMap(OnboardingProvider provider) {
    final answers = <String, dynamic>{};
    
    // Add the current question's answer
    final currentAnswer = provider.onboardingAnswers.getAnswer(question.id);
    if (currentAnswer != null) {
      answers[question.id] = currentAnswer;
    }
    
    // Add all other answers in case questions need context from other answers
    // This is useful for conditional questions or questions that depend on previous answers
    for (final q in provider.onboardingQuestions) {
      final answer = provider.onboardingAnswers.getAnswer(q.id);
      if (answer != null) {
        answers[q.id] = answer;
      }
    }
    
    return answers;
  }
}