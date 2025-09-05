import 'package:flutter/services.dart';
import 'dart:convert';
import '../../core/onboarding_workflow/models/questions/question_list.dart';

/// Service for loading onboarding question configuration from JSON assets
class QuestionConfigurationService {
  
  /// Load questions from the initial JSON configuration file
  static Future<QuestionList> loadInitialQuestions() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'lib/core/onboarding_workflow/config/initial_questions.json'
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      return QuestionList.fromJson(jsonData);
    } catch (e) {
      // If asset loading fails, return empty list
      return QuestionList.empty();
    }
  }
}