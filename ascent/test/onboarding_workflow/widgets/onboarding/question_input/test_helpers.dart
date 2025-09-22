import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ascent/workflow_views/onboarding_workflow/models/questions/question_option.dart';

/// Test helpers for question input widgets
class TestHelpers {
  /// Creates a MaterialApp wrapper for testing widgets
  static Widget createTestApp({required Widget child}) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: child,
        ),
      ),
    );
  }

  /// Creates a mock callback function for testing
  static MockCallback createMockCallback() {
    return MockCallback();
  }

  /// Creates sample single choice options for testing
  static List<QuestionOption> createSingleChoiceOptions() {
    return [
      QuestionOption(
        label: 'Option 1',
        description: 'First option description',
        value: 'value1',
      ),
      QuestionOption(
        label: 'Option 2',
        description: 'Second option description',
        value: 'value2',
      ),
      QuestionOption(
        label: 'Option 3',
        value: 'value3',
      ),
    ];
  }

  /// Creates sample multiple choice options for testing
  static List<QuestionOption> createMultipleChoiceOptions() {
    return [
      QuestionOption(
        label: 'Option 1',
        description: 'First option description',
        value: 'value1',
      ),
      QuestionOption(
        label: 'Option 2',
        description: 'Second option description',
        value: 'value2',
      ),
      QuestionOption(
        label: 'Option 3',
        value: 'value3',
      ),
    ];
  }


  /// Pumps and settles a widget for testing
  static Future<void> pumpAndSettle(WidgetTester tester, Widget widget) async {
    await tester.pumpWidget(createTestApp(child: widget));
    await tester.pumpAndSettle();
  }

  /// Finds a text field by its placeholder text
  static Finder findTextFieldByPlaceholder(String placeholder) {
    return find.widgetWithText(TextFormField, placeholder);
  }

  /// Verifies that an error message is displayed
  static void expectErrorText(String errorText) {
    expect(find.text(errorText), findsOneWidget);
  }

  /// Verifies that no error is displayed
  static void expectNoError() {
    expect(find.textContaining('required'), findsNothing);
    expect(find.textContaining('Must be'), findsNothing);
  }

  /// Finds required indicator text
  static Finder findRequiredIndicator() {
    return find.text('* Required');
  }

  /// Creates a basic test configuration map
  static Map<String, dynamic> createBasicConfig({
    required String questionId,
    required String title,
    required Function onAnswerChanged,
    String? subtitle,
    bool isRequired = true,
    dynamic currentValue,
  }) {
    return {
      'questionId': questionId,
      'title': title,
      'subtitle': subtitle,
      'onAnswerChanged': onAnswerChanged,
      'currentValue': currentValue,
      'isRequired': isRequired,
    };
  }
}

/// Mock callback class for testing
class MockCallback {
  final List<CallRecord> calls = [];

  void call(String questionId, dynamic value) {
    calls.add(CallRecord(questionId, value));
  }

  /// Returns the last call made to this callback
  CallRecord? get lastCall => calls.isEmpty ? null : calls.last;

  /// Returns the number of times this callback was called
  int get callCount => calls.length;

  /// Clears all recorded calls
  void reset() {
    calls.clear();
  }

  /// Verifies that the callback was called with specific parameters
  bool wasCalledWith(String questionId, dynamic value) {
    return calls.any((call) => call.questionId == questionId && call.value == value);
  }
}

/// Mock callback class for multiple choice widgets that return List of String
class MockMultipleChoiceCallback {
  final List<MultipleChoiceCallRecord> calls = [];

  void call(String questionId, List<String> values) {
    calls.add(MultipleChoiceCallRecord(questionId, values));
  }

  /// Returns the last call made to this callback
  MultipleChoiceCallRecord? get lastCall => calls.isEmpty ? null : calls.last;

  /// Returns the number of times this callback was called
  int get callCount => calls.length;

  /// Clears all recorded calls
  void reset() {
    calls.clear();
  }

  /// Verifies that the callback was called with specific parameters
  bool wasCalledWith(String questionId, List<String> values) {
    return calls.any((call) => 
        call.questionId == questionId && 
        call.values.length == values.length &&
        call.values.every((value) => values.contains(value)));
  }
}

/// Mock callback class for number/slider widgets that return double
class MockNumericCallback {
  final List<NumericCallRecord> calls = [];

  void call(String questionId, double value) {
    calls.add(NumericCallRecord(questionId, value));
  }

  /// Returns the last call made to this callback
  NumericCallRecord? get lastCall => calls.isEmpty ? null : calls.last;

  /// Returns the number of times this callback was called
  int get callCount => calls.length;

  /// Clears all recorded calls
  void reset() {
    calls.clear();
  }

  /// Verifies that the callback was called with specific parameters
  bool wasCalledWith(String questionId, double value) {
    return calls.any((call) => call.questionId == questionId && call.value == value);
  }
}

/// Mock callback class for date picker widgets that return DateTime
class MockDateCallback {
  final List<DateCallRecord> calls = [];

  void call(String questionId, DateTime value) {
    calls.add(DateCallRecord(questionId, value));
  }

  /// Returns the last call made to this callback
  DateCallRecord? get lastCall => calls.isEmpty ? null : calls.last;

  /// Returns the number of times this callback was called
  int get callCount => calls.length;

  /// Clears all recorded calls
  void reset() {
    calls.clear();
  }

  /// Verifies that the callback was called with specific parameters
  bool wasCalledWith(String questionId, DateTime value) {
    return calls.any((call) => call.questionId == questionId && call.value == value);
  }
}

/// Record of a callback call
class CallRecord {
  final String questionId;
  final dynamic value;

  CallRecord(this.questionId, this.value);

  @override
  String toString() => 'CallRecord(questionId: $questionId, value: $value)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CallRecord &&
          runtimeType == other.runtimeType &&
          questionId == other.questionId &&
          value == other.value;

  @override
  int get hashCode => questionId.hashCode ^ value.hashCode;
}

/// Record of a multiple choice callback call
class MultipleChoiceCallRecord {
  final String questionId;
  final List<String> values;

  MultipleChoiceCallRecord(this.questionId, this.values);

  @override
  String toString() => 'MultipleChoiceCallRecord(questionId: $questionId, values: $values)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MultipleChoiceCallRecord &&
          runtimeType == other.runtimeType &&
          questionId == other.questionId &&
          values.length == other.values.length &&
          values.every((value) => other.values.contains(value));

  @override
  int get hashCode => questionId.hashCode ^ values.hashCode;
}

/// Record of a numeric callback call
class NumericCallRecord {
  final String questionId;
  final double value;

  NumericCallRecord(this.questionId, this.value);

  @override
  String toString() => 'NumericCallRecord(questionId: $questionId, value: $value)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NumericCallRecord &&
          runtimeType == other.runtimeType &&
          questionId == other.questionId &&
          value == other.value;

  @override
  int get hashCode => questionId.hashCode ^ value.hashCode;
}

/// Record of a date callback call
class DateCallRecord {
  final String questionId;
  final DateTime value;

  DateCallRecord(this.questionId, this.value);

  @override
  String toString() => 'DateCallRecord(questionId: $questionId, value: $value)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DateCallRecord &&
          runtimeType == other.runtimeType &&
          questionId == other.questionId &&
          value == other.value;

  @override
  int get hashCode => questionId.hashCode ^ value.hashCode;
}

