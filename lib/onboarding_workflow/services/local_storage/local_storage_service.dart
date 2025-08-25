import 'package:hive_flutter/hive_flutter.dart';
import '../../models/questions/question_list.dart';
import '../../models/answers/onboarding_answers.dart';
import '../../../constants.dart';

/// Service for managing local storage of onboarding data using Hive database
class LocalStorageService {
  
  /// Recursively convert Hive's _Map<dynamic, dynamic> to Map<String, dynamic>
  static dynamic _castToStringValueMap(dynamic input) {
    if (input is Map) {
      return Map<String, dynamic>.from(
        input.map((key, value) => MapEntry(key.toString(), _castToStringValueMap(value)))
      );
    } else if (input is List) {
      return input.map((item) => _castToStringValueMap(item)).toList();
    } else {
      return input;
    }
  }
  
  /// Load questions from questionBox
  static Future<QuestionList> loadQuestions() async {
    final Box questionBox = await Hive.openBox(AppConstants.questionBoxName);
    final dynamic rawData = questionBox.get(AppConstants.questionsStorageKey);
    
    if (rawData == null) {
      return QuestionList.empty();
    }
    
    // Recursively convert all nested Maps from Hive format to proper Map<String, dynamic>
    final Map<String, dynamic> questionsData = _castToStringValueMap(rawData) as Map<String, dynamic>;
    return QuestionList.fromJson(questionsData);
  }
  
  /// Save questions to questionBox
  static Future<void> saveQuestions(Map<String, dynamic> questionsJson) async {
    final Box questionBox = await Hive.openBox(AppConstants.questionBoxName);
    await questionBox.put(AppConstants.questionsStorageKey, questionsJson);
  }

  /// Get question version from questionBox
  static Future<double> getQuestionVersion() async {
    final Box questionBox = await Hive.openBox(AppConstants.questionBoxName);
    final dynamic rawData = questionBox.get(AppConstants.questionsStorageKey);
    
    if (rawData == null) {
      return 0.0;
    }
    
    final Map<String, dynamic> questionsData = _castToStringValueMap(rawData) as Map<String, dynamic>;
    final String versionStr = questionsData['version'] as String;
    return double.tryParse(versionStr) ?? 0.0;
  }

  /// Save question version to questionBox
  static Future<void> saveQuestionVersion(double pVersion) async {
    final Box questionBox = await Hive.openBox(AppConstants.questionBoxName);
    await questionBox.put('version', pVersion);
  }
  
  /// Load answers from answerBox
  static Future<OnboardingAnswers> loadAnswers() async {
    final Box answerBox = await Hive.openBox(AppConstants.answerBoxName);
    final dynamic rawData = answerBox.get(AppConstants.answersStorageKey);
    
    if (rawData == null) {
      return OnboardingAnswers.empty();
    }
    
    final Map<String, dynamic> answersData = _castToStringValueMap(rawData) as Map<String, dynamic>;
    return OnboardingAnswers.fromJson(answersData);
  }
  
  /// Save answers to answerBox
  static Future<void> saveAnswers(OnboardingAnswers pAnswers) async {
    final Box answerBox = await Hive.openBox(AppConstants.answerBoxName);
    await answerBox.put(AppConstants.answersStorageKey, pAnswers.toJson());
  }
}