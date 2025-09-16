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
      onAnswerChanged: () => provider.updateQuestionAnswer(question.id, question.answer),
      accentColor: accentColor,
    );
  }
}