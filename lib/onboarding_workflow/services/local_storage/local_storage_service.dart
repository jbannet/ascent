import 'package:hive_flutter/hive_flutter.dart';
import '../../models/questions/question_list.dart';
import '../../models/answers/onboarding_answers.dart';
import '../../../constants.dart';

/// Service for managing local storage of onboarding data using Hive database
class LocalStorageService {
  
  /// Load questions from questionBox
  static Future<QuestionList> loadQuestions() async {
    final Box questionBox = await Hive.openBox(AppConstants.questionBoxName);
    final Map<String, dynamic>? questionsData = questionBox.get(AppConstants.questionsStorageKey);
    
    if (questionsData == null) {
      return QuestionList.empty();
    }
    
    return QuestionList.fromJson(questionsData);
  }
  
  /// Save questions to questionBox
  static Future<void> saveQuestions(QuestionList pQuestionList) async {
    final Box questionBox = await Hive.openBox(AppConstants.questionBoxName);
    await questionBox.put(AppConstants.questionsStorageKey, pQuestionList.toJson());
  }

  /// Get question version from questionBox
  static Future<int> getQuestionVersion() async {
    final Box questionBox = await Hive.openBox(AppConstants.questionBoxName);
    final Map<String, dynamic>? questionsData = questionBox.get(AppConstants.questionsStorageKey);
    
    if (questionsData == null) {
      return 0;
    }
    
    return questionsData['version'] as int? ?? 0;
  }

  /// Save question version to questionBox
  static Future<void> saveQuestionVersion(int pVersion) async {
    final Box questionBox = await Hive.openBox(AppConstants.questionBoxName);
    await questionBox.put('version', pVersion);
  }
  
  /// Load answers from answerBox
  static Future<OnboardingAnswers> loadAnswers() async {
    final Box answerBox = await Hive.openBox(AppConstants.answerBoxName);
    final Map<String, dynamic>? answersData = answerBox.get(AppConstants.answersStorageKey);
    
    if (answersData == null) {
      return OnboardingAnswers.empty();
    }
    
    return OnboardingAnswers.fromJson(answersData);
  }
  
  /// Save answers to answerBox
  static Future<void> saveAnswers(OnboardingAnswers pAnswers) async {
    final Box answerBox = await Hive.openBox(AppConstants.answerBoxName);
    await answerBox.put(AppConstants.answersStorageKey, pAnswers.toJson());
  }
}