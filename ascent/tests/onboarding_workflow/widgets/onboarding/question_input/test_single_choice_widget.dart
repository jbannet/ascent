import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ascent/workflows/onboarding_workflow/widgets/onboarding/question_input/single_choice_widget.dart';
import 'package:ascent/workflows/onboarding_workflow/models/questions/question_option.dart';
import 'test_helpers.dart';

void main() {
  group('SingleChoiceWidget', () {
    late MockCallback mockCallback;
    late List<QuestionOption> testOptions;

    setUp(() {
      mockCallback = TestHelpers.createMockCallback();
      testOptions = TestHelpers.createSingleChoiceOptions();
    });

    testWidgets('should create widget with required parameters', (WidgetTester tester) async {
      final widget = SingleChoiceWidget(
        questionId: 'test_question',
        title: 'Test Question',
        options: testOptions,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      expect(find.text('Option 1'), findsOneWidget);
      expect(find.text('Option 2'), findsOneWidget);
      expect(find.text('Option 3'), findsOneWidget);
    });

    testWidgets('should display subtitle when provided', (WidgetTester tester) async {
      final widget = SingleChoiceWidget(
        questionId: 'test_question',
        title: 'Test Question',
        subtitle: 'Test subtitle',
        options: testOptions,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      expect(find.text('Test subtitle'), findsOneWidget);
    });

    testWidgets('should not show required indicator when not required', (WidgetTester tester) async {
      final widget = SingleChoiceWidget(
        questionId: 'test_question',
        title: 'Test Question',
        options: testOptions,
        isRequired: false,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      expect(TestHelpers.findRequiredIndicator(), findsNothing);
    });

    testWidgets('should show selected value', (WidgetTester tester) async {
      final widget = SingleChoiceWidget(
        questionId: 'test_question',
        title: 'Test Question',
        options: testOptions,
        selectedValue: 'value1',
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      // Find the container with selected styling
      final selectedOption = find.byWidgetPredicate((widget) =>
          widget is Container &&
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).border != null);
      expect(selectedOption, findsAtLeast(1));
    });

    testWidgets('should display option descriptions', (WidgetTester tester) async {
      final widget = SingleChoiceWidget(
        questionId: 'test_question',
        title: 'Test Question',
        options: testOptions,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      expect(find.text('First option description'), findsOneWidget);
      expect(find.text('Second option description'), findsOneWidget);
      // Option 3 has no description, so it shouldn't appear
    });

    testWidgets('should call onAnswerChanged when option is selected', (WidgetTester tester) async {
      final widget = SingleChoiceWidget(
        questionId: 'test_question',
        title: 'Test Question',
        options: testOptions,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      // Tap on the first option
      await tester.tap(find.text('Option 1'));
      await tester.pump();

      expect(mockCallback.callCount, equals(1));
      expect(mockCallback.wasCalledWith('test_question', 'value1'), isTrue);
    });

    testWidgets('should update selection when different option is tapped', (WidgetTester tester) async {
      final widget = SingleChoiceWidget(
        questionId: 'test_question',
        title: 'Test Question',
        options: testOptions,
        selectedValue: 'value1',
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      // Tap on the second option
      await tester.tap(find.text('Option 2'));
      await tester.pump();

      expect(mockCallback.callCount, equals(1));
      expect(mockCallback.wasCalledWith('test_question', 'value2'), isTrue);
    });

    testWidgets('should update when selectedValue changes', (WidgetTester tester) async {
      var selectedValue = 'value1';
      
      Widget buildWidget() => SingleChoiceWidget(
        questionId: 'test_question',
        title: 'Test Question',
        options: testOptions,
        selectedValue: selectedValue,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, buildWidget());

      // Change selected value and rebuild
      selectedValue = 'value2';
      await TestHelpers.pumpAndSettle(tester, buildWidget());

      // The widget should reflect the new selection
      // We can verify this by checking if the callback would be called with the new value
      await tester.tap(find.text('Option 2'));
      await tester.pump();

      expect(mockCallback.wasCalledWith('test_question', 'value2'), isTrue);
    });

    testWidgets('should show radio button indicators', (WidgetTester tester) async {
      final widget = SingleChoiceWidget(
        questionId: 'test_question',
        title: 'Test Question',
        options: testOptions,
        selectedValue: 'value1',
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      // Should have check icon for selected option
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('should handle tap on entire option container', (WidgetTester tester) async {
      final widget = SingleChoiceWidget(
        questionId: 'test_question',
        title: 'Test Question',
        options: testOptions,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      // Tap on the option description instead of the label
      await tester.tap(find.text('First option description'));
      await tester.pump();

      expect(mockCallback.callCount, equals(1));
      expect(mockCallback.wasCalledWith('test_question', 'value1'), isTrue);
    });

    group('fromConfig constructor', () {
      test('should create widget from valid config', () {
        final config = TestHelpers.createBasicConfig(
          questionId: 'test_question',
          title: 'Test Question',
          onAnswerChanged: mockCallback.call,
        );
        config['options'] = testOptions;

        final widget = SingleChoiceWidget.fromConfig(config);

        expect(widget.questionId, equals('test_question'));
        expect(widget.title, equals('Test Question'));
        expect(widget.options, equals(testOptions));
        expect(widget.isRequired, isTrue);
      });

      test('should create widget with optional parameters', () {
        final config = TestHelpers.createBasicConfig(
          questionId: 'test_question',
          title: 'Test Question',
          subtitle: 'Test subtitle',
          onAnswerChanged: mockCallback.call,
          isRequired: false,
        );
        config['options'] = testOptions;
        config['selectedValue'] = 'value1';

        final widget = SingleChoiceWidget.fromConfig(config);

        expect(widget.subtitle, equals('Test subtitle'));
        expect(widget.selectedValue, equals('value1'));
        expect(widget.isRequired, isFalse);
      });

      test('should throw ArgumentError for missing questionId', () {
        final config = {
          'title': 'Test Question',
          'options': testOptions,
          'onAnswerChanged': mockCallback.call,
        };

        expect(
          () => SingleChoiceWidget.fromConfig(config),
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
          'options': testOptions,
          'onAnswerChanged': mockCallback.call,
        };

        expect(
          () => SingleChoiceWidget.fromConfig(config),
          throwsA(isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('title is required'),
          )),
        );
      });

      test('should throw ArgumentError for missing options', () {
        final config = {
          'questionId': 'test_question',
          'title': 'Test Question',
          'onAnswerChanged': mockCallback.call,
        };

        expect(
          () => SingleChoiceWidget.fromConfig(config),
          throwsA(isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('options is required'),
          )),
        );
      });

      test('should throw ArgumentError for missing onAnswerChanged', () {
        final config = {
          'questionId': 'test_question',
          'title': 'Test Question',
          'options': testOptions,
        };

        expect(
          () => SingleChoiceWidget.fromConfig(config),
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