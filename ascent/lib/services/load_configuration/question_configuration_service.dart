import '../../core/onboarding_workflow/models/questions/question_list.dart';
import '../../core/onboarding_question_bank/registry/question_bank.dart';

/// Service for loading onboarding question configuration from QuestionBank
class QuestionConfigurationService {
  
  /// Load questions from the QuestionBank registry
  /// This replaces the previous JSON-based loading system
  static Future<QuestionList> loadInitialQuestions() async {
    try {
      // Load questions from the centralized question bank
      return QuestionBank.getQuestionList();
    } catch (e) {
      // If loading fails, return empty list
      return QuestionList.empty();
    }
  }
}