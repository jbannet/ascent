import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../../onboarding_workflow/widgets/onboarding/question_input/dual_column_selector_widget.dart';
import '../onboarding_question.dart';

/// Session commitment question that captures both full and micro session availability.
/// 
/// This single question replaces 4 previous questions about workout frequency/duration
/// by capturing commitment to two distinct session types:
/// - Full sessions: 30-60 minute traditional workouts
/// - Micro sessions: 7-15 minute fitness snacks
/// 
/// The dual-column UI allows users to specify days per week for each type,
/// recognizing that modern fitness patterns include both approaches.
class SessionCommitmentQuestion extends OnboardingQuestion {
  static const String questionId = 'session_commitment';
  static final SessionCommitmentQuestion instance = SessionCommitmentQuestion._();
  SessionCommitmentQuestion._();
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => SessionCommitmentQuestion.questionId;
  
  @override
  String get questionText => 'How many days can you commit?';
  
  @override
  String get section => 'schedule';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.dualColumnSelector;
  
  @override
  String? get subtitle => 'Select days per week for each session type';
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
    'leftColumn': {
      'label': 'Full Sessions',
      'description': '30-60 minutes',
      'maxValue': 7,
      'minValue': 0,
    },
    'rightColumn': {
      'label': 'Micro Sessions', 
      'description': '7-15 minutes',
      'maxValue': 7,
      'minValue': 0,
    },
  };
  
  //MARK: VALIDATION
  
  @override
  bool isValidAnswer(dynamic answer) {
    if (answer is! Map<String, dynamic>) return false;
    
    final fullSessions = answer['full_sessions'];
    final microSessions = answer['micro_sessions'];
    
    // At least one type of session should be selected
    if (fullSessions == null || microSessions == null) return false;
    if (fullSessions is! int || microSessions is! int) return false;
    
    // Valid range check
    if (fullSessions < 0 || fullSessions > 7) return false;
    if (microSessions < 0 || microSessions > 7) return false;
    
    // User should commit to at least some exercise
    return (fullSessions + microSessions) > 0;
  }
  
  @override
  dynamic getDefaultAnswer() => {
    'full_sessions': 3,  // Default to 3 full sessions per week
    'micro_sessions': 2, // And 2 micro sessions
  };
  
  @override
  void fromJsonValue(dynamic json) {
    if (json is Map<String, dynamic>) {
      _sessionCommitment = json;
    } else if (json is String) {
      try {
        _sessionCommitment = jsonDecode(json) as Map<String, dynamic>;
      } catch (_) {
        _sessionCommitment = null;
      }
    } else {
      _sessionCommitment = null;
    }
  }
  
  //MARK: TYPED ACCESSORS
  
  /// Get number of full session days per week
  int getFullSessionDays(Map<String, dynamic> answers) {
    final commitment = answers[questionId];
    if (commitment == null || commitment is! Map<String, dynamic>) return 3;
    return commitment['full_sessions'] ?? 3;
  }
  
  /// Get number of micro session days per week  
  int getMicroSessionDays(Map<String, dynamic> answers) {
    final commitment = answers[questionId];
    if (commitment == null || commitment is! Map<String, dynamic>) return 0;
    return commitment['micro_sessions'] ?? 0;
  }
  
  /// Get total training days per week (max of full + micro, not sum)
  /// Since user might do both types on same day
  int getTotalTrainingDays(Map<String, dynamic> answers) {
    final full = getFullSessionDays(answers);
    final micro = getMicroSessionDays(answers);
    // Assume some overlap - use weighted calculation
    // If both are selected, likely some days have both
    if (full > 0 && micro > 0) {
      return (full + (micro * 0.5)).round().clamp(full, 7);
    }
    return (full + micro).clamp(0, 7);
  }
  
  /// Get approximate total weekly training time in minutes
  int getWeeklyTrainingMinutes(Map<String, dynamic> answers) {
    final full = getFullSessionDays(answers);
    final micro = getMicroSessionDays(answers);
    
    // Full sessions average 45 minutes
    // Micro sessions average 10 minutes
    return (full * 45) + (micro * 10);
  }

  //MARK: ANSWER STORAGE
  
  Map<String, dynamic>? _sessionCommitment;
  
  @override
  String? get answer => _sessionCommitment != null ? jsonEncode(_sessionCommitment) : null;
  
  /// Set the session commitment with a typed Map<String, dynamic>
  void setSessionCommitment(Map<String, dynamic>? value) => _sessionCommitment = value;
  
  /// Get the session commitment as a typed Map<String, dynamic>
  Map<String, dynamic>? get sessionCommitment => _sessionCommitment;

  @override
  Widget buildAnswerWidget(
    Function() onAnswerChanged,
  ) {
    return DualColumnSelectorWidget(
      config: config,
      onChanged: (value) {
        setSessionCommitment(value as Map<String, dynamic>?);
        onAnswerChanged();
      },
      initialValue: _sessionCommitment,
    );
  }
}