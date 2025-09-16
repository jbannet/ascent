import '../onboarding_question.dart';
import 'sugary_treats_question.dart';
import 'sodas_question.dart';
import 'grains_question.dart';
import 'alcohol_question.dart';

/// Integration helper for the nutrition onboarding questions.
/// 
/// This provides a centralized way to access all 4 nutrition questions
/// and integrate them into the existing onboarding flow. The questions
/// should be presented sequentially to build the progressive chart visualization.
class NutritionQuestionsIntegration {
  
  /// All nutrition questions in the correct order for onboarding flow
  static List<OnboardingQuestion> get nutritionQuestions => [
    SugaryTreatsQuestion.instance,
    SodasQuestion.instance, 
    GrainsQuestion.instance,
    AlcoholQuestion.instance,
  ];
  
  /// Question IDs in order
  static const List<String> questionIds = [
    SugaryTreatsQuestion.questionId,
    SodasQuestion.questionId,
    GrainsQuestion.questionId,
    AlcoholQuestion.questionId,
  ];
  
  /// Get nutrition question by ID
  static OnboardingQuestion? getQuestionById(String id) {
    switch (id) {
      case SugaryTreatsQuestion.questionId:
        return SugaryTreatsQuestion.instance;
      case SodasQuestion.questionId:
        return SodasQuestion.instance;
      case GrainsQuestion.questionId:
        return GrainsQuestion.instance;
      case AlcoholQuestion.questionId:
        return AlcoholQuestion.instance;
      default:
        return null;
    }
  }
  
  /// Check if a question ID belongs to the nutrition flow
  static bool isNutritionQuestion(String id) {
    return questionIds.contains(id);
  }
  
  /// Get the next nutrition question ID in sequence, or null if at end
  static String? getNextQuestionId(String currentId) {
    final currentIndex = questionIds.indexOf(currentId);
    if (currentIndex == -1 || currentIndex >= questionIds.length - 1) {
      return null; // Not found or last question
    }
    return questionIds[currentIndex + 1];
  }
  
  /// Get the previous nutrition question ID in sequence, or null if at start
  static String? getPreviousQuestionId(String currentId) {
    final currentIndex = questionIds.indexOf(currentId);
    if (currentIndex <= 0) {
      return null; // Not found or first question
    }
    return questionIds[currentIndex - 1];
  }
  
  /// Check if all nutrition questions have been answered
  static bool areAllQuestionsCompleted(Map<String, dynamic> answers) {
    return questionIds.every((id) {
      final question = getQuestionById(id);
      if (question == null) return false;
      
      final answer = answers[id];
      // Special handling for alcohol privacy option
      if (id == AlcoholQuestion.questionId) {
        return answer != null; // Allow 'prefer_not_to_say' as valid
      }
      return question.hasAnswer;
    });
  }
  
  /// Get completion progress (0.0 to 1.0)
  static double getCompletionProgress(Map<String, dynamic> answers) {
    int completedCount = 0;
    
    for (final id in questionIds) {
      final question = getQuestionById(id);
      if (question != null) {
        final answer = answers[id];
        // Special handling for alcohol privacy option
        if (id == AlcoholQuestion.questionId) {
          if (answer != null) completedCount++;
        } else if (question.hasAnswer) {
          completedCount++;
        }
      }
    }
    
    return completedCount / questionIds.length;
  }
  
  /// Get all nutrition data in a structured format
  static Map<String, dynamic> getNutritionProfile(Map<String, dynamic> answers) {
    return {
      'sugary_treats': SugaryTreatsQuestion.instance.getSugaryTreatsCount(answers),
      'sodas': SodasQuestion.instance.getSodasCount(answers),
      'grains': GrainsQuestion.instance.getGrainsCount(answers),
      'alcohol': AlcoholQuestion.instance.getAlcoholCount(answers),
      'alcohol_private': AlcoholQuestion.instance.isPrivateAnswer(answers),
      'completion_progress': getCompletionProgress(answers),
      'is_complete': areAllQuestionsCompleted(answers),
    };
  }
  
  /// Validate all nutrition answers
  static Map<String, String> validateNutritionAnswers(Map<String, dynamic> answers) {
    final errors = <String, String>{};
    
    for (final id in questionIds) {
      final question = getQuestionById(id);
      if (question != null) {
        final answer = answers[id];
        if (!question.hasAnswer) {
          // Don't treat missing alcohol answer as error if privacy is expected
          if (id == AlcoholQuestion.questionId && answer == null) {
            continue; // Allow missing alcohol answer
          }
          errors[id] = 'Invalid answer for ${question.questionText}';
        }
      }
    }
    
    return errors;
  }
}

/// Extension methods for easier integration with existing onboarding
extension NutritionAnswersExtension on Map<String, dynamic> {
  
  /// Get the nutrition profile from this answers map
  Map<String, dynamic> get nutritionProfile => 
    NutritionQuestionsIntegration.getNutritionProfile(this);
  
  /// Check if nutrition questions are complete
  bool get isNutritionComplete => 
    NutritionQuestionsIntegration.areAllQuestionsCompleted(this);
  
  /// Get nutrition completion progress
  double get nutritionProgress => 
    NutritionQuestionsIntegration.getCompletionProgress(this);
}