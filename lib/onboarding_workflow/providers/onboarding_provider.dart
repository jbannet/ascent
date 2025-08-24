import 'package:flutter/foundation.dart';
import '../models/questions/question_configuration.dart';
import '../models/questions/question_section.dart';
import '../models/questions/onboarding_question.dart';
import '../models/answers/onboarding_answers.dart';
import '../models/state/onboarding_state.dart';

class OnboardingProvider extends ChangeNotifier {
  // State
  QuestionConfiguration? _questionConfig;
  OnboardingAnswers? _answers;
  OnboardingState _state = OnboardingState.initial();

  // Getters
  QuestionConfiguration? get questionConfig => _questionConfig;
  OnboardingAnswers? get answers => _answers;
  OnboardingState get state => _state;

  // Current question helpers
  QuestionSection? get currentSection {
    if (_questionConfig == null || 
        _state.currentSectionIndex >= _questionConfig!.sections.length) {
      return null;
    }
    return _questionConfig!.sections[_state.currentSectionIndex];
  }

  OnboardingQuestion? get currentQuestion {
    final section = currentSection;
    if (section == null || 
        _state.currentQuestionIndex >= section.questions.length) {
      return null;
    }
    return section.questions[_state.currentQuestionIndex];
  }

  // Initialize onboarding with questions
  Future<void> initialize(QuestionConfiguration config) async {
    _questionConfig = config;
    _answers = OnboardingAnswers.empty(config.version);
    _state = OnboardingState.initial();
    
    // Start with first question
    if (config.sections.isNotEmpty && 
        config.sections.first.questions.isNotEmpty) {
      _state = _state.nextQuestion(
        questionId: config.sections.first.questions.first.id,
        sectionIndex: 0,
        questionIndex: 0,
      );
    }
    
    notifyListeners();
  }

  // Save answer for current question
  void saveAnswer(String questionId, dynamic value) {
    if (_answers == null) return;
    
    _answers = _answers!.withAnswer(questionId, value);
    _updateProgress();
    notifyListeners();
  }

  // Navigate to next question
  void nextQuestion() {
    if (_questionConfig == null) return;

    int sectionIndex = _state.currentSectionIndex;
    int questionIndex = _state.currentQuestionIndex + 1;

    // Check if we need to move to next section
    if (sectionIndex < _questionConfig!.sections.length) {
      final currentSection = _questionConfig!.sections[sectionIndex];
      
      if (questionIndex >= currentSection.questions.length) {
        // Move to next section
        sectionIndex++;
        questionIndex = 0;
      }

      // Check if we've reached the end
      if (sectionIndex >= _questionConfig!.sections.length) {
        completeOnboarding();
        return;
      }

      // Get next question that should be shown (considering conditions)
      final nextQuestion = _findNextVisibleQuestion(sectionIndex, questionIndex);
      if (nextQuestion != null) {
        _state = _state.nextQuestion(
          questionId: nextQuestion.question.id,
          sectionIndex: nextQuestion.sectionIndex,
          questionIndex: nextQuestion.questionIndex,
        );
      } else {
        // No more questions, complete onboarding
        completeOnboarding();
      }
    }

    _updateProgress();
    notifyListeners();
  }

  // Navigate to previous question
  void previousQuestion() {
    if (_questionConfig == null) return;

    int sectionIndex = _state.currentSectionIndex;
    int questionIndex = _state.currentQuestionIndex - 1;

    // Check if we need to move to previous section
    if (questionIndex < 0) {
      sectionIndex--;
      if (sectionIndex >= 0) {
        questionIndex = _questionConfig!.sections[sectionIndex].questions.length - 1;
      }
    }

    // Don't go before first question
    if (sectionIndex < 0) {
      sectionIndex = 0;
      questionIndex = 0;
    }

    // Get previous visible question
    final prevQuestion = _findPreviousVisibleQuestion(sectionIndex, questionIndex);
    if (prevQuestion != null) {
      _state = _state.previousQuestion(
        questionId: prevQuestion.question.id,
        sectionIndex: prevQuestion.sectionIndex,
        questionIndex: prevQuestion.questionIndex,
      );
    }

    notifyListeners();
  }

  // Skip current question
  void skipQuestion() {
    if (currentQuestion != null) {
      saveAnswer(currentQuestion!.id, null);
      nextQuestion();
    }
  }

  // Complete onboarding
  void completeOnboarding() {
    if (_answers != null) {
      _answers = _answers!.markCompleted();
      _state = _state.complete();
      notifyListeners();
      
      // Here you would typically save to Firebase and local storage
      _saveOnboardingData();
    }
  }

  // Check if question should be visible based on conditions
  bool _shouldShowQuestion(OnboardingQuestion question) {
    if (question.condition == null || _answers == null) {
      return true;
    }

    final condition = question.condition!;
    final answer = _answers!.getAnswer(condition.questionId);

    switch (condition.operator) {
      case 'equals':
        return answer == condition.value;
      case 'contains':
        if (answer is List) {
          return answer.contains(condition.value);
        }
        if (answer is String) {
          return answer.contains(condition.value);
        }
        return false;
      case 'isNotEmpty':
        if (answer == null) return false;
        if (answer is String) return answer.isNotEmpty;
        if (answer is List) return answer.isNotEmpty;
        return true;
      default:
        return true;
    }
  }

  // Find next visible question
  _NextQuestion? _findNextVisibleQuestion(int startSection, int startQuestion) {
    if (_questionConfig == null) return null;

    for (int s = startSection; s < _questionConfig!.sections.length; s++) {
      final section = _questionConfig!.sections[s];
      final startQ = (s == startSection) ? startQuestion : 0;
      
      for (int q = startQ; q < section.questions.length; q++) {
        final question = section.questions[q];
        if (_shouldShowQuestion(question)) {
          return _NextQuestion(question, s, q);
        }
      }
    }
    return null;
  }

  // Find previous visible question
  _NextQuestion? _findPreviousVisibleQuestion(int startSection, int startQuestion) {
    if (_questionConfig == null) return null;

    for (int s = startSection; s >= 0; s--) {
      final section = _questionConfig!.sections[s];
      final startQ = (s == startSection) ? startQuestion : section.questions.length - 1;
      
      for (int q = startQ; q >= 0; q--) {
        final question = section.questions[q];
        if (_shouldShowQuestion(question)) {
          return _NextQuestion(question, s, q);
        }
      }
    }
    return null;
  }

  // Update progress percentage
  void _updateProgress() {
    if (_questionConfig == null || _answers == null) return;

    int totalQuestions = 0;
    int answeredQuestions = 0;

    for (final section in _questionConfig!.sections) {
      for (final question in section.questions) {
        if (_shouldShowQuestion(question)) {
          totalQuestions++;
          if (_answers!.isAnswered(question.id)) {
            answeredQuestions++;
          }
        }
      }
    }

    _state = _state.withProgress(totalQuestions, answeredQuestions);
  }

  // Save onboarding data (placeholder for actual implementation)
  Future<void> _saveOnboardingData() async {
    // This will be implemented when we create the storage services
    // For now, just print to console
    if (kDebugMode) {
      print('Saving onboarding data...');
      print('Answers: ${_answers?.toJson()}');
    }
  }

  // Load existing onboarding state (if resuming)
  Future<void> loadExistingState() async {
    // This will be implemented when we create the storage services
    notifyListeners();
  }

  // Reset onboarding
  void reset() {
    if (_questionConfig != null) {
      initialize(_questionConfig!);
    }
  }

  @override
  void dispose() {
    // Clean up if needed
    super.dispose();
  }
}

// Helper class for navigation
class _NextQuestion {
  final OnboardingQuestion question;
  final int sectionIndex;
  final int questionIndex;

  _NextQuestion(this.question, this.sectionIndex, this.questionIndex);
}