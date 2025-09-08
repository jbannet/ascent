import 'package:flutter/material.dart';
import '../../../models/questions/question.dart';
import '../../../models/questions/enum_question_type.dart';
import 'text_input_widget.dart';
import 'number_input_widget.dart';
import 'single_choice_widget.dart';
import 'multiple_choice_widget.dart';
import 'slider_widget.dart';
import 'date_picker_widget.dart';
import 'body_map_widget.dart';
import 'dual_column_selector_widget.dart';

/// Factory for creating question input widgets based on question type.
/// 
/// This factory builds a configuration map from question data and routes
/// to the appropriate widget's fromConfig constructor for validation and creation.
class FactoryQuestionInputs {
  /// Creates appropriate input widget for the given question type.
  static Widget createWidget({
    required Question question,
    required Map<String, dynamic> currentAnswers,
    required Function(String questionId, dynamic value) onAnswerChanged,
  }) {
    // Build configuration: runtime context + answer input settings from JSON
    final config = <String, dynamic>{
      // Runtime context
      'questionId': question.id,
      'title': question.question,
      'subtitle': question.subtitle,
      'onAnswerChanged': onAnswerChanged,
      'currentValue': currentAnswers[question.id],
      // Spread all answer configuration settings directly from JSON
      ...?question.answerConfigurationSettings,
    };
    
    // Add options directly for choice widgets
    if (question.options != null) {
      config['options'] = question.options;
      
      // Handle multiple selected values for multiple choice widgets
      if (question.type == EnumQuestionType.multipleChoice) {
        final currentValue = currentAnswers[question.id];
        if (currentValue is List) {
          config['selectedValues'] = currentValue.cast<String>();
        } else if (currentValue is String) {
          config['selectedValues'] = [currentValue];
        }
      }
    }
    
    // Route to appropriate widget based on question type
    switch (question.type) {
      case EnumQuestionType.textInput:
        return TextInputWidget.fromConfig(config);
      
      case EnumQuestionType.numberInput:
        return NumberInputWidget.fromConfig(config);
      
      case EnumQuestionType.singleChoice:
        return SingleChoiceWidget.fromConfig(config);
      
      case EnumQuestionType.multipleChoice:
        return MultipleChoiceWidget.fromConfig(config);
      
      case EnumQuestionType.slider:
        return SliderWidget.fromConfig(config);
      
      case EnumQuestionType.datePicker:
        return DatePickerWidget.fromConfig(config);
      
      case EnumQuestionType.bodyMap:
        // Handle body map selections (List<String> with pain_/injury_ prefixes)
        final currentValue = currentAnswers[question.id];
        if (currentValue is List) {
          config['selectedValues'] = currentValue.cast<String>();
        } else if (currentValue is String) {
          config['selectedValues'] = [currentValue];
        }
        return BodyMapWidget.fromConfig(config);
      
      case EnumQuestionType.dualColumnSelector:
        // Handle dual column selections (Map with full_sessions and micro_sessions)
        return DualColumnSelectorWidget(
          config: question.answerConfigurationSettings ?? {},
          onChanged: (value) => onAnswerChanged(question.id, value),
          initialValue: currentAnswers[question.id] as Map<String, dynamic>?,
        );
    }
  }
}