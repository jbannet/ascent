import 'dart:math';

import 'package:ascent/constants_and_enums/constants_features.dart';
import 'package:ascent/constants_and_enums/category_enum.dart';

import '../../services_and_utilities/local_storage/local_storage_service.dart';

// Import all fitness profile extensions
import 'fitness_profile_extraction_extensions/age_bracket.dart';
import 'fitness_profile_extraction_extensions/strength.dart';
import 'fitness_profile_extraction_extensions/balance.dart';
import 'fitness_profile_extraction_extensions/functional.dart';
import 'fitness_profile_extraction_extensions/injuries.dart';
import 'fitness_profile_extraction_extensions/low_impact.dart';
import 'fitness_profile_extraction_extensions/flexibility.dart';
import 'fitness_profile_extraction_extensions/cardio.dart';
import 'fitness_profile_extraction_extensions/sleep.dart';
import 'fitness_profile_extraction_extensions/nutrition.dart';
import 'fitness_profile_extraction_extensions/weight_management.dart';
import 'fitness_profile_extraction_extensions/session_commitment.dart';
import 'fitness_profile_extraction_extensions/sedentary_lifestyle.dart';
import 'fitness_profile_extraction_extensions/relative_objective_importance.dart';
import 'fitness_profile_extraction_extensions/osteoporosis.dart';
import 'fitness_profile_extraction_extensions/recommendations.dart';

/// Evaluates onboarding answers to create a fitness profile with ML features.
/// 
/// This class takes raw answers from the onboarding flow, stores them,
/// and uses the FitnessFeatureCalculator to transform them into ML features.
/// The result is a feature vector that can be used with the ML system.
class FitnessProfile {
  final Map<String, double> _features = {};
  final Map<String, dynamic> _answers;
  Map<String, int>? injuriesMap;
  List<String>? recommendationsList;

  int get microWorkoutsPerWeek =>
      _features[FeatureConstants.microSessionsPerWeek]?.toInt() ?? 0;
  int get fullWorkoutsPerWeek =>
      _features[FeatureConstants.fullSessionsPerWeek]?.toInt() ?? 0;

  Map<String, dynamic> get answers => _answers;
  Map<String, double> get featuresMap => _features;
  get features => Map<String, double>.unmodifiable(_features);     

  
  //MARK: Factories
  FitnessProfile(List<String> featureOrder, Map<String, dynamic> answers) : _answers = answers {
    //build features in correct order
    for (final feature in featureOrder) {
      _features[feature] = 0.0;
    }

    // Calculate features from provided answers
    calculateAllFeatures();
  }

  /// Factory method to create a FitnessProfile from survey answers
  /// Calculates all features from the provided answers
  factory FitnessProfile.createFitnessProfileFromSurvey(
    List<String> featureOrder,
    Map<String, dynamic> answers
  ) {
    final profile = FitnessProfile._internal(featureOrder, answers);
    profile.calculateAllFeatures();
    return profile;
  }

  /// Factory method to create a FitnessProfile from storage
  /// Loads features from storage instead of calculating them
  factory FitnessProfile.createFitnessProfileFromStorage(
    List<String> featureOrder,
    Map<String, dynamic> answers
  ) {
    final profile = FitnessProfile._internal(featureOrder, answers);
    // Use FitnessProfile.loadFromStorage(featureOrder) to retrieve persisted data
    return profile;
  }

  /// Internal constructor for factory methods
  FitnessProfile._internal(List<String> featureOrder, Map<String, dynamic> answers) : _answers = answers {
    //build features in correct order
    for (final feature in featureOrder) {
      _features[feature] = 0.0;
    }
  }

  //Load features from local storage (Hive) into the features Map<String, double>
  Map<String, dynamic> toJson() => {
    'answers': _answers,
    'features': _features,
  };

  factory FitnessProfile.fromJson(List<String> featureOrder, Map<String, dynamic> json) {
    final answers = Map<String, dynamic>.from(json['answers'] as Map? ?? {});
    final profile = FitnessProfile._internal(featureOrder, answers);

    final featuresJson = json['features'];
    if (featuresJson is Map) {
      for (final entry in featuresJson.entries) {
        final value = (entry.value as num?)?.toDouble();
        if (value != null && profile._features.containsKey(entry.key)) {
          profile._features[entry.key] = value;
        }
      }
    }

    return profile;
  }

  Future<void> saveToStorage() async {
    await LocalStorageService.saveFitnessProfile(toJson());
  }

  static Future<FitnessProfile?> loadFromStorage(List<String> featureOrder) async {
    final Map<String, dynamic>? json = await LocalStorageService.loadFitnessProfile();
    if (json == null) {
      return null;
    }

    return FitnessProfile.fromJson(featureOrder, json);
  }

  //MARK: get functions
  /// Get category allocations as percentages for display
  Map<Category, double> get categoryAllocationsAsPercentages {
    return {
      Category.cardio: (featuresMap[FeatureConstants.categoryCardio] ?? 0.0) * 100,
      Category.strength: (featuresMap[FeatureConstants.categoryStrength] ?? 0.0) * 100,
      Category.balance: (featuresMap[FeatureConstants.categoryBalance] ?? 0.0) * 100,
      Category.flexibility: (featuresMap[FeatureConstants.categoryStretching] ?? 0.0) * 100,
      Category.functional: (featuresMap[FeatureConstants.categoryFunctional] ?? 0.0) * 100,
    };
  }

  Category selectRandomCategory(Map<Category, double> weights) {
    if (weights.isEmpty) {
      throw ArgumentError('weights cannot be empty');
    }

    final double totalWeight = weights.values.reduce((a, b) => a + b);
    if (totalWeight <= 0) {
      throw ArgumentError('weights must sum to more than zero');
    }

    final random = Random();
    double randomValue = random.nextDouble() * totalWeight;

    double cumulativeWeight = 0.0;
    for (final entry in weights.entries) {
      cumulativeWeight += entry.value;
      if (randomValue <= cumulativeWeight) {
        return entry.key;
      }
    }

    return weights.keys.first;
  }


  //MARK: FUNCTIONS
  /// Calculate all features using extension methods
  void calculateAllFeatures() {
    // Age bracket features
    calculateAgeBracket();

    // Core metrics for each exercise modality (NOT importance)
    calculateStrength();
    calculateBalance();
    calculateFunctional();
    calculateInjuries();
    calculateLowImpact();
    calculateStretching();
    calculateCardio();
    calculateSleep();
    calculateNutrition();
    calculateWeightManagement();
    calculateSessionCommitment();
    calculateSedentaryLifestyle();
    calculateOsteoporosisRisk();

    // Calculate relative importance across all modalities (MUST be last)
    calculateRelativeImportance();
  }
}
