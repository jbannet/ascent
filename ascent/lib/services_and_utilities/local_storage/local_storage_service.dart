import 'package:hive_flutter/hive_flutter.dart';
import '../../constants_and_enums/constants.dart';

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
  
  
  /// Load answers from answerBox as raw JSON
  static Future<Map<String, dynamic>> loadAnswers() async {
    final Box answerBox = await Hive.openBox(AppConstants.answerBoxName);
    final dynamic rawData = answerBox.get(AppConstants.answersStorageKey);
    
    if (rawData == null) {
      return {};
    }
    
    final Map<String, dynamic> answersData = _castToStringValueMap(rawData) as Map<String, dynamic>;
    // Handle legacy OnboardingAnswers format
    if (answersData.containsKey('answers')) {
      return answersData['answers'] as Map<String, dynamic>;
    }
    return answersData;
  }
  
  /// Save answers to answerBox as raw JSON
  static Future<void> saveAnswers(Map<String, dynamic> answersJson) async {
    final Box answerBox = await Hive.openBox(AppConstants.answerBoxName);
    await answerBox.put(AppConstants.answersStorageKey, answersJson);
  }

  /// Load plan payload from storage
  static Future<Map<String, dynamic>?> loadPlan() async {
    final Box planBox = await Hive.openBox(AppConstants.planBoxName);
    final dynamic rawData = planBox.get(AppConstants.planJsonKey);

    if (rawData == null) {
      return null;
    }

    return _castToStringValueMap(rawData) as Map<String, dynamic>;
  }

  /// Save plan payload to storage
  static Future<void> savePlan(Map<String, dynamic> planJson) async {
    final Box planBox = await Hive.openBox(AppConstants.planBoxName);
    await planBox.put(AppConstants.planJsonKey, planJson);
  }

  /// Remove persisted plan data.
  static Future<void> deletePlan() async {
    final Box planBox = await Hive.openBox(AppConstants.planBoxName);
    await planBox.delete(AppConstants.planJsonKey);
  }

  /// Load fitness profile features from fitnessProfileBox
  static Future<Map<String, dynamic>?> loadFitnessProfile() async {
    final Box fitnessProfileBox = await Hive.openBox(AppConstants.fitnessProfileBoxName);
    final dynamic rawData = fitnessProfileBox.get(AppConstants.fitnessProfileJsonKey);

    if (rawData == null) {
      return null;
    }

    return _castToStringValueMap(rawData) as Map<String, dynamic>;
  }

  /// Save fitness profile payload to fitnessProfileBox
  static Future<void> saveFitnessProfile(Map<String, dynamic> profileJson) async {
    final Box fitnessProfileBox = await Hive.openBox(AppConstants.fitnessProfileBoxName);
    await fitnessProfileBox.put(AppConstants.fitnessProfileJsonKey, profileJson);
  }

  /// Remove persisted fitness profile payload.
  static Future<void> deleteFitnessProfile() async {
    final Box fitnessProfileBox = await Hive.openBox(AppConstants.fitnessProfileBoxName);
    await fitnessProfileBox.delete(AppConstants.fitnessProfileJsonKey);
  }

  /// Load fitness profile features from fitnessProfileBox
  static Future<Map<String, double>?> loadFitnessProfileFeatures() async {
    final Box fitnessProfileBox = await Hive.openBox(AppConstants.fitnessProfileBoxName);
    final dynamic rawData = fitnessProfileBox.get(AppConstants.fitnessProfileFeaturesKey);
    
    if (rawData == null) {
      return null;
    }
    
    final Map<String, dynamic> featuresData = _castToStringValueMap(rawData) as Map<String, dynamic>;
    return featuresData.map((key, value) => MapEntry(key, (value as num).toDouble()));
  }
  
  /// Save fitness profile features to fitnessProfileBox
  static Future<void> saveFitnessProfileFeatures(Map<String, double> pFeatures) async {
    final Box fitnessProfileBox = await Hive.openBox(AppConstants.fitnessProfileBoxName);
    await fitnessProfileBox.put(AppConstants.fitnessProfileFeaturesKey, pFeatures);
  }

  /// Load fitness profile demographics from fitnessProfileBox
  static Future<Map<String, double>?> loadFitnessProfileDemographics() async {
    final Box fitnessProfileBox = await Hive.openBox(AppConstants.fitnessProfileBoxName);
    final dynamic rawData = fitnessProfileBox.get(AppConstants.fitnessProfileDemographicsKey);
    
    if (rawData == null) {
      return null;
    }
    
    final Map<String, dynamic> demographicsData = _castToStringValueMap(rawData) as Map<String, dynamic>;
    return demographicsData.map((key, value) => MapEntry(key, (value as num).toDouble()));
  }
  
  /// Save fitness profile demographics to fitnessProfileBox
  static Future<void> saveFitnessProfileDemographics(Map<String, double> pDemographics) async {
    final Box fitnessProfileBox = await Hive.openBox(AppConstants.fitnessProfileBoxName);
    await fitnessProfileBox.put(AppConstants.fitnessProfileDemographicsKey, pDemographics);
  }

}
