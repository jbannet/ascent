import 'package:flutter/services.dart';
import 'dart:convert';
import '../../onboarding_workflow/models/questions/question_list.dart';
import '../local_storage/local_storage_service.dart';

/// Service for loading onboarding question configuration from JSON assets
class QuestionConfigurationService {
  
  /// Load questions from the initial JSON configuration file
  static Future<QuestionList> loadInitialQuestions() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'lib/onboarding_workflow/config/initial_questions.json'
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      return QuestionList.fromJson(jsonData);
    } catch (e) {
      // If asset loading fails, return empty list
      return QuestionList.empty();
    }
  }
  
  /// Get the version from the JSON configuration
  static Future<String> getConfigurationVersion() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'lib/onboarding_workflow/config/initial_questions.json'
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      return jsonData['version'] as String? ?? '1.0';
    } catch (e) {
      return '1.0';
    }
  }
  
  /// Initialize questions from assets if not already stored locally
  static Future<void> initializeQuestionsIfNeeded() async {
    try {
      // Check if questions already exist in local storage
      final existingQuestions = await LocalStorageService.loadQuestions();
      
      // If no questions exist locally, load from assets and save
      if (!existingQuestions.isInitialized) {
        // Load JSON directly from assets and save to Hive
        final String jsonString = await rootBundle.loadString(
          'lib/onboarding_workflow/config/initial_questions.json'
        );
        
        final dynamic decoded = json.decode(jsonString);
        final Map<String, dynamic> jsonData = Map<String, dynamic>.from(decoded as Map);
        
        await LocalStorageService.saveQuestions(jsonData);
      }
    } catch (e) {
      // Re-throw to see the actual error during development
      rethrow;
    }
  }
}