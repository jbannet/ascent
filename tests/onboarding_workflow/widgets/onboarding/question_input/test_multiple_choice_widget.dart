import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ascent/onboarding_workflow/widgets/onboarding/question_input/multiple_choice_widget.dart';
import 'test_helpers.dart';

void main() {
  group('MultipleChoiceWidget', () {
    late MockMultipleChoiceCallback mockCallback;
    late List<MultipleChoiceOption> testOptions;

    setUp(() {
      mockCallback = MockMultipleChoiceCallback();
      testOptions = TestHelpers.createMultipleChoiceOptions();
    });

    testWidgets('should create widget with required parameters', (WidgetTester tester) async {
      final widget = MultipleChoiceWidget(
        questionId: 'test_question',
        title: 'Test Question',
        options: testOptions,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      expect(find.text('Test Question'), findsOneWidget);
      expect(find.text('Select all that apply'), findsOneWidget);
      expect(TestHelpers.findRequiredIndicator(), findsOneWidget);
      expect(find.text('Option 1'), findsOneWidget);
      expect(find.text('Option 2'), findsOneWidget);
      expect(find.text('Option 3'), findsOneWidget);
    });

    testWidgets('should display subtitle when provided', (WidgetTester tester) async {
      final widget = MultipleChoiceWidget(
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
      final widget = MultipleChoiceWidget(
        questionId: 'test_question',
        title: 'Test Question',
        options: testOptions,
        isRequired: false,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      expect(TestHelpers.findRequiredIndicator(), findsNothing);
    });

    testWidgets('should show selected values', (WidgetTester tester) async {
      final widget = MultipleChoiceWidget(
        questionId: 'test_question',
        title: 'Test Question',
        options: testOptions,
        selectedValues: ['value1', 'value2'],
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      // Should have check icons for selected options
      expect(find.byIcon(Icons.check), findsNWidgets(2));
    });

    testWidgets('should display option descriptions', (WidgetTester tester) async {
      final widget = MultipleChoiceWidget(
        questionId: 'test_question',
        title: 'Test Question',
        options: testOptions,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      expect(find.text('First option description'), findsOneWidget);
      expect(find.text('Second option description'), findsOneWidget);
      // Option 3 has no description
    });

    testWidgets('should call onAnswerChanged when option is selected', (WidgetTester tester) async {
      final widget = MultipleChoiceWidget(
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
      expect(mockCallback.wasCalledWith('test_question', ['value1']), isTrue);
    });

    testWidgets('should allow multiple selections', (WidgetTester tester) async {
      final widget = MultipleChoiceWidget(
        questionId: 'test_question',
        title: 'Test Question',
        options: testOptions,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      // Tap on the first option
      await tester.tap(find.text('Option 1'));
      await tester.pump();

      // Tap on the second option
      await tester.tap(find.text('Option 2'));
      await tester.pump();

      expect(mockCallback.callCount, equals(2));
      expect(mockCallback.wasCalledWith('test_question', ['value1', 'value2']), isTrue);
    });

    testWidgets('should deselect option when tapped again', (WidgetTester tester) async {
      final widget = MultipleChoiceWidget(
        questionId: 'test_question',
        title: 'Test Question',
        options: testOptions,
        selectedValues: ['value1'],
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      // Tap on the first option to deselect it
      await tester.tap(find.text('Option 1'));
      await tester.pump();

      expect(mockCallback.callCount, equals(1));
      expect(mockCallback.wasCalledWith('test_question', <String>[]), isTrue);
    });

    testWidgets('should show max selections limit', (WidgetTester tester) async {
      final widget = MultipleChoiceWidget(
        questionId: 'test_question',
        title: 'Test Question',
        options: testOptions,
        maxSelections: 2,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      expect(find.text('Select up to 2 options'), findsOneWidget);
      expect(find.text('0/2 selected'), findsOneWidget);
    });

    testWidgets('should show min selections requirement', (WidgetTester tester) async {
      final widget = MultipleChoiceWidget(
        questionId: 'test_question',
        title: 'Test Question',
        options: testOptions,
        minSelections: 2,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      expect(find.text('Select at least 2 options'), findsOneWidget);
    });

    testWidgets('should show range when both min and max are set', (WidgetTester tester) async {
      final widget = MultipleChoiceWidget(
        questionId: 'test_question',
        title: 'Test Question',
        options: testOptions,
        minSelections: 1,
        maxSelections: 2,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      expect(find.text('Select 1-2 options'), findsOneWidget);
      expect(find.text('0/2 selected'), findsOneWidget);
    });

    testWidgets('should update selection counter', (WidgetTester tester) async {
      final widget = MultipleChoiceWidget(
        questionId: 'test_question',
        title: 'Test Question',
        options: testOptions,
        maxSelections: 3,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      expect(find.text('0/3 selected'), findsOneWidget);

      // Select first option
      await tester.tap(find.text('Option 1'));
      await tester.pump();

      expect(find.text('1/3 selected'), findsOneWidget);
    });

    testWidgets('should prevent selection beyond max limit', (WidgetTester tester) async {
      final widget = MultipleChoiceWidget(
        questionId: 'test_question',
        title: 'Test Question',
        options: testOptions,
        maxSelections: 2,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      // Select first two options
      await tester.tap(find.text('Option 1'));
      await tester.pump();
      await tester.tap(find.text('Option 2'));
      await tester.pump();

      // Try to select third option - should not allow selection
      await tester.tap(find.text('Option 3'));
      await tester.pump();
      await tester.pumpAndSettle(); // Wait for any potential snackbar

      // Should only have 2 selections, not 3
      expect(mockCallback.callCount, equals(2)); // Only 2 calls, not 3
      
      // Verify the third option was not selected by checking call history
      expect(mockCallback.wasCalledWith('test_question', ['value1', 'value2', 'value3']), isFalse);
    });

    testWidgets('should update when selectedValues changes', (WidgetTester tester) async {
      var selectedValues = <String>['value1'];
      
      Widget buildWidget() => MultipleChoiceWidget(
        questionId: 'test_question',
        title: 'Test Question',
        options: testOptions,
        selectedValues: selectedValues,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, buildWidget());

      // Change selected values and rebuild
      selectedValues = ['value1', 'value2'];
      await TestHelpers.pumpAndSettle(tester, buildWidget());

      // Should show 2 check icons now
      expect(find.byIcon(Icons.check), findsNWidgets(2));
    });

    testWidgets('should handle tap on entire option container', (WidgetTester tester) async {
      final widget = MultipleChoiceWidget(
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
      expect(mockCallback.wasCalledWith('test_question', ['value1']), isTrue);
    });

    group('fromConfig constructor', () {
      test('should create widget from valid config', () {
        final config = TestHelpers.createBasicConfig(
          questionId: 'test_question',
          title: 'Test Question',
          onAnswerChanged: mockCallback.call,
        );
        config['options'] = testOptions;

        final widget = MultipleChoiceWidget.fromConfig(config);

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
        config['selectedValues'] = ['value1', 'value2'];
        config['maxSelections'] = 3;
        config['minSelections'] = 1;

        final widget = MultipleChoiceWidget.fromConfig(config);

        expect(widget.subtitle, equals('Test subtitle'));
        expect(widget.selectedValues, equals(['value1', 'value2']));
        expect(widget.maxSelections, equals(3));
        expect(widget.minSelections, equals(1));
        expect(widget.isRequired, isFalse);
      });

      test('should throw ArgumentError for missing questionId', () {
        final config = {
          'title': 'Test Question',
          'options': testOptions,
          'onAnswerChanged': mockCallback.call,
        };

        expect(
          () => MultipleChoiceWidget.fromConfig(config),
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
          () => MultipleChoiceWidget.fromConfig(config),
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
          () => MultipleChoiceWidget.fromConfig(config),
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
          () => MultipleChoiceWidget.fromConfig(config),
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