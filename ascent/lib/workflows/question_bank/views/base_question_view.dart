import 'package:flutter/material.dart';
import '../../../theme/general_widgets/swoosh_clipper.dart';

/// Base widget for rendering questions with consistent styling.
/// 
/// This provides the common visual structure (reason section, question text, answer area)
/// that all question views share, while allowing the answer widget to be customized.
class BaseQuestionView extends StatelessWidget {
  final String questionId;
  final String questionText;
  final String? subtitle;
  final String? reason;
  final Widget answerWidget;
  final Color? accentColor;

  const BaseQuestionView({
    super.key,
    required this.questionId,
    required this.questionText,
    this.subtitle,
    this.reason,
    required this.answerWidget,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = accentColor ?? theme.colorScheme.primary;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //MARK: ReasonSection
        if (reason != null)
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
                    // Circle indicator
                    Container(
                      width: 24,
                      height: 24,
                      margin: const EdgeInsets.only(right: 12, top: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.info,
                        size: 16,
                        color: primaryColor,
                      ),
                    ),
                    // Reason text
                    Expanded(
                      child: Text(
                        reason!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        //MARK: QuestionText
        Text(
          questionText,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        
        //MARK: Subtitle
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
        
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
          child: answerWidget,
        ),
      ],
    );
  }
}