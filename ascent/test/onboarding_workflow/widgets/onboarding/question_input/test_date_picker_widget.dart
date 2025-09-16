import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ascent/workflow_views/onboarding_workflow/widgets/onboarding/question_input/date_picker_widget.dart';
import 'test_helpers.dart';

void main() {
  group('DatePickerWidget', () {
    late MockDateCallback mockCallback;

    setUp(() {
      mockCallback = MockDateCallback();
    });

    testWidgets('should create widget with required parameters', (WidgetTester tester) async {
      final widget = DatePickerWidget(
        questionId: 'test_question',
        title: 'Test Question',
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      expect(find.text('Select a date'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today_outlined), findsOneWidget);
    });

    testWidgets('should display subtitle when provided', (WidgetTester tester) async {
      final widget = DatePickerWidget(
        questionId: 'test_question',
        title: 'Test Question',
        subtitle: 'Test subtitle',
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      expect(find.text('Test subtitle'), findsOneWidget);
    });

    testWidgets('should not show required indicator when not required', (WidgetTester tester) async {
      final widget = DatePickerWidget(
        questionId: 'test_question',
        title: 'Test Question',
        isRequired: false,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      expect(TestHelpers.findRequiredIndicator(), findsNothing);
    });

    testWidgets('should show current value when provided', (WidgetTester tester) async {
      final testDate = DateTime(2024, 1, 15);
      final widget = DatePickerWidget(
        questionId: 'test_question',
        title: 'Test Question',
        currentValue: testDate,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      expect(find.text('January 15, 2024'), findsAtLeast(1));
      expect(find.text('Selected Date'), findsOneWidget);
    });

    testWidgets('should display custom placeholder when provided', (WidgetTester tester) async {
      final widget = DatePickerWidget(
        questionId: 'test_question',
        title: 'Test Question',
        placeholder: 'Pick your date',
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      expect(find.text('Pick your date'), findsOneWidget);
    });

    testWidgets('should show date range info when min/max dates provided', (WidgetTester tester) async {
      final minDate = DateTime(2023, 1, 1);
      final maxDate = DateTime(2025, 12, 31);
      
      final widget = DatePickerWidget(
        questionId: 'test_question',
        title: 'Test Question',
        minDate: minDate,
        maxDate: maxDate,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      expect(find.textContaining('Between January 1, 2023 and December 31, 2025'), findsOneWidget);
    });

    testWidgets('should show only after date when only min date provided', (WidgetTester tester) async {
      final minDate = DateTime(2023, 6, 15);
      
      final widget = DatePickerWidget(
        questionId: 'test_question',
        title: 'Test Question',
        minDate: minDate,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      expect(find.textContaining('After June 15, 2023'), findsOneWidget);
    });

    testWidgets('should show only before date when only max date provided', (WidgetTester tester) async {
      final maxDate = DateTime(2025, 8, 20);
      
      final widget = DatePickerWidget(
        questionId: 'test_question',
        title: 'Test Question',
        maxDate: maxDate,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      expect(find.textContaining('Before August 20, 2025'), findsOneWidget);
    });

    testWidgets('should show clear button when not required and date selected', (WidgetTester tester) async {
      final testDate = DateTime(2024, 1, 15);
      final widget = DatePickerWidget(
        questionId: 'test_question',
        title: 'Test Question',
        currentValue: testDate,
        isRequired: false,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('should not show clear button when required', (WidgetTester tester) async {
      final testDate = DateTime(2024, 1, 15);
      final widget = DatePickerWidget(
        questionId: 'test_question',
        title: 'Test Question',
        currentValue: testDate,
        isRequired: true,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      expect(find.byIcon(Icons.clear), findsNothing);
    });

    testWidgets('should show quick options when max date allows future dates', (WidgetTester tester) async {
      final maxDate = DateTime.now().add(const Duration(days: 365));
      
      final widget = DatePickerWidget(
        questionId: 'test_question',
        title: 'Test Question',
        maxDate: maxDate,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      expect(find.text('Quick Options'), findsOneWidget);
      expect(find.text('1 month'), findsOneWidget);
    });

    testWidgets('should call onAnswerChanged when date is selected via quick option', (WidgetTester tester) async {
      final maxDate = DateTime.now().add(const Duration(days: 365));
      
      final widget = DatePickerWidget(
        questionId: 'test_question',
        title: 'Test Question',
        maxDate: maxDate,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      // Tap on 1 month quick option
      await tester.tap(find.text('1 month'));
      await tester.pump();

      expect(mockCallback.callCount, equals(1));
      expect(mockCallback.lastCall?.questionId, equals('test_question'));
      expect(mockCallback.lastCall?.value, isA<DateTime>());
    });

    testWidgets('should show days from now for future dates', (WidgetTester tester) async {
      final futureDate = DateTime.now().add(const Duration(days: 30));
      final widget = DatePickerWidget(
        questionId: 'test_question',
        title: 'Test Question',
        currentValue: futureDate,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      expect(find.textContaining('days from now'), findsOneWidget);
    });

    testWidgets('should update when currentValue changes', (WidgetTester tester) async {
      var currentValue = DateTime(2024, 1, 15);
      
      Widget buildWidget() => DatePickerWidget(
        questionId: 'test_question',
        title: 'Test Question',
        currentValue: currentValue,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, buildWidget());
      expect(find.text('January 15, 2024'), findsAtLeast(1));

      // Change current value and rebuild
      currentValue = DateTime(2024, 6, 10);
      await TestHelpers.pumpAndSettle(tester, buildWidget());
      expect(find.text('June 10, 2024'), findsAtLeast(1));
    });

    // Note: Testing actual date picker dialog would require more complex integration testing
    // as it involves system dialogs. The core functionality is tested above.

    group('fromConfig constructor', () {
      test('should create widget from valid config', () {
        final config = TestHelpers.createBasicConfig(
          questionId: 'test_question',
          title: 'Test Question',
          onAnswerChanged: mockCallback.call,
        );

        final widget = DatePickerWidget.fromConfig(config);

        expect(widget.questionId, equals('test_question'));
        expect(widget.title, equals('Test Question'));
        expect(widget.isRequired, isTrue);
        expect(widget.initialDatePickerMode, equals(DatePickerMode.day));
      });

      test('should create widget with optional parameters', () {
        final testDate = DateTime(2024, 1, 15);
        final minDate = DateTime(2023, 1, 1);
        final maxDate = DateTime(2025, 12, 31);
        
        final config = TestHelpers.createBasicConfig(
          questionId: 'test_question',
          title: 'Test Question',
          subtitle: 'Test subtitle',
          onAnswerChanged: mockCallback.call,
          isRequired: false,
          currentValue: testDate,
        );
        config['minDate'] = minDate;
        config['maxDate'] = maxDate;
        config['placeholder'] = 'Pick a date';
        config['initialDatePickerMode'] = 'year';

        final widget = DatePickerWidget.fromConfig(config);

        expect(widget.subtitle, equals('Test subtitle'));
        expect(widget.currentValue, equals(testDate));
        expect(widget.minDate, equals(minDate));
        expect(widget.maxDate, equals(maxDate));
        expect(widget.placeholder, equals('Pick a date'));
        expect(widget.initialDatePickerMode, equals(DatePickerMode.year));
        expect(widget.isRequired, isFalse);
      });

      test('should parse date picker modes correctly', () {
        final testCases = {
          'day': DatePickerMode.day,
          'year': DatePickerMode.year,
          'unknown': DatePickerMode.day,
          null: DatePickerMode.day,
        };

        for (final entry in testCases.entries) {
          final config = TestHelpers.createBasicConfig(
            questionId: 'test_question',
            title: 'Test Question',
            onAnswerChanged: mockCallback.call,
          );
          if (entry.key != null) {
            config['initialDatePickerMode'] = entry.key;
          }

          final widget = DatePickerWidget.fromConfig(config);
          expect(widget.initialDatePickerMode, equals(entry.value));
        }
      });

      test('should throw ArgumentError for missing questionId', () {
        final config = {
          'title': 'Test Question',
          'onAnswerChanged': mockCallback.call,
        };

        expect(
          () => DatePickerWidget.fromConfig(config),
          throwsA(isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('questionId is required'),
          )),
        );
      });

      test('should throw ArgumentError for missing title', () {
        final config = {
          'questionId': 'test_question',
          'onAnswerChanged': mockCallback.call,
        };

        expect(
          () => DatePickerWidget.fromConfig(config),
          throwsA(isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('title is required'),
          )),
        );
      });

      test('should throw ArgumentError for missing onAnswerChanged', () {
        final config = {
          'questionId': 'test_question',
          'title': 'Test Question',
        };

        expect(
          () => DatePickerWidget.fromConfig(config),
          throwsA(isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('onAnswerChanged is required'),
          )),
        );
      });
    });
  });
}