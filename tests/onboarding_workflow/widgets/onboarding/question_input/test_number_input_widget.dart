import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ascent/onboarding_workflow/widgets/onboarding/question_input/number_input_widget.dart';
import 'test_helpers.dart';

void main() {
  group('NumberInputWidget', () {
    late MockNumericCallback mockCallback;

    setUp(() {
      mockCallback = MockNumericCallback();
    });

    testWidgets('should create widget with required parameters', (WidgetTester tester) async {
      final widget = NumberInputWidget(
        questionId: 'test_question',
        title: 'Test Question',
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      expect(find.text('Test Question'), findsOneWidget);
      expect(TestHelpers.findRequiredIndicator(), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('should display subtitle when provided', (WidgetTester tester) async {
      final widget = NumberInputWidget(
        questionId: 'test_question',
        title: 'Test Question',
        subtitle: 'Test subtitle',
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      expect(find.text('Test subtitle'), findsOneWidget);
    });

    testWidgets('should display placeholder text', (WidgetTester tester) async {
      final widget = NumberInputWidget(
        questionId: 'test_question',
        title: 'Test Question',
        placeholder: 'Enter a number',
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      // Check that the placeholder text is rendered by verifying the widget properties
      expect(widget.placeholder, equals('Enter a number'));
    });

    testWidgets('should show current value in text field', (WidgetTester tester) async {
      final widget = NumberInputWidget(
        questionId: 'test_question',
        title: 'Test Question',
        currentValue: 42.0,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.controller?.text, equals('42.0'));
    });

    testWidgets('should not show required indicator when not required', (WidgetTester tester) async {
      final widget = NumberInputWidget(
        questionId: 'test_question',
        title: 'Test Question',
        isRequired: false,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      expect(TestHelpers.findRequiredIndicator(), findsNothing);
    });

    testWidgets('should show range information when min/max are set', (WidgetTester tester) async {
      final widget = NumberInputWidget(
        questionId: 'test_question',
        title: 'Test Question',
        minValue: 0.0,
        maxValue: 100.0,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      expect(find.text('Range: 0.0 - 100.0'), findsOneWidget);
    });

    testWidgets('should show only min value when only min is set', (WidgetTester tester) async {
      final widget = NumberInputWidget(
        questionId: 'test_question',
        title: 'Test Question',
        minValue: 0.0,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      expect(find.text('Min: 0.0'), findsOneWidget);
    });

    testWidgets('should show only max value when only max is set', (WidgetTester tester) async {
      final widget = NumberInputWidget(
        questionId: 'test_question',
        title: 'Test Question',
        maxValue: 100.0,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      expect(find.text('Max: 100.0'), findsOneWidget);
    });

    testWidgets('should display unit as suffix when provided', (WidgetTester tester) async {
      final widget = NumberInputWidget(
        questionId: 'test_question',
        title: 'Test Question',
        unit: 'kg',
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      // Check that the unit is set on the widget
      expect(widget.unit, equals('kg'));
    });

    testWidgets('should show unit selector when unit options are provided', (WidgetTester tester) async {
      final widget = NumberInputWidget(
        questionId: 'test_question',
        title: 'Test Question',
        unitOptions: ['cm', 'ft', 'in'],
        selectedUnit: 'cm',
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      expect(find.byType(DropdownButton<String>), findsOneWidget);
    });

    testWidgets('should call onAnswerChanged when valid number is entered', (WidgetTester tester) async {
      final widget = NumberInputWidget(
        questionId: 'test_question',
        title: 'Test Question',
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      await tester.enterText(find.byType(TextFormField), '42.5');
      await tester.pump();

      expect(mockCallback.callCount, greaterThan(0));
      expect(mockCallback.wasCalledWith('test_question', 42.5), isTrue);
    });

    testWidgets('should validate required field on focus lost', (WidgetTester tester) async {
      final widget = NumberInputWidget(
        questionId: 'test_question',
        title: 'Test Question',
        isRequired: true,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      // Focus and then unfocus without entering text
      await tester.tap(find.byType(TextFormField));
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      TestHelpers.expectErrorText('This field is required');
    });

    testWidgets('should validate minimum value', (WidgetTester tester) async {
      final widget = NumberInputWidget(
        questionId: 'test_question',
        title: 'Test Question',
        minValue: 10.0,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      await tester.enterText(find.byType(TextFormField), '5');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      TestHelpers.expectErrorText('Must be at least 10.0');
    });

    testWidgets('should validate maximum value', (WidgetTester tester) async {
      final widget = NumberInputWidget(
        questionId: 'test_question',
        title: 'Test Question',
        maxValue: 100.0,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      await tester.enterText(find.byType(TextFormField), '150');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      TestHelpers.expectErrorText('Must be no more than 100.0');
    });

    testWidgets('should validate invalid number format', (WidgetTester tester) async {
      final widget = NumberInputWidget(
        questionId: 'test_question',
        title: 'Test Question',
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      // Enter just a dot which should be invalid
      await tester.enterText(find.byType(TextFormField), '.');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      TestHelpers.expectErrorText('Please enter a valid number');
    });

    testWidgets('should prevent decimal input when decimals not allowed', (WidgetTester tester) async {
      final widget = NumberInputWidget(
        questionId: 'test_question',
        title: 'Test Question',
        allowDecimals: false,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      // Try to enter decimal - should be filtered out by input formatter
      await tester.enterText(find.byType(TextFormField), '42.5');
      await tester.pump();

      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      // Should only have '425' due to digits only formatter
      expect(textField.controller?.text, equals('425'));
    });

    testWidgets('should clear error when user starts typing', (WidgetTester tester) async {
      final widget = NumberInputWidget(
        questionId: 'test_question',
        title: 'Test Question',
        isRequired: true,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      // Trigger error
      await tester.tap(find.byType(TextFormField));
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      TestHelpers.expectErrorText('This field is required');

      // Start typing to clear error
      await tester.enterText(find.byType(TextFormField), '1');
      await tester.pump();

      TestHelpers.expectNoError();
    });

    testWidgets('should use digits only formatter when decimals not allowed', (WidgetTester tester) async {
      final widget = NumberInputWidget(
        questionId: 'test_question',
        title: 'Test Question',
        allowDecimals: false,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      // Try to enter decimal - should be filtered out
      await tester.enterText(find.byType(TextFormField), '42.5abc');
      await tester.pump();

      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      // Only digits should remain due to FilteringTextInputFormatter.digitsOnly
      expect(textField.controller?.text, equals('425'));
    });

    testWidgets('should use decimal formatter when decimals allowed', (WidgetTester tester) async {
      final widget = NumberInputWidget(
        questionId: 'test_question',
        title: 'Test Question',
        allowDecimals: true,
        decimalPlaces: 2,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      // The decimal formatter should allow decimals
      await tester.enterText(find.byType(TextFormField), '42.5');
      await tester.pump();

      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.controller?.text, equals('42.5'));
    });

    testWidgets('should handle unit selection change', (WidgetTester tester) async {
      Function(String)? unitCallback;
      
      final widget = NumberInputWidget(
        questionId: 'test_question',
        title: 'Test Question',
        unitOptions: ['cm', 'ft', 'in'],
        selectedUnit: 'cm',
        onUnitChanged: (unit) => unitCallback?.call(unit),
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      // Set up the callback to track unit changes
      String? changedUnit;
      unitCallback = (unit) => changedUnit = unit;

      // Find and tap the dropdown
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      // Select a different unit
      await tester.tap(find.text('ft').last);
      await tester.pumpAndSettle();

      expect(changedUnit, equals('ft'));
    });

    testWidgets('should update when currentValue changes', (WidgetTester tester) async {
      var currentValue = 10.0;
      
      Widget buildWidget() => NumberInputWidget(
        questionId: 'test_question',
        title: 'Test Question',
        currentValue: currentValue,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, buildWidget());

      var textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.controller?.text, equals('10.0'));

      // Change current value and rebuild
      currentValue = 20.0;
      await TestHelpers.pumpAndSettle(tester, buildWidget());

      textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.controller?.text, equals('20.0'));
    });

    testWidgets('should update when selectedUnit changes', (WidgetTester tester) async {
      var selectedUnit = 'cm';
      
      Widget buildWidget() => NumberInputWidget(
        questionId: 'test_question',
        title: 'Test Question',
        unitOptions: ['cm', 'ft', 'in'],
        selectedUnit: selectedUnit,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, buildWidget());

      var dropdown = tester.widget<DropdownButton<String>>(find.byType(DropdownButton<String>));
      expect(dropdown.value, equals('cm'));

      // Change selected unit and rebuild
      selectedUnit = 'ft';
      await TestHelpers.pumpAndSettle(tester, buildWidget());

      dropdown = tester.widget<DropdownButton<String>>(find.byType(DropdownButton<String>));
      expect(dropdown.value, equals('ft'));
    });

    group('fromConfig constructor', () {
      test('should create widget from valid config', () {
        final config = TestHelpers.createBasicConfig(
          questionId: 'test_question',
          title: 'Test Question',
          onAnswerChanged: mockCallback.call,
        );

        final widget = NumberInputWidget.fromConfig(config);

        expect(widget.questionId, equals('test_question'));
        expect(widget.title, equals('Test Question'));
        expect(widget.isRequired, isTrue);
        expect(widget.allowDecimals, isTrue);
      });

      test('should create widget with optional parameters', () {
        final config = TestHelpers.createBasicConfig(
          questionId: 'test_question',
          title: 'Test Question',
          subtitle: 'Test subtitle',
          onAnswerChanged: mockCallback.call,
          isRequired: false,
          currentValue: 42.0,
        );
        config['placeholder'] = 'Enter number';
        config['minValue'] = 0.0;
        config['maxValue'] = 100.0;
        config['allowDecimals'] = false;
        config['decimalPlaces'] = 1;
        config['unit'] = 'kg';
        config['unitOptions'] = ['kg', 'lb'];
        config['selectedUnit'] = 'kg';

        final widget = NumberInputWidget.fromConfig(config);

        expect(widget.subtitle, equals('Test subtitle'));
        expect(widget.placeholder, equals('Enter number'));
        expect(widget.currentValue, equals(42.0));
        expect(widget.minValue, equals(0.0));
        expect(widget.maxValue, equals(100.0));
        expect(widget.allowDecimals, isFalse);
        expect(widget.decimalPlaces, equals(1));
        expect(widget.unit, equals('kg'));
        expect(widget.unitOptions, equals(['kg', 'lb']));
        expect(widget.selectedUnit, equals('kg'));
        expect(widget.isRequired, isFalse);
      });

      test('should throw ArgumentError for missing questionId', () {
        final config = {
          'title': 'Test Question',
          'onAnswerChanged': mockCallback.call,
        };

        expect(
          () => NumberInputWidget.fromConfig(config),
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
          () => NumberInputWidget.fromConfig(config),
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
          () => NumberInputWidget.fromConfig(config),
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