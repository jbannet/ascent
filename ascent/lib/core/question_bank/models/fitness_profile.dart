import '../../onboarding_workflow/models/answers/onboarding_answers.dart';
import '../registry/question_bank.dart';
import '../../../services/local_storage/local_storage_service.dart';

/// Evaluates onboarding answers to create a fitness profile with ML features.
/// 
/// This class takes raw answers from the onboarding flow and uses the
/// QuestionBank to evaluate each answer's contribution to fitness features.
/// The result is a feature vector that can be used with the ML system.
class FitnessProfile {
  final Map<String, double> _features = {};
  final Map<String, double> _profile = {};
  
  FitnessProfile(List<String> featureOrder){
    //build features in correct order
    for (final feature in featureOrder) {
      _features[feature] = 0.0;
    }
    
    loadFeaturesFromStorage();
  }

  get features => Map<String, double>.unmodifiable(_features);

  //Load features from local storage (Hive) into the features Map<String, double>
  Future<void> loadFeaturesFromStorage() async {    
    final Map<String, double>? loadedFeatures = await LocalStorageService.loadFitnessProfileFeatures();
    final Map<String, double>? loadedDemographics = await LocalStorageService.loadFitnessProfileDemographics();
    
    if (loadedFeatures != null && loadedFeatures.isNotEmpty) {
      //Load features from storage into the _features map, keeping the same key order
      for (final entry in loadedFeatures.entries) {
        if (_features.containsKey(entry.key)) { //only load known features
          _features[entry.key] = entry.value;
        }
      }
    }
    
    if (loadedDemographics != null && loadedDemographics.isNotEmpty) {
      //Load demographics from storage
      _profile.addAll(loadedDemographics);
    }
  }

  //Use local_storage (Hive) to save the features Map<String, double>
  Future<void> saveFeaturesToStorage() async {
    await LocalStorageService.saveFitnessProfileFeatures(_features);
  }

  Future<void> saveDemographicsToStorage() async {
    await LocalStorageService.saveFitnessProfileDemographics(_profile);
  }

  /// Function called once during onboarding completion
  /// Process all answers through their respective question evaluators
  void initializeProfileFromQuestions(OnboardingAnswers answers) {
    // Evaluate each answer through its question
    for (final entry in answers.answers.entries) {
      final questionId = entry.key;
      final answer = entry.value;
      
      // Skip null answers
      if (answer == null) continue;
      
      // Get the question evaluator
      final question = QuestionBank.getQuestion(questionId);
      if (question == null) continue;
      
      // Pass features and demographics directly so question can modify them
      //!!!! THIS IS A DESTRUCTIVE OPERATION ON THE MAPS
      question.evaluate(answer, _features, _profile);
    }
  }
}