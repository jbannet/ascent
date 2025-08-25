import 'question.dart';
import '../../../extensions/list_extensions.dart';

/// Primary model for managing the onboarding question flow.
/// 
/// This is the main model that contains all questions in a flat structure.
/// Each question contains its own section information, eliminating the need
/// for nested section/configuration hierarchy.
class QuestionList {
  final String version;
  final List<Question> questions;
  
  //MARK: CONSTRUCTORS
  QuestionList({
    required this.version,
    required this.questions,
  });

  /// Factory to create empty question list
  factory QuestionList.empty() {
    return QuestionList(version: '0.0.0', questions: []);
  }
  
  //MARK: GETTERS
  bool get isInitialized => questions.isNotEmpty;
  int get length => questions.length;
  
  Question? getQuestionAtIndex(int index) {
    return questions.safeGet(index);
  }    
  
  factory QuestionList.fromJson(Map<String, dynamic> json) {
    return QuestionList(
      version: json['version'] as String,
      questions: (json['questions'] as List)
          .map((q) => Question.fromJson(q))
          .toList(),
    );
  }
}