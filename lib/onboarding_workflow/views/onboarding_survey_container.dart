import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding/onboarding_progress_bar.dart';
import '../../theme/general_widgets/buttons/universal_elevated_button.dart';
import '../../theme/general_widgets/buttons/universal_outlined_button.dart';
import 'question_view.dart';

class OnboardingSurveyContainer extends StatelessWidget {
  final VoidCallback? onComplete;

  const OnboardingSurveyContainer({
    super.key,
    this.onComplete,
  });

  //MARK: STRUCTURE
  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, provider, child) {
        if (provider.isOnboardingComplete) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onComplete?.call();
          });
        }
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                OnboardingProgressBar(
                  sectionName: provider.currentQuestion?.section ?? 'ONBOARDING',
                  progressPercentage: provider.percentComplete,
                  currentQuestionNumber: provider.currentQuestionNumber,
                  totalQuestionCount: provider.questionList.length,
                ),
                Expanded(
                  child: _buildContent(provider),
                ),
                _buildNavigationButtons(context, provider),
              ],
            ),
          ),
        );
      },
    );
  }

  //MARK: CONTENT
  Widget _buildContent(OnboardingProvider provider) {
    final currentQuestion = provider.currentQuestion;
    
    if (currentQuestion == null) {
      return const Center(
        child: Text('Loading questions...'),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: QuestionView(
        question: currentQuestion,
      ),
    );
  }
  
  Widget _buildNavigationButtons(BuildContext context, OnboardingProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          if (provider.currentQuestionNumber > 0)
            Expanded(
              child: UniversalOutlinedButton(
                onPressed: provider.prevQuestion,
                child: const Text('Previous'),
              ),
            )
          else
            const Expanded(child: SizedBox()),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: UniversalElevatedButton(
              onPressed: provider.nextQuestion,
              child: const Text('Next'),
            ),
          ),
        ],
      ),
    );
  }
}