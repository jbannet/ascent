import 'package:hive_flutter/hive_flutter.dart';
import '../../core/onboarding_workflow/models/answers/onboarding_answers.dart';
import '../../constants.dart';

/// Service for managing local storage of onboarding data using Hive database
class LocalStorageService {
  
  // ignore: unintended_html_in_doc_comment
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