import 'package:flutter/foundation.dart';
import '../models/questions/question_list.dart';
import '../models/questions/question.dart';
import '../models/answers/onboarding_answers.dart';
import '../services/local_storage/local_storage_service.dart';
import '../services/firebase/firebase_storage_service.dart';

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

  // Load onboarding data from local storage and Firebase
  // This should initialize empty objects if nothing saved yet, not null
  // It should also check for newer question versions in Firebase
  // and update the local question list if needed
  Future<void> initialize() async {
    // load questions and answers from local storage
    // this should return an empty object if nothing saved yet
    final QuestionList localQuestionList = await LocalStorageService.loadQuestions();
    final int questionVersion = await LocalStorageService.getQuestionVersion(); //0 if none saved
    final OnboardingAnswers localAnswers = await LocalStorageService.loadAnswers();
   
    // There should be a default question list stored at app signup the first time.
    if (!localQuestionList.isInitialized){
      throw Exception('Local question list failed to initialize');
      //TODO: Handle this error more gracefully and get from Firebase
    }

    int firebaseQuestionVersion = await FirebaseStorageService.getQuestionVersion();

    // Update questions if Firebase has a newer version
    if (questionVersion < firebaseQuestionVersion) {
      //loadQuestions call updates and saves new questions and version locally
      _questionList = await FirebaseStorageService.loadQuestions(localQuestionList, firebaseQuestionVersion);       
    } else {
      _questionList = localQuestionList; //necessary because questionList is final
    }

    if (!localAnswers.isInitialized) {
      _onboardingAnswers = await FirebaseStorageService.loadAnswers();
    } else {
      _onboardingAnswers = localAnswers; 
    }

    if (questionVersion < firebaseQuestionVersion) {
      // If we updated questions, we should clear answers to avoid mismatches
      _onboardingAnswers = OnboardingAnswers.empty();
      await LocalStorageService.saveAnswers(_onboardingAnswers);
    }
  }

//MARK: STORAGE
  Future<void> saveAnswersIncomplete() async {
    // Save to local storage
    await LocalStorageService.saveAnswers(_onboardingAnswers);
  }

  Future<void> saveAnswersComplete() async {
    // Save to Firebase and Local Storage
    await FirebaseStorageService.saveAnswers(_onboardingAnswers);
    await LocalStorageService.saveAnswers(_onboardingAnswers);
  }

  // Update answer for a specific question
  void updateQuestionAnswer(String questionId, dynamic answerValue) {
    _onboardingAnswers = _onboardingAnswers.withAnswer(questionId, answerValue);
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
  
  // Navigate to next question
  void nextQuestion() {
    if (!_questionList.isInitialized) return;
    
    if (_currentQuestionNumber < _questionList.length - 1) {
      _currentQuestionNumber++;
    } else {
      // Last question - mark as complete
      markOnboardingCompleted();
      return;
    }
    notifyListeners();
  }
  
  // Navigate to previous question
  void prevQuestion() {
    if (_currentQuestionNumber > 0) {
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