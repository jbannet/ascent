import '../../onboarding_workflow/models/answers/onboarding_answers.dart';
import '../base/feature_contribution.dart';
import '../registry/question_bank.dart';
import '../../brain/matrix_models/person_vector.dart';

/// Evaluates onboarding answers to create a fitness profile with ML features.
/// 
/// This class takes raw answers from the onboarding flow and uses the
/// QuestionBank to evaluate each answer's contribution to fitness features.
/// The result is a feature vector that can be used with the ML system.
class FitnessProfileEvaluator {
  final Map<String, double> features = {};
  final OnboardingAnswers answers;
  
  FitnessProfileEvaluator(this.answers) {
    _evaluateAllAnswers();
  }
  
  /// Process all answers through their respective question evaluators
  void _evaluateAllAnswers() {
    // Build context with demographic information
    final context = _buildEvaluationContext();
    
    // Evaluate each answer through its question
    for (final entry in answers.answers.entries) {
      final questionId = entry.key;
      final answer = entry.value;
      
      // Skip null answers
      if (answer == null) continue;
      
      // Get the question evaluator
      final question = QuestionBank.getQuestion(questionId);
      if (question == null) {
        print('Warning: No evaluator found for question $questionId');
        continue;
      }
      
      // Evaluate the answer
      try {
        final contributions = question.evaluate(answer, context);
        _applyContributions(contributions);
      } catch (e) {
        print('Error evaluating question $questionId: $e');
      }
    }
  }
  
  /// Build context map with demographic and other supporting data
  Map<String, dynamic> _buildEvaluationContext() {
    return {
      'age': answers.getAnswer('age') ?? 35,
      'gender': answers.getAnswer('gender') ?? 'male',
      'height': answers.getAnswer('height'),
      // Add other context as needed
    };
  }
  
  /// Apply feature contributions to the feature map
  void _applyContributions(List<FeatureContribution> contributions) {
    for (final contribution in contributions) {
      switch (contribution.type) {
        case ContributionType.set:
          features[contribution.featureName] = contribution.value;
          break;
          
        case ContributionType.add:
          features[contribution.featureName] = 
            (features[contribution.featureName] ?? 0.0) + contribution.value;
          break;
          
        case ContributionType.multiply:
          features[contribution.featureName] = 
            (features[contribution.featureName] ?? 1.0) * contribution.value;
          break;
      }
    }
  }
  
  /// Convert the evaluated features to a PersonVector for ML use
  PersonVector toPersonVector() {
    // Define feature order (this would normally come from a configuration)
    final featureOrder = features.keys.toList()..sort();
    
    // Create ordered feature map
    final orderedFeatures = <String, double>{};
    for (final featureName in featureOrder) {
      orderedFeatures[featureName] = features[featureName] ?? 0.0;
    }
    
    return PersonVector(orderedFeatures, featureOrder);
  }
  
  /// Get a summary of the fitness profile for display
  Map<String, dynamic> getProfileSummary() {
    return {
      'total_features': features.length,
      'strength_score': _calculateDimensionScore(['upper_body_strength', 'overall_strength']),
      'training_readiness': features['strength_training_readiness'] ?? 0.0,
      'fitness_age_factor': features['strength_fitness_age_factor'] ?? 0.5,
      'all_features': Map.from(features), // Copy for debugging
    };
  }
  
  /// Calculate a composite score for a fitness dimension
  double _calculateDimensionScore(List<String> featureNames) {
    final values = featureNames
        .map((name) => features[name])
        .where((value) => value != null)
        .map((value) => value!)
        .toList();
    
    if (values.isEmpty) return 0.0;
    
    // Average the contributing features
    return values.reduce((a, b) => a + b) / values.length;
  }
}