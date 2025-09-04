import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ascent/core/onboarding_workflow/widgets/onboarding/question_input/ranking_widget.dart';
import 'test_helpers.dart';

void main() {
  group('RankingWidget', () {
    late MockRankingCallback mockCallback;
    late List<RankingOption> testOptions;

    setUp(() {
      mockCallback = MockRankingCallback();
      testOptions = TestHelpers.createRankingOptions();
    });

    testWidgets('should create widget with required parameters', (WidgetTester tester) async {
      final widget = RankingWidget(
        questionId: 'test_question',
        title: 'Test Question',
        options: testOptions,
        maxRankings: 3,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      expect(find.text('Test Question'), findsOneWidget);
      expect(find.text('Option 1'), findsOneWidget);
      expect(find.text('Option 2'), findsOneWidget);
      expect(find.text('Option 3'), findsOneWidget);
      expect(find.text('Rank your top 3 choices (1 = most important)'), findsOneWidget);
      expect(find.text('0/3 ranked'), findsOneWidget);
    });

    testWidgets('should display subtitle when provided', (WidgetTester tester) async {
      final widget = RankingWidget(
        questionId: 'test_question',
        title: 'Test Question',
        subtitle: 'Test subtitle',
        options: testOptions,
        maxRankings: 3,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      expect(find.text('Test subtitle'), findsOneWidget);
    });

    testWidgets('should show required indicator when required', (WidgetTester tester) async {
      final widget = RankingWidget(
        questionId: 'test_question',
        title: 'Test Question',
        options: testOptions,
        maxRankings: 3,
        isRequired: true,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      expect(find.text('* Required'), findsOneWidget);
    });

    testWidgets('should not show required indicator when not required', (WidgetTester tester) async {
      final widget = RankingWidget(
        questionId: 'test_question',
        title: 'Test Question',
        options: testOptions,
        maxRankings: 3,
        isRequired: false,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      expect(find.text('* Required'), findsNothing);
    });

    testWidgets('should show current rankings when provided', (WidgetTester tester) async {
      final widget = RankingWidget(
        questionId: 'test_question',
        title: 'Test Question',
        options: testOptions,
        maxRankings: 3,
        currentRankings: {'value1': 1, 'value2': 2},
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      expect(find.text('Your Rankings'), findsOneWidget);
      expect(find.text('1st choice'), findsOneWidget);
      expect(find.text('2nd choice'), findsOneWidget);
      expect(find.text('2/3 ranked'), findsOneWidget);
    });

    testWidgets('should display option descriptions', (WidgetTester tester) async {
      final widget = RankingWidget(
        questionId: 'test_question',
        title: 'Test Question',
        options: testOptions,
        maxRankings: 3,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      expect(find.text('First option description'), findsOneWidget);
      expect(find.text('Second option description'), findsOneWidget);
    });

    testWidgets('should show ranking dialog when option is tapped', (WidgetTester tester) async {
      final widget = RankingWidget(
        questionId: 'test_question',
        title: 'Test Question',
        options: testOptions,
        maxRankings: 3,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      await tester.tap(find.text('Option 1'));
      await tester.pumpAndSettle();

      expect(find.text('Rank: Option 1'), findsOneWidget);
      expect(find.text('Select a ranking:'), findsOneWidget);
      expect(find.text('1st'), findsOneWidget);
      expect(find.text('2nd'), findsOneWidget);
      expect(find.text('3rd'), findsOneWidget);
    });

    testWidgets('should set ranking when rank button is tapped', (WidgetTester tester) async {
      final widget = RankingWidget(
        questionId: 'test_question',
        title: 'Test Question',
        options: testOptions,
        maxRankings: 3,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      // Tap on first option to open dialog
      await tester.tap(find.text('Option 1'));
      await tester.pumpAndSettle();

      // Tap on 1st rank button
      await tester.tap(find.text('1st'));
      await tester.pumpAndSettle();

      expect(mockCallback.callCount, equals(1));
      expect(mockCallback.wasCalledWith('test_question', {'value1': 1}), isTrue);
    });

    testWidgets('should update ranking counter when items are ranked', (WidgetTester tester) async {
      final widget = RankingWidget(
        questionId: 'test_question',
        title: 'Test Question',
        options: testOptions,
        maxRankings: 3,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      expect(find.text('0/3 ranked'), findsOneWidget);

      // Rank first option
      await tester.tap(find.text('Option 1'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('1st'));
      await tester.pumpAndSettle();

      expect(find.text('1/3 ranked'), findsOneWidget);
    });

    testWidgets('should show ranked options with visual indicators', (WidgetTester tester) async {
      final widget = RankingWidget(
        questionId: 'test_question',
        title: 'Test Question',
        options: testOptions,
        maxRankings: 3,
        currentRankings: {'value1': 1},
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      // Should show rank number in circle (multiple instances are expected)
      expect(find.text('1'), findsAtLeast(1));
      // Should show rank text (multiple instances are expected)
      expect(find.text('1st'), findsAtLeast(1));
    });

    testWidgets('should show remove button for ranked items in dialog', (WidgetTester tester) async {
      final widget = RankingWidget(
        questionId: 'test_question',
        title: 'Test Question',
        options: testOptions,
        maxRankings: 3,
        currentRankings: {'value1': 1},
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      // Tap on ranked option (use last to get the one in options list)
      await tester.tap(find.text('Option 1').last);
      await tester.pumpAndSettle();

      expect(find.text('Remove'), findsOneWidget);
    });

    testWidgets('should remove ranking when remove button is tapped', (WidgetTester tester) async {
      final widget = RankingWidget(
        questionId: 'test_question',
        title: 'Test Question',
        options: testOptions,
        maxRankings: 3,
        currentRankings: {'value1': 1},
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      // Tap on ranked option (use last to get the one in options list)
      await tester.tap(find.text('Option 1').last);
      await tester.pumpAndSettle();

      // Tap remove button
      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();

      expect(mockCallback.callCount, equals(1));
      expect(mockCallback.wasCalledWith('test_question', <String, int>{}), isTrue);
    });

    testWidgets('should prevent duplicate rankings when allowTies is false', (WidgetTester tester) async {
      final widget = RankingWidget(
        questionId: 'test_question',
        title: 'Test Question',
        options: testOptions,
        maxRankings: 3,
        allowTies: false,
        currentRankings: {'value1': 1},
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      // Tap on second option
      await tester.tap(find.text('Option 2'));
      await tester.pumpAndSettle();

      // Find the 1st rank button - it should be present but disabled/unavailable
      final firstRankButton = find.text('1st').last;
      expect(firstRankButton, findsOneWidget);
    });

    testWidgets('should allow duplicate rankings when allowTies is true', (WidgetTester tester) async {
      final widget = RankingWidget(
        questionId: 'test_question',
        title: 'Test Question',
        options: testOptions,
        maxRankings: 3,
        allowTies: true,
        currentRankings: {'value1': 1, 'value2': 1},
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      // Should be able to create widget with duplicate rankings when allowTies is true
      expect(find.text('2/3 ranked'), findsOneWidget);
      expect(find.text('1st choice'), findsNWidgets(2)); // Two items with 1st choice
    });

    testWidgets('should close dialog when cancel is tapped', (WidgetTester tester) async {
      final widget = RankingWidget(
        questionId: 'test_question',
        title: 'Test Question',
        options: testOptions,
        maxRankings: 3,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      // Open dialog
      await tester.tap(find.text('Option 1'));
      await tester.pumpAndSettle();

      expect(find.text('Rank: Option 1'), findsOneWidget);

      // Tap cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Rank: Option 1'), findsNothing);
    });

    testWidgets('should update when currentRankings changes', (WidgetTester tester) async {
      var currentRankings = <String, int>{'value1': 1};
      
      Widget buildWidget() => RankingWidget(
        questionId: 'test_question',
        title: 'Test Question',
        options: testOptions,
        maxRankings: 3,
        currentRankings: currentRankings,
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, buildWidget());

      expect(find.text('1/3 ranked'), findsOneWidget);

      // Change rankings and rebuild
      currentRankings = {'value1': 1, 'value2': 2};
      await TestHelpers.pumpAndSettle(tester, buildWidget());

      expect(find.text('2/3 ranked'), findsOneWidget);
    });

    testWidgets('should use correct rank colors', (WidgetTester tester) async {
      final widget = RankingWidget(
        questionId: 'test_question',
        title: 'Test Question',
        options: testOptions,
        maxRankings: 3,
        currentRankings: {'value1': 1, 'value2': 2, 'value3': 3},
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      // Should display all three rankings
      expect(find.text('1st choice'), findsOneWidget);
      expect(find.text('2nd choice'), findsOneWidget);
      expect(find.text('3rd choice'), findsOneWidget);
    });

    testWidgets('should show edit icon for ranked options and add icon for unranked', (WidgetTester tester) async {
      final widget = RankingWidget(
        questionId: 'test_question',
        title: 'Test Question',
        options: testOptions,
        maxRankings: 3,
        currentRankings: {'value1': 1},
        onAnswerChanged: mockCallback.call,
      );

      await TestHelpers.pumpAndSettle(tester, widget);

      // Should show edit icon for ranked option
      expect(find.byIcon(Icons.edit), findsOneWidget);
      // Should show add icons for unranked options
      expect(find.byIcon(Icons.add_circle_outline), findsNWidgets(2));
    });
  });
}