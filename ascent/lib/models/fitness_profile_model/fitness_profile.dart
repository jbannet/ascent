import 'package:ascent/constants_and_enums/constants_features.dart';
import 'package:ascent/constants_and_enums/category_enum.dart';

import '../../services_and_utilities/local_storage/local_storage_service.dart';

// Import all fitness profile extensions
import 'fitness_profile_extraction_extensions/age_bracket.dart';
import 'fitness_profile_extraction_extensions/strength.dart';
import 'fitness_profile_extraction_extensions/balance.dart';
import 'fitness_profile_extraction_extensions/low_impact.dart';
import 'fitness_profile_extraction_extensions/flexibility.dart';
import 'fitness_profile_extraction_extensions/cardio.dart';
import 'fitness_profile_extraction_extensions/weight_management.dart';
import 'fitness_profile_extraction_extensions/session_commitment.dart';
import 'fitness_profile_extraction_extensions/relative_objective_importance.dart';

/// Evaluates onboarding answers to create a fitness profile with ML features.
/// 
/// This class takes raw answers from the onboarding flow, stores them,
/// and uses the FitnessFeatureCalculator to transform them into ML features.
/// The result is a feature vector that can be used with the ML system.
class FitnessProfile {
  final Map<String, double> _features = {};
  final Map<String, dynamic> _answers;

  get microWorkoutsPerWeek => _features['microSessionsPerWeek']?.toInt() ?? 0;
  get fullWorkoutsPerWeek => _features['fullSessionsPerWeek']?.toInt() ?? 0;
  
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
    // Features will be loaded from storage when loadFeaturesFromStorage() is called
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
  Future<void> loadFeaturesFromStorage() async {    
    final Map<String, double>? loadedFeatures = await LocalStorageService.loadFitnessProfileFeatures();
    
    if (loadedFeatures != null && loadedFeatures.isNotEmpty) {
      //Load features from storage into the _features map, keeping the same key order
      for (final entry in loadedFeatures.entries) {
        if (_features.containsKey(entry.key)) { //only load known features
          _features[entry.key] = entry.value;
        }
      }
    }
  }

  //Use local_storage (Hive) to save the features Map<String, double>
  Future<void> saveFeaturesToStorage() async {
    await LocalStorageService.saveFitnessProfileFeatures(_features);
  }


  /// Get category allocations as percentages for display
  Map<Category, double> getCategoryAllocationsAsPercentages() {
    return {
      Category.cardio: (featuresMap[FeatureConstants.categoryCardio] ?? 0.0) * 100,
      Category.strength: (featuresMap[FeatureConstants.categoryStrength] ?? 0.0) * 100,
      Category.balance: (featuresMap[FeatureConstants.categoryBalance] ?? 0.0) * 100,
      Category.flexibility: (featuresMap[FeatureConstants.categoryStretching] ?? 0.0) * 100,
      Category.functional: (featuresMap[FeatureConstants.categoryFunctional] ?? 0.0) * 100,
    };
  }


  /// Calculate all features using extension methods
  void calculateAllFeatures() {
    // Age bracket features
    calculateAgeBracket();

    // Core metrics for each exercise modality (NOT importance)
    calculateStrength();
    calculateBalance();
    // calculateFunctional(); // Removed - using question-based allocation instead
    calculateLowImpact();
    calculateStretching();
    calculateCardio();
    calculateWeightManagement();
    calculateSessionCommitment();

    // Calculate relative importance across all modalities (MUST be last)
    calculateRelativeImportance();
  }
}