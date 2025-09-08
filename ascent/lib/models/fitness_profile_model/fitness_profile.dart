import '../../services/local_storage/local_storage_service.dart';

// Import all fitness profile extensions
import 'fitness_profile_extraction_extensions/age_bracket.dart';
import 'fitness_profile_extraction_extensions/strength.dart';
import 'fitness_profile_extraction_extensions/balance.dart';
import 'fitness_profile_extraction_extensions/functional.dart';
import 'fitness_profile_extraction_extensions/low_impact.dart';
import 'fitness_profile_extraction_extensions/stretching.dart';
import 'fitness_profile_extraction_extensions/cardio.dart';
import 'fitness_profile_extraction_extensions/weight_management.dart';
import 'fitness_profile_extraction_extensions/relative_objective_importance.dart';

/// Evaluates onboarding answers to create a fitness profile with ML features.
/// 
/// This class takes raw answers from the onboarding flow, stores them,
/// and uses the FitnessFeatureCalculator to transform them into ML features.
/// The result is a feature vector that can be used with the ML system.
class FitnessProfile {
  final Map<String, double> _features = {};
  final Map<String, dynamic> _answers;
  
  FitnessProfile(List<String> featureOrder, Map<String, dynamic> answers) : _answers = answers {
    //build features in correct order
    for (final feature in featureOrder) {
      _features[feature] = 0.0;
    }
    
    loadFeaturesFromStorage();
    
    // Calculate features from provided answers
    _calculateAllFeatures();
  }

  get features => Map<String, double>.unmodifiable(_features);
  
  // Getters for extensions to access private members
  Map<String, dynamic> get answers => _answers;
  Map<String, double> get featuresMap => _features;

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


  /// Calculate all features using extension methods
  void _calculateAllFeatures() {
    // Age bracket features
    calculateAgeBracket();
    
    // Core metrics for each exercise modality (NOT importance)
    calculateStrength();
    calculateBalance();
    calculateFunctional();
    calculateLowImpact();
    calculateStretching();
    calculateCardio();
    calculateWeightManagement();
    
    // Calculate relative importance across all modalities (MUST be last)
    calculateRelativeImportance();
  }
}