import '../../onboarding_workflow/models/answers/onboarding_answers.dart';
import '../../../services/local_storage/local_storage_service.dart';

// Import all fitness profile extensions
import 'fitness_profile_extensions/age_bracket.dart';
import 'fitness_profile_extensions/strength.dart';
import 'fitness_profile_extensions/balance.dart';
import 'fitness_profile_extensions/low_impact.dart';
import 'fitness_profile_extensions/stretching.dart';
import 'fitness_profile_extensions/cardio.dart';
import 'fitness_profile_extensions/bodyweight.dart';
import 'fitness_profile_extensions/birth_year.dart';

/// Evaluates onboarding answers to create a fitness profile with ML features.
/// 
/// This class takes raw answers from the onboarding flow, stores them,
/// and uses the FitnessFeatureCalculator to transform them into ML features.
/// The result is a feature vector that can be used with the ML system.
class FitnessProfile {
  final Map<String, double> _features = {};
  final Map<String, dynamic> _answers = {};
  
  FitnessProfile(List<String> featureOrder){
    //build features in correct order
    for (final feature in featureOrder) {
      _features[feature] = 0.0;
    }
    
    loadFeaturesFromStorage();
  }

  get features => Map<String, double>.unmodifiable(_features);
  
  // Getters for extensions to access private members
  Map<String, dynamic> get answers => _answers;
  Map<String, double> get featuresMap => _features;

  //Load features from local storage (Hive) into the features Map<String, double>
  Future<void> loadFeaturesFromStorage() async {    
    final Map<String, double>? loadedFeatures = await LocalStorageService.loadFitnessProfileFeatures();
    final Map<String, double>? loadedAnswers = await LocalStorageService.loadFitnessProfileDemographics();
    
    if (loadedFeatures != null && loadedFeatures.isNotEmpty) {
      //Load features from storage into the _features map, keeping the same key order
      for (final entry in loadedFeatures.entries) {
        if (_features.containsKey(entry.key)) { //only load known features
          _features[entry.key] = entry.value;
        }
      }
    }
    
    if (loadedAnswers != null && loadedAnswers.isNotEmpty) {
      //Load raw answers from storage
      _answers.addAll(loadedAnswers);
    }
  }

  //Use local_storage (Hive) to save the features Map<String, double>
  Future<void> saveFeaturesToStorage() async {
    await LocalStorageService.saveFitnessProfileFeatures(_features);
  }

  Future<void> saveAnswersToStorage() async {
    // Convert dynamic answers to double values where possible
    final Map<String, double> numericAnswers = {};
    for (final entry in _answers.entries) {
      if (entry.value is num) {
        numericAnswers[entry.key] = (entry.value as num).toDouble();
      }
    }
    await LocalStorageService.saveFitnessProfileDemographics(numericAnswers);
  }

  /// Function called once during onboarding completion
  /// Store raw answers and calculate features using extension methods
  void initializeProfileFromQuestions(OnboardingAnswers onboardingAnswers) {
    // Store raw answers directly (no need to loop through questions)
    _answers.addAll(onboardingAnswers.answers);
    
    // Calculate all features using extension methods
    // Age bracket features
    calculateAgeBracket();
    
    // Exercise category features
    calculateStrength();
    calculateBalance();
    calculateLowImpact();
    calculateStretching();
    calculateCardio();
    calculateBodyweight();
    
    // Profile values
    calculateBirthYear();
  }
}