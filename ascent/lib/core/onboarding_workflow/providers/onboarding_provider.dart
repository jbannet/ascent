import 'package:flutter/foundation.dart';
import '../models/questions/question_list.dart';
import '../models/questions/question.dart';
import '../models/answers/onboarding_answers.dart';
import '../../../services/local_storage/local_storage_service.dart';
import '../../../services/load_configuration/question_configuration_service.dart';
//import '../../services/firebase/firebase_storage_service.dart';

class OnboardingProvider extends ChangeNotifier {
  // State
  QuestionList _questionList = QuestionList.empty();
  OnboardingAnswers _onboardingAnswers = OnboardingAnswers.empty();
  int _currentQuestionNumber = 0;
  bool _onboardingComplete = false;

  // Getters
  QuestionList get questionList => _questionList;
  OnboardingAnswers get onboardingAnswers => _onboardingAnswers;
  int get currentQuestionNumber => _currentQuestionNumber;
  bool get isOnboardingComplete => _onboardingComplete;

  // Load onboarding data - questions from JSON, answers from local storage
  Future<void> initialize() async {
    // Load questions directly from JSON file
    _questionList = await QuestionConfigurationService.loadInitialQuestions();
    
    if (!_questionList.isInitialized){
      throw Exception('Failed to load questions from JSON configuration');
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
  // Get current question object
  Question? get currentQuestion {
    return _questionList.getQuestionAtIndex(_currentQuestionNumber);
  } 
  
  // Get completion percentage
  double get percentComplete {
    int questionCount = _questionList.length;
    int answerCount = _onboardingAnswers.length;

    return questionCount == 0 ? 0 : (answerCount / questionCount) * 100;
  }
  
  // Navigate to next question and save answers to disk
  void nextQuestion() {
    if (!_questionList.isInitialized) return;
    
    // Save current progress before navigating
    saveAnswersIncomplete();
    
    if (_currentQuestionNumber < _questionList.length - 1) {
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