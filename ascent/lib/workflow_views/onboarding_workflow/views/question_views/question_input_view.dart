import 'package:flutter/material.dart';
import '../../models/questions/question_option.dart';

/// Base interface for all question input view widgets.
/// 
/// This interface provides a consistent pattern for question views:
/// - All views receive the full answers map (not just their specific answer)
/// - Views extract their own answer using answers[questionId] 
/// - Views handle their own type conversion and validation
/// - Views can access other answers if needed (e.g., BodyMapWidget needs gender)
abstract class QuestionInputView extends StatelessWidget {
  /// The unique identifier for this question
  final String questionId;
  
  /// The full map of all answers collected so far
  /// Views extract their specific answer using answers[questionId]
  final Map<String, dynamic> answers;
  
  /// Callback function called when the answer changes
  final Function(String, dynamic) onAnswerChanged;
  
  /// Optional configuration parameters for the view
  /// Used by views that need customization (slider ranges, text limits, etc.)
  final Map<String, dynamic>? config;
  
  /// Options for choice-based questions (single/multiple choice)
  final List<QuestionOption>? options;

  const QuestionInputView({
    super.key,
    required this.questionId,
    required this.answers,
    required this.onAnswerChanged,
    this.config,
    this.options,
  });
  
  /// Helper method to extract this question's current answer
  /// Returns null if no answer exists yet
  dynamic get currentAnswer => answers[questionId];
  
  /// Helper method to safely cast the current answer to a specific type
  /// Returns null if the answer doesn't exist or can't be cast
  T? getCurrentAnswerAs<T>() {
    final answer = currentAnswer;
    if (answer == null) return null;
    
    if (answer is T) return answer;
    
    // Handle common type conversions
    if (T == double && answer is num) {
      return answer.toDouble() as T;
    }
    if (T == int && answer is num) {
      return answer.toInt() as T;
    }
    if (T == String) {
      return answer.toString() as T;
    }
    
    return null;
  }
  
  /// Helper method to safely convert answer to `List<String>`
  /// Used by multiple choice and body map questions
  List<String>? getCurrentAnswerAsList() {
    final answer = currentAnswer;
    if (answer == null) return null;
    
    if (answer is List<String>) return answer;
    if (answer is List) return answer.cast<String>();
    if (answer is String) return [answer];
    
    return null;
  }
}