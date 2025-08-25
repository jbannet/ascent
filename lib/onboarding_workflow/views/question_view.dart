import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/questions/question.dart';
import '../providers/onboarding_provider.dart';
import '../../theme/general_widgets/swoosh_clipper.dart';

class QuestionView extends StatelessWidget {
  final Question question;
  final Color? accentColor;

  const QuestionView({
    super.key,
    required this.question,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = accentColor ?? theme.colorScheme.primary;
    final provider = context.watch<OnboardingProvider>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //MARK: ReasonSection
        Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 24),
            child: ClipPath(
              clipper: SwooshClipper(),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryColor,
                      primaryColor.withValues(alpha: 0.8),
                      primaryColor.withValues(alpha: 0.6),
                    ],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 16, 40, 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Purple circle emoji indicator
                    Container(
                      width: 24,
                      height: 24,
                      margin: const EdgeInsets.only(right: 12, top: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          '🟣',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                    
                    // Reason content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'REASON:',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                          
                          const SizedBox(height: 6),
                          
                          // Explanation text
                          Text(
                            question.section.replaceAll('_', ' ').toUpperCase(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        //MARK: QuestionText
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: primaryColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Text(
            question.question,
            style: theme.textTheme.labelMedium?.copyWith(
              color: primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        //MARK: AnswerWidget
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: question.buildAnswerWidget(
            currentAnswers: {question.id: provider.onboardingAnswers.getAnswer(question.id)},
            onAnswerChanged: (questionId, value) => provider.updateQuestionAnswer(questionId, value),
          ),
        ),
      ],
    );
  }
}
