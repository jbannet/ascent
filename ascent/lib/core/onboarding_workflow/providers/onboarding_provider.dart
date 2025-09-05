import 'package:flutter/foundation.dart';
import '../models/answers/onboarding_answers.dart';
import '../../../services/local_storage/local_storage_service.dart';
import '../../question_bank/registry/question_bank.dart';
import '../../question_bank/questions/onboarding_question.dart';
//import '../../services/firebase/firebase_storage_service.dart';

class OnboardingProvider extends ChangeNotifier {
  // State
  List<OnboardingQuestion> _onboardingQuestions = [];
  OnboardingAnswers _onboardingAnswers = OnboardingAnswers.empty();
  int _currentQuestionNumber = 0;
  bool _onboardingComplete = false;

  // Getters
  List<OnboardingQuestion> get onboardingQuestions => _onboardingQuestions;
  OnboardingAnswers get onboardingAnswers => _onboardingAnswers;
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

    // Load answers from local storage (keep this for persistence)
    final OnboardingAnswers localAnswers = await LocalStorageService.loadAnswers();
    
    if (!localAnswers.isInitialized) {
      _onboardingAnswers = OnboardingAnswers.empty();
    } else {
      _onboardingAnswers = localAnswers; 
    }
  }

//MARK: STORAGE
  // Save to local storage
  Future<void> saveAnswersIncomplete() async {    
    await LocalStorageService.saveAnswers(_onboardingAnswers);
  }

  // Save to Firebase and Local Storage
  Future<void> saveAnswersComplete() async {
    //await FirebaseStorageService.saveAnswers(_onboardingAnswers);
    await LocalStorageService.saveAnswers(_onboardingAnswers);
  }

  // Update answer for a specific question
  void updateQuestionAnswer(String questionId, dynamic answerValue) {
    _onboardingAnswers.setAnswer(questionId, answerValue);
    notifyListeners();
  }

//MARK: NAVIGATION
  
  // Get completion percentage
  double get percentComplete {
    int questionCount = _onboardingQuestions.length;
    int answerCount = _onboardingAnswers.length;

    return questionCount == 0 ? 0 : (answerCount / questionCount) * 100;
  }
  
  // Navigate to next question and save answers to disk
  void nextQuestion() {
    if (_onboardingQuestions.isEmpty) return;
    
    // Save current progress before navigating
    saveAnswersIncomplete();
    
    if (_currentQuestionNumber < _onboardingQuestions.length - 1) {
      _currentQuestionNumber++;
    } else {
      // Last question - mark as complete
      markOnboardingCompleted();
      return;
    }
    notifyListeners();
  }
  
  // Navigate to previous question and save answer to disk
  void prevQuestion() {
    if (_currentQuestionNumber > 0) {
      // Save current progress before navigating
      saveAnswersIncomplete();
      _currentQuestionNumber--;
      notifyListeners();
    }
  }
  
  // Mark onboarding as completed
  void markOnboardingCompleted() {
    _onboardingComplete = true;
    notifyListeners();
    saveAnswersComplete();
  }
}