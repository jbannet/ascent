import 'package:flutter/foundation.dart';
import '../../../services/local_storage/local_storage_service.dart';
import '../../question_bank/registry/question_bank.dart';
import '../../question_bank/questions/onboarding_question.dart';
//import '../../services/firebase/firebase_storage_service.dart';

class OnboardingProvider extends ChangeNotifier {
  // State
  List<OnboardingQuestion> _onboardingQuestions = [];
  int _currentQuestionNumber = 0;
  bool _onboardingComplete = false;

  // Getters
  List<OnboardingQuestion> get onboardingQuestions => _onboardingQuestions;
  int get currentQuestionNumber => _currentQuestionNumber;
  bool get isOnboardingComplete => _onboardingComplete;
  
  // Get current question
  OnboardingQuestion? get currentOnboardingQuestion {
    if (_currentQuestionNumber >= 0 && _currentQuestionNumber < _onboardingQuestions.length) {
      return _onboardingQuestions[_currentQuestionNumber];
    }
    return null;
  }

  // Load onboarding data - questions from question bank, answers from local storage
  Future<void> initialize() async {
    // Load questions from the question bank
    _onboardingQuestions = QuestionBank.initialize();
    
    if (_onboardingQuestions.isEmpty) {
      throw Exception('Failed to load questions from question bank');
    }

    // Load answers from local storage and populate questions
    final Map<String, dynamic> storedAnswers = await LocalStorageService.loadAnswers();
    QuestionBank.fromJson(storedAnswers);
    debugPrint('Loaded ${storedAnswers.length} answers from local storage');
  }

//MARK: STORAGE
  // Save to local storage
  Future<void> saveAnswersIncomplete() async {    
    final answersJson = QuestionBank.toJson();
    await LocalStorageService.saveAnswers(answersJson);
  }

  // Save to Firebase and Local Storage
  Future<void> saveAnswersComplete() async {
    final answersJson = QuestionBank.toJson();
    //await FirebaseStorageService.saveAnswers(answersJson);
    await LocalStorageService.saveAnswers(answersJson);
  }

  // Update answer for a specific question
  void updateQuestionAnswer(String questionId, dynamic answerValue) {
    final question = QuestionBank.getQuestion(questionId);
    if (question != null) {
      question.fromJsonValue(answerValue);
      notifyListeners();
    }
  }

  // Check if current question has been answered
  bool hasAnswerForCurrentQuestion() {
    final currentQuestion = currentOnboardingQuestion;
    if (currentQuestion == null) return false;
    
    final answer = currentQuestion.answer;
    return answer != null && answer.toString().trim().isNotEmpty;
  }

  // Check if current answer is valid
  bool isCurrentAnswerValid() {
    final currentQuestion = currentOnboardingQuestion;
    if (currentQuestion == null) return false;
    
    return currentQuestion.hasAnswer;
  }

  // Skip current question (for optional questions)
  void skipQuestion() {
    if (_onboardingQuestions.isEmpty) return;
  
    // Save current progress before navigating
    saveAnswersIncomplete();
    
    // Find next visible question
    while (_currentQuestionNumber < _onboardingQuestions.length - 1) {
      _currentQuestionNumber++;
      if (_onboardingQuestions[_currentQuestionNumber].shouldShow({})) {
        notifyListeners();
        return;
      }
    }
    markOnboardingCompleted();
  }

//MARK: NAVIGATION
  
  // Get completion percentage
  double get percentComplete {
    int questionCount = _onboardingQuestions.length;

    return questionCount == 0 ? 0 : (_currentQuestionNumber / questionCount) * 100;
  }
  
  // Navigate to next question and save answers to disk
  void nextQuestion() {
    if (_onboardingQuestions.isEmpty) return;
    
    // Validate required questions before proceeding
    final currentQuestion = currentOnboardingQuestion;
    if (currentQuestion != null) {
      final isRequired = currentQuestion.config?['isRequired'] ?? false;
      if (isRequired && !isCurrentAnswerValid()) {
        // Don't proceed if required question is not answered validly
        return;
      }
    }
  
    // Save current progress before navigating
    saveAnswersIncomplete();
    
    // Find next visible question
    while (_currentQuestionNumber < _onboardingQuestions.length - 1) {
      _currentQuestionNumber++;
      if (_onboardingQuestions[_currentQuestionNumber].shouldShow({})) {
        notifyListeners();
        return;
      }
    }
    markOnboardingCompleted();
  }
  
  // Navigate to previous question and save answer to disk
  void prevQuestion() {
    if (_currentQuestionNumber <= 0) return;
    saveAnswersIncomplete();

    // Find previous visible question
    while (_currentQuestionNumber > 0) {
      _currentQuestionNumber--;
      if (_onboardingQuestions[_currentQuestionNumber].shouldShow({})) {
        notifyListeners();
        return;
      }
    }
  }
  
  // Mark onboarding as completed
  void markOnboardingCompleted() {
    _onboardingComplete = true;
    notifyListeners();
    saveAnswersComplete();
  }
}