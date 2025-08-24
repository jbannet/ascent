import 'dart:convert';
import '../models/questions/question_configuration.dart';
import '../models/answers/onboarding_answers.dart';
import '../models/state/app_state.dart';

class JsonParser {
  // Convert object to JSON string
  static String toJson(dynamic object) {
    if (object == null) {
      return '{}';
    }
    
    Map<String, dynamic> jsonMap;
    
    if (object is QuestionConfiguration) {
      jsonMap = object.toJson();
    } else if (object is OnboardingAnswers) {
      jsonMap = object.toJson();
    } else if (object is AppState) {
      jsonMap = object.toJson();
    } else if (object is Map<String, dynamic>) {
      jsonMap = object;
    } else {
      throw ArgumentError('Unsupported object type for JSON conversion');
    }
    
    return jsonEncode(jsonMap);
  }

  // Parse JSON string to Map
  static Map<String, dynamic> fromJson(String jsonString) {
    if (jsonString.isEmpty) {
      return {};
    }
    
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      } else {
        throw FormatException('JSON is not a Map<String, dynamic>');
      }
    } catch (e) {
      throw FormatException('Invalid JSON string: $e');
    }
  }

  // Parse questions from JSON map
  static QuestionConfiguration parseQuestions(Map<String, dynamic> json) {
    try {
      return QuestionConfiguration.fromJson(json);
    } catch (e) {
      throw FormatException('Failed to parse questions: $e');
    }
  }

  // Parse answers from JSON map
  static OnboardingAnswers parseAnswers(Map<String, dynamic> json) {
    try {
      return OnboardingAnswers.fromJson(json);
    } catch (e) {
      throw FormatException('Failed to parse answers: $e');
    }
  }

  // Parse app state from JSON map
  static AppState parseAppState(Map<String, dynamic> json) {
    try {
      return AppState.fromJson(json);
    } catch (e) {
      throw FormatException('Failed to parse app state: $e');
    }
  }

  // Validate question configuration JSON structure
  static bool validateQuestionConfig(Map<String, dynamic> json) {
    try {
      // Check required top-level fields
      if (!json.containsKey('version') || !json.containsKey('sections')) {
        return false;
      }

      // Check version is string
      if (json['version'] is! String) {
        return false;
      }

      // Check sections is list
      if (json['sections'] is! List) {
        return false;
      }

      final sections = json['sections'] as List;
      if (sections.isEmpty) {
        return false;
      }

      // Validate each section
      for (final section in sections) {
        if (section is! Map<String, dynamic>) {
          return false;
        }
        
        if (!section.containsKey('section_id') ||
            !section.containsKey('title') ||
            !section.containsKey('reason') ||
            !section.containsKey('questions')) {
          return false;
        }

        final questions = section['questions'];
        if (questions is! List || questions.isEmpty) {
          return false;
        }

        // Validate each question
        for (final question in questions) {
          if (question is! Map<String, dynamic>) {
            return false;
          }
          
          if (!question.containsKey('id') ||
              !question.containsKey('question') ||
              !question.containsKey('type')) {
            return false;
          }
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // Validate answer JSON structure
  static bool validateAnswers(Map<String, dynamic> json) {
    try {
      // Check required fields
      if (!json.containsKey('onboarding_version') ||
          !json.containsKey('completed') ||
          !json.containsKey('started_at') ||
          !json.containsKey('answers')) {
        return false;
      }

      // Check types
      if (json['onboarding_version'] is! String ||
          json['completed'] is! bool ||
          json['started_at'] is! String ||
          json['answers'] is! Map) {
        return false;
      }

      // Try to parse date
      DateTime.parse(json['started_at'] as String);
      
      if (json['completed_at'] != null) {
        DateTime.parse(json['completed_at'] as String);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // Safe parsing with error handling
  static T? safeParse<T>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) parser,
  ) {
    try {
      return parser(json);
    } catch (e) {
      print('Error parsing JSON: $e');
      return null;
    }
  }

  // Extract specific fields from JSON
  static dynamic getField(Map<String, dynamic> json, String path) {
    final keys = path.split('.');
    dynamic current = json;
    
    for (final key in keys) {
      if (current is Map<String, dynamic>) {
        if (!current.containsKey(key)) {
          return null;
        }
        current = current[key];
      } else {
        return null;
      }
    }
    
    return current;
  }

  // Merge two JSON maps
  static Map<String, dynamic> mergeJson(
    Map<String, dynamic> base,
    Map<String, dynamic> updates,
  ) {
    final result = Map<String, dynamic>.from(base);
    
    updates.forEach((key, value) {
      if (value is Map<String, dynamic> && 
          result[key] is Map<String, dynamic>) {
        // Recursively merge nested maps
        result[key] = mergeJson(
          result[key] as Map<String, dynamic>,
          value,
        );
      } else {
        // Replace value
        result[key] = value;
      }
    });
    
    return result;
  }

  // Clean null values from JSON
  static Map<String, dynamic> removeNulls(Map<String, dynamic> json) {
    final cleaned = <String, dynamic>{};
    
    json.forEach((key, value) {
      if (value != null) {
        if (value is Map<String, dynamic>) {
          cleaned[key] = removeNulls(value);
        } else {
          cleaned[key] = value;
        }
      }
    });
    
    return cleaned;
  }
}