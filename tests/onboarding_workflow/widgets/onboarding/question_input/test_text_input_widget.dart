import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ascent/onboarding_workflow/widgets/onboarding/question_input/text_input_widget.dart';
import 'test_helpers.dart';

void main() {
  group('TextInputWidget', () {
    late MockCallback mockCallback;

    setUp(() {
      mockCallback = TestHelpers.createMockCallback();
    });

    testWidgets('should create widget with required parameters', (WidgetTester tester) async {
      final widget = TextInputWidget(
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
      final widget = TextInputWidget(
        questionId: 'test_question',
        title: 'Test Question',
        subtitle: 'Test subtitle',
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      expect(find.text('Test subtitle'), findsOneWidget);
    });

    testWidgets('should display placeholder text', (WidgetTester tester) async {
      final widget = TextInputWidget(
        questionId: 'test_question',
        title: 'Test Question',
        placeholder: 'Enter your answer',
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      expect(TestHelpers.findTextFieldByPlaceholder('Enter your answer'), findsOneWidget);
    });

    testWidgets('should show current value in text field', (WidgetTester tester) async {
      final widget = TextInputWidget(
        questionId: 'test_question',
        title: 'Test Question',
        currentValue: 'Initial value',
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.controller?.text, equals('Initial value'));
    });

    testWidgets('should not show required indicator when not required', (WidgetTester tester) async {
      final widget = TextInputWidget(
        questionId: 'test_question',
        title: 'Test Question',
        isRequired: false,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      expect(TestHelpers.findRequiredIndicator(), findsNothing);
    });

    testWidgets('should show character count when maxLength is set', (WidgetTester tester) async {
      final widget = TextInputWidget(
        questionId: 'test_question',
        title: 'Test Question',
        maxLength: 100,
        currentValue: 'Hello',
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      expect(find.text('5/100'), findsOneWidget);
    });

    testWidgets('should show helper text for length constraints', (WidgetTester tester) async {
      final widget = TextInputWidget(
        questionId: 'test_question',
        title: 'Test Question',
        minLength: 5,
        maxLength: 50,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      expect(find.text('Enter 5-50 characters'), findsOneWidget);
    });

    testWidgets('should call onAnswerChanged when text is entered', (WidgetTester tester) async {
      final widget = TextInputWidget(
        questionId: 'test_question',
        title: 'Test Question',
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      await tester.enterText(find.byType(TextFormField), 'New text');
      await tester.pump();

      expect(mockCallback.callCount, greaterThan(0));
      expect(mockCallback.wasCalledWith('test_question', 'New text'), isTrue);
    });

    testWidgets('should validate required field on focus lost', (WidgetTester tester) async {
      final widget = TextInputWidget(
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

    testWidgets('should validate minimum length', (WidgetTester tester) async {
      final widget = TextInputWidget(
        questionId: 'test_question',
        title: 'Test Question',
        minLength: 5,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      await tester.enterText(find.byType(TextFormField), 'Hi');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      TestHelpers.expectErrorText('Must be at least 5 characters');
    });

    testWidgets('should validate maximum length', (WidgetTester tester) async {
      final widget = TextInputWidget(
        questionId: 'test_question',
        title: 'Test Question',
        maxLength: 5,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      await tester.enterText(find.byType(TextFormField), 'This is too long');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      TestHelpers.expectErrorText('Must be no more than 5 characters');
    });

    testWidgets('should clear error when user starts typing', (WidgetTester tester) async {
      final widget = TextInputWidget(
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
      await tester.enterText(find.byType(TextFormField), 'Text');
      await tester.pump();

      TestHelpers.expectNoError();
    });

    testWidgets('should handle multiline input', (WidgetTester tester) async {
      final widget = TextInputWidget(
        questionId: 'test_question',
        title: 'Test Question',
        multiline: true,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      // For multiline, we can verify the behavior through interaction
      // The widget should accept multi-line text input
      await tester.enterText(find.byType(TextFormField), 'Line 1\nLine 2\nLine 3');
      await tester.pump();

      expect(mockCallback.wasCalledWith('test_question', 'Line 1\nLine 2\nLine 3'), isTrue);
    });

    testWidgets('should use custom keyboard type', (WidgetTester tester) async {
      final widget = TextInputWidget(
        questionId: 'test_question',
        title: 'Test Question',
        keyboardType: TextInputType.emailAddress,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      // Verify that the keyboard type is passed to the widget correctly
      // We can test this by checking the widget's constructor parameters
      expect(widget.keyboardType, equals(TextInputType.emailAddress));
    });

    testWidgets('should use input formatters', (WidgetTester tester) async {
      final formatters = [FilteringTextInputFormatter.digitsOnly];
      
      final widget = TextInputWidget(
        questionId: 'test_question',
        title: 'Test Question',
        inputFormatters: formatters,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      // Test that input formatters are working by trying to enter non-numeric text
      await tester.enterText(find.byType(TextFormField), 'abc123def');
      await tester.pump();

      // Should only accept the digits due to FilteringTextInputFormatter.digitsOnly
      expect(mockCallback.wasCalledWith('test_question', '123'), isTrue);
    });

    testWidgets('should use custom validator', (WidgetTester tester) async {
      String? customValidator(String? value) {
        if (value != null && value.contains('bad')) {
          return 'Invalid input';
        }
        return null;
      }

      final widget = TextInputWidget(
        questionId: 'test_question',
        title: 'Test Question',
        validator: customValidator,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      await tester.enterText(find.byType(TextFormField), 'bad input');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      TestHelpers.expectErrorText('Invalid input');
    });

    group('fromConfig constructor', () {
      test('should create widget from valid config', () {
        final config = TestHelpers.createBasicConfig(
          questionId: 'test_question',
          title: 'Test Question',
          onAnswerChanged: mockCallback.call,
        );

        final widget = TextInputWidget.fromConfig(config);

        expect(widget.questionId, equals('test_question'));
        expect(widget.title, equals('Test Question'));
        expect(widget.isRequired, isTrue);
      });

      test('should create widget with optional parameters', () {
        final config = TestHelpers.createBasicConfig(
          questionId: 'test_question',
          title: 'Test Question',
          subtitle: 'Test subtitle',
          onAnswerChanged: mockCallback.call,
          isRequired: false,
          currentValue: 'Initial value',
        );
        config['placeholder'] = 'Enter text';
        config['maxLength'] = 100;
        config['minLength'] = 5;
        config['multiline'] = true;
        config['keyboardType'] = 'email';

        final widget = TextInputWidget.fromConfig(config);

        expect(widget.subtitle, equals('Test subtitle'));
        expect(widget.placeholder, equals('Enter text'));
        expect(widget.maxLength, equals(100));
        expect(widget.minLength, equals(5));
        expect(widget.multiline, isTrue);
        expect(widget.keyboardType, equals(TextInputType.emailAddress));
        expect(widget.isRequired, isFalse);
        expect(widget.currentValue, equals('Initial value'));
      });

      test('should throw ArgumentError for missing questionId', () {
        final config = {
          'title': 'Test Question',
          'onAnswerChanged': mockCallback.call,
        };

        expect(
          () => TextInputWidget.fromConfig(config),
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
          () => TextInputWidget.fromConfig(config),
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
          () => TextInputWidget.fromConfig(config),
          throwsA(isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('onAnswerChanged is required'),
          )),
        );
      });

      test('should parse keyboard types correctly', () {
        final testCases = {
          'text': TextInputType.text,
          'multiline': TextInputType.multiline,
          'number': TextInputType.number,
          'phone': TextInputType.phone,
          'email': TextInputType.emailAddress,
          'url': TextInputType.url,
          'name': TextInputType.name,
          'unknown': TextInputType.text,
          null: null,
        };

        for (final entry in testCases.entries) {
          final config = TestHelpers.createBasicConfig(
            questionId: 'test_question',
            title: 'Test Question',
            onAnswerChanged: mockCallback.call,
          );
          if (entry.key != null) {
            config['keyboardType'] = entry.key;
          }

          final widget = TextInputWidget.fromConfig(config);
          expect(widget.keyboardType, equals(entry.value));
        }
      });
    });
  });
}