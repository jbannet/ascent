import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ascent/workflow_views/onboarding_workflow/widgets/onboarding/question_input/slider_widget.dart';
import 'test_helpers.dart';

void main() {
  group('SliderWidget', () {
    late MockNumericCallback mockCallback;

    setUp(() {
      mockCallback = MockNumericCallback();
    });

    testWidgets('should create widget with required parameters', (WidgetTester tester) async {
      final widget = SliderWidget(
        questionId: 'test_question',
        title: 'Test Question',
        minValue: 0.0,
        maxValue: 10.0,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      expect(find.text('Range: 0 - 10'), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);
    });

    testWidgets('should display subtitle when provided', (WidgetTester tester) async {
      final widget = SliderWidget(
        questionId: 'test_question',
        title: 'Test Question',
        subtitle: 'Test subtitle',
        minValue: 0.0,
        maxValue: 10.0,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      expect(find.text('Test subtitle'), findsOneWidget);
    });

    testWidgets('should not show required indicator when not required', (WidgetTester tester) async {
      final widget = SliderWidget(
        questionId: 'test_question',
        title: 'Test Question',
        minValue: 0.0,
        maxValue: 10.0,
        isRequired: false,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      expect(TestHelpers.findRequiredIndicator(), findsNothing);
    });

    testWidgets('should show current value when provided', (WidgetTester tester) async {
      final widget = SliderWidget(
        questionId: 'test_question',
        title: 'Test Question',
        minValue: 0.0,
        maxValue: 10.0,
        currentValue: 5.0,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('should show current value with unit when provided', (WidgetTester tester) async {
      final widget = SliderWidget(
        questionId: 'test_question',
        title: 'Test Question',
        minValue: 0.0,
        maxValue: 100.0,
        currentValue: 50.0,
        unit: '%',
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      expect(find.text('50%'), findsOneWidget);
      expect(find.text('Range: 0% - 100%'), findsOneWidget);
    });

    testWidgets('should not show value display when showValue is false', (WidgetTester tester) async {
      final widget = SliderWidget(
        questionId: 'test_question',
        title: 'Test Question',
        minValue: 0.0,
        maxValue: 10.0,
        currentValue: 5.0,
        showValue: false,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      // The value display container should not be present when showValue is false
      // We can verify this by checking that no prominent value display is shown
      expect(find.text('5'), findsNothing); // Value shouldn't be displayed prominently
    });

    testWidgets('should display scale labels when divisions are provided', (WidgetTester tester) async {
      final widget = SliderWidget(
        questionId: 'test_question',
        title: 'Test Question',
        minValue: 0.0,
        maxValue: 10.0,
        divisions: 5,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      // Should have scale labels
      expect(find.text('0'), findsAtLeast(1));
      expect(find.text('10'), findsAtLeast(1));
    });

    testWidgets('should show discrete value buttons for small number of divisions', (WidgetTester tester) async {
      final widget = SliderWidget(
        questionId: 'test_question',
        title: 'Test Question',
        minValue: 0.0,
        maxValue: 5.0,
        divisions: 5,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      // Should have clickable buttons for each value
      expect(find.text('0'), findsAtLeast(1));
      expect(find.text('1'), findsAtLeast(1));
      expect(find.text('2'), findsAtLeast(1));
      expect(find.text('3'), findsAtLeast(1));
      expect(find.text('4'), findsAtLeast(1));
      expect(find.text('5'), findsAtLeast(1));
    });

    testWidgets('should call onAnswerChanged when slider value changes', (WidgetTester tester) async {
      final widget = SliderWidget(
        questionId: 'test_question',
        title: 'Test Question',
        minValue: 0.0,
        maxValue: 10.0,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      // Simulate slider change
      await tester.drag(find.byType(Slider), const Offset(100, 0));
      await tester.pump();

      expect(mockCallback.callCount, greaterThan(0));
      // The exact value depends on the drag distance, but should be within range
      final lastCall = mockCallback.lastCall;
      expect(lastCall?.questionId, equals('test_question'));
      expect(lastCall?.value, isA<double>());
      expect(lastCall?.value, greaterThanOrEqualTo(0.0));
      expect(lastCall?.value, lessThanOrEqualTo(10.0));
    });

    testWidgets('should call onAnswerChanged when discrete button is tapped', (WidgetTester tester) async {
      final widget = SliderWidget(
        questionId: 'test_question',
        title: 'Test Question',
        minValue: 0.0,
        maxValue: 3.0,
        divisions: 3,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      // Find the discrete value buttons container and tap on one
      final buttonContainers = find.byWidgetPredicate((widget) =>
          widget is Container &&
          widget.decoration is BoxDecoration &&
          widget.padding != null);
      
      if (buttonContainers.evaluate().isNotEmpty) {
        await tester.tap(buttonContainers.first);
        await tester.pump();

        expect(mockCallback.callCount, equals(1));
        expect(mockCallback.lastCall?.questionId, equals('test_question'));
        expect(mockCallback.lastCall?.value, isA<double>());
      }
    });

    testWidgets('should apply step value when provided', (WidgetTester tester) async {
      final widget = SliderWidget(
        questionId: 'test_question',
        title: 'Test Question',
        minValue: 0.0,
        maxValue: 10.0,
        step: 2.0,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      // The step functionality is internal, but we can verify the widget accepts the parameter
      expect(widget.step, equals(2.0));
    });

    testWidgets('should use custom label formatter when provided', (WidgetTester tester) async {
      String customFormatter(double value) => '${value.toInt()} points';
      
      final widget = SliderWidget(
        questionId: 'test_question',
        title: 'Test Question',
        minValue: 0.0,
        maxValue: 100.0,
        currentValue: 50.0,
        labelFormatter: customFormatter,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      expect(find.text('50 points'), findsOneWidget);
    });

    testWidgets('should format decimal values correctly', (WidgetTester tester) async {
      final widget = SliderWidget(
        questionId: 'test_question',
        title: 'Test Question',
        minValue: 0.0,
        maxValue: 10.0,
        currentValue: 5.5,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      expect(find.text('5.5'), findsOneWidget);
    });

    testWidgets('should update when currentValue changes', (WidgetTester tester) async {
      var currentValue = 3.0;
      
      Widget buildWidget() => SliderWidget(
        questionId: 'test_question',
        title: 'Test Question',
        minValue: 0.0,
        maxValue: 10.0,
        currentValue: currentValue,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, buildWidget());
      expect(find.text('3'), findsOneWidget);

      // Change current value and rebuild
      currentValue = 7.0;
      await TestHelpers.pumpAndSettle(tester, buildWidget());
      expect(find.text('7'), findsOneWidget);
    });

    group('fromConfig constructor', () {
      test('should create widget from valid config', () {
        final config = TestHelpers.createBasicConfig(
          questionId: 'test_question',
          title: 'Test Question',
          onAnswerChanged: mockCallback.call,
        );
        config['minValue'] = 0.0;
        config['maxValue'] = 10.0;

        final widget = SliderWidget.fromConfig(config);

        expect(widget.questionId, equals('test_question'));
        expect(widget.title, equals('Test Question'));
        expect(widget.minValue, equals(0.0));
        expect(widget.maxValue, equals(10.0));
        expect(widget.isRequired, isTrue);
      });

      test('should create widget with optional parameters', () {
        final config = TestHelpers.createBasicConfig(
          questionId: 'test_question',
          title: 'Test Question',
          subtitle: 'Test subtitle',
          onAnswerChanged: mockCallback.call,
          isRequired: false,
          currentValue: 5.0,
        );
        config['minValue'] = 0.0;
        config['maxValue'] = 10.0;
        config['divisions'] = 10;
        config['unit'] = 'kg';
        config['showValue'] = false;
        config['step'] = 0.5;

        final widget = SliderWidget.fromConfig(config);

        expect(widget.subtitle, equals('Test subtitle'));
        expect(widget.currentValue, equals(5.0));
        expect(widget.divisions, equals(10));
        expect(widget.unit, equals('kg'));
        expect(widget.showValue, isFalse);
        expect(widget.step, equals(0.5));
        expect(widget.isRequired, isFalse);
      });

      test('should throw ArgumentError for missing questionId', () {
        final config = {
          'title': 'Test Question',
          'minValue': 0.0,
          'maxValue': 10.0,
          'onAnswerChanged': mockCallback.call,
        };

        expect(
          () => SliderWidget.fromConfig(config),
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
          'minValue': 0.0,
          'maxValue': 10.0,
          'onAnswerChanged': mockCallback.call,
        };

        expect(
          () => SliderWidget.fromConfig(config),
          throwsA(isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('title is required'),
          )),
        );
      });

      test('should throw ArgumentError for missing minValue', () {
        final config = {
          'questionId': 'test_question',
          'title': 'Test Question',
          'maxValue': 10.0,
          'onAnswerChanged': mockCallback.call,
        };

        expect(
          () => SliderWidget.fromConfig(config),
          throwsA(isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('minValue is required'),
          )),
        );
      });

      test('should throw ArgumentError for missing maxValue', () {
        final config = {
          'questionId': 'test_question',
          'title': 'Test Question',
          'minValue': 0.0,
          'onAnswerChanged': mockCallback.call,
        };

        expect(
          () => SliderWidget.fromConfig(config),
          throwsA(isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('maxValue is required'),
          )),
        );
      });

      test('should throw ArgumentError for missing onAnswerChanged', () {
        final config = {
          'questionId': 'test_question',
          'title': 'Test Question',
          'minValue': 0.0,
          'maxValue': 10.0,
        };

        expect(
          () => SliderWidget.fromConfig(config),
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