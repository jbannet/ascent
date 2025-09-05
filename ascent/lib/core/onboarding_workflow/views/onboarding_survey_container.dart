import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding/onboarding_progress_bar.dart';
import '../../../theme/general_widgets/buttons/universal_elevated_button.dart';
import '../../../theme/general_widgets/buttons/universal_outlined_button.dart';
import 'onboarding_question_view.dart';

class OnboardingSurveyContainer extends StatefulWidget {
  final VoidCallback? onComplete;

  const OnboardingSurveyContainer({
    super.key,
    this.onComplete,
  });

  @override
  State<OnboardingSurveyContainer> createState() => _OnboardingSurveyContainerState();
}

class _OnboardingSurveyContainerState extends State<OnboardingSurveyContainer> {
  OnboardingProvider? _onboardingProvider;
  bool _isInitializing = true;
  String? _initializationError;

  @override
  void initState() {
    super.initState();
    _initializeOnboarding();
  }

  Future<void> _initializeOnboarding() async {
    try {
      debugPrint('Starting onboarding initialization...');
      
      // Create and initialize the provider (loads questions from JSON directly)
      final onboardingProvider = OnboardingProvider();
      await onboardingProvider.initialize();
      debugPrint('✅ OnboardingProvider initialized');
      
      setState(() {
        _onboardingProvider = onboardingProvider;
        _isInitializing = false;
      });
    } catch (e) {
      debugPrint('❌ Onboarding initialization failed: $e');
      setState(() {
        _initializationError = e.toString();
        _isInitializing = false;
      });
    }
  }

  //MARK: STRUCTURE
  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Initializing onboarding...',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    if (_initializationError != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Failed to initialize onboarding',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _initializationError!,
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isInitializing = true;
                    _initializationError = null;
                  });
                  _initializeOnboarding();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return ChangeNotifierProvider.value(
      value: _onboardingProvider!,
      child: Consumer<OnboardingProvider>(
        builder: (context, provider, child) {
          if (provider.isOnboardingComplete) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              widget.onComplete?.call();
            });
          }
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                children: [
                  OnboardingProgressBar(
                    sectionName: provider.currentOnboardingQuestion?.section ?? 'ONBOARDING',
                    progressPercentage: provider.percentComplete,
                    currentQuestionNumber: provider.currentQuestionNumber,
                    totalQuestionCount: provider.onboardingQuestions.length,
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
      ),
    );
  }

  //MARK: CONTENT
  Widget _buildContent(OnboardingProvider provider) {
    final currentQuestion = provider.currentOnboardingQuestion;
    
    if (currentQuestion == null) {
      return const Center(
        child: Text('Loading questions...'),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: OnboardingQuestionView(
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