import 'package:flutter/material.dart';
import '../../../question_bank/questions/nutrition/nutrition_questions_integration.dart';
import 'diet_quality_summary.dart';

/// Demo widget showing the complete nutrition onboarding flow.
/// 
/// This demonstrates how to integrate the 4 nutrition questions into
/// an existing onboarding flow with the progressive chart visualization.
/// Remove this file once integrated into the actual onboarding system.
class NutritionOnboardingDemo extends StatefulWidget {
  const NutritionOnboardingDemo({super.key});

  @override
  State<NutritionOnboardingDemo> createState() => _NutritionOnboardingDemoState();
}

class _NutritionOnboardingDemoState extends State<NutritionOnboardingDemo> {
  PageController _pageController = PageController();
  int _currentQuestionIndex = 0;
  final Map<String, dynamic> _answers = {};
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isComplete = _currentQuestionIndex >= NutritionQuestionsIntegration.questionIds.length;
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text('Nutrition Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Progress indicator
          if (!isComplete) _buildProgressIndicator(theme),
          
          // Question content
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentQuestionIndex = index;
                });
              },
              itemCount: NutritionQuestionsIntegration.questionIds.length + 1, // +1 for summary
              itemBuilder: (context, index) {
                if (index >= NutritionQuestionsIntegration.questionIds.length) {
                  // Summary page
                  return DietQualitySummary(
                    answers: _answers,
                    onContinue: () {
                      // In real app, navigate to next onboarding step
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Nutrition profile complete! 🎉'),
                          backgroundColor: theme.colorScheme.primary,
                        ),
                      );
                    },
                  );
                }
                
                final questionId = NutritionQuestionsIntegration.questionIds[index];
                final question = NutritionQuestionsIntegration.getQuestionById(questionId);
                
                if (question == null) {
                  return Center(child: Text('Question not found'));
                }
                
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: question.renderQuestionView(
                    onAnswerChanged: () => _onAnswerChanged(question.id, question.answer),
                    accentColor: theme.colorScheme.primary,
                  ),
                );
              },
            ),
          ),
          
          // Navigation buttons
          if (!isComplete) _buildNavigationButtons(theme),
        ],
      ),
    );
  }
  
  Widget _buildProgressIndicator(ThemeData theme) {
    final progress = (_currentQuestionIndex + 1) / NutritionQuestionsIntegration.questionIds.length;
    
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Building Your Profile',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              Text(
                '${_currentQuestionIndex + 1} of ${NutritionQuestionsIntegration.questionIds.length}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNavigationButtons(ThemeData theme) {
    final canGoBack = _currentQuestionIndex > 0;
    final currentQuestionId = NutritionQuestionsIntegration.questionIds[_currentQuestionIndex];
    final currentQuestion = NutritionQuestionsIntegration.getQuestionById(currentQuestionId);
    final canContinue = currentQuestion?.hasAnswer ?? false;
    final isLastQuestion = _currentQuestionIndex >= NutritionQuestionsIntegration.questionIds.length - 1;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          if (canGoBack)
            Expanded(
              child: OutlinedButton(
                onPressed: () => _goToPreviousQuestion(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text('Back'),
              ),
            )
          else
            Expanded(child: SizedBox()),
          
          const SizedBox(width: 16),
          
          // Continue button
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: canContinue ? () => _goToNextQuestion() : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                isLastQuestion ? 'View Summary' : 'Continue',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _onAnswerChanged(String questionId, dynamic answer) {
    setState(() {
      _answers[questionId] = answer;
    });
  }
  
  void _goToNextQuestion() {
    if (_currentQuestionIndex < NutritionQuestionsIntegration.questionIds.length) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  void _goToPreviousQuestion() {
    if (_currentQuestionIndex > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}