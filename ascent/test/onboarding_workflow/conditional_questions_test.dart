import 'package:ascent/constants_and_enums/constants.dart';
import 'package:ascent/workflow_views/onboarding_workflow/question_bank/questions/demographics/age_question.dart';
import 'package:ascent/workflow_views/onboarding_workflow/question_bank/questions/fitness_assessment/q4_run_vo2_question.dart';
import 'package:ascent/workflow_views/onboarding_workflow/question_bank/questions/fitness_assessment/q4a_fall_history_question.dart';
import 'package:ascent/workflow_views/onboarding_workflow/question_bank/questions/fitness_assessment/q4b_fall_risk_factors_question.dart';
import 'package:ascent/workflow_views/onboarding_workflow/question_bank/questions/fitness_assessment/q6_bodyweight_squats_question.dart';
import 'package:ascent/workflow_views/onboarding_workflow/question_bank/questions/fitness_assessment/q6a_chair_stand_question.dart';
import 'package:ascent/workflow_views/onboarding_workflow/question_bank/questions/fitness_assessment/q6b_balance_test_question.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Conditional onboarding questions', () {
    setUp(resetQuestionState);
    tearDown(resetQuestionState);

    group('Q4A – fall history', () {
      test('shows when age exceeds fall-risk threshold', () {
        setAgeYears(AnswerConstants.fallRiskAge);

        expect(Q4AFallHistoryQuestion.instance.shouldShow(), isTrue);
      });

      test('shows when mobility performance is below Cooper cutoff', () {
        setAgeYears(AnswerConstants.fallRiskAge - 10);
        setRunDistanceMiles(AnswerConstants.cooperAtRiskMiles / 2);

        expect(Q4AFallHistoryQuestion.instance.shouldShow(), isTrue);
      });

      test('hides when no risk triggers are present', () {
        setAgeYears(AnswerConstants.fallRiskAge - 15);
        setRunDistanceMiles(AnswerConstants.cooperAtRiskMiles + 0.5);

        expect(Q4AFallHistoryQuestion.instance.shouldShow(), isFalse);
      });
    });

    group('Q4B – fall risk factors', () {
      test('shows when a previous fall is recorded', () {
        setFallHistory(AnswerConstants.yes);

        expect(Q4BFallRiskFactorsQuestion.instance.shouldShow(), isTrue);
      });

      test('shows when age alone hits the fall-risk threshold', () {
        setAgeYears(AnswerConstants.fallRiskAge);
        setFallHistory(AnswerConstants.no);

        expect(Q4BFallRiskFactorsQuestion.instance.shouldShow(), isTrue);
      });

      test('shows when mobility is below Cooper cutoff', () {
        setAgeYears(AnswerConstants.fallRiskAge - 10);
        setFallHistory(AnswerConstants.no);
        setRunDistanceMiles(AnswerConstants.cooperAtRiskMiles / 2);

        expect(Q4BFallRiskFactorsQuestion.instance.shouldShow(), isTrue);
      });

      test('hides when all fall-risk triggers fail', () {
        setAgeYears(AnswerConstants.fallRiskAge - 10);
        setFallHistory(AnswerConstants.no);
        setRunDistanceMiles(AnswerConstants.cooperAtRiskMiles + 0.5);

        expect(Q4BFallRiskFactorsQuestion.instance.shouldShow(), isFalse);
      });
    });

    group('Q6A – chair stand', () {
      test('shows when age exceeds the fall-risk threshold', () {
        setAgeYears(AnswerConstants.fallRiskAge);
        setRunDistanceMiles(AnswerConstants.cooperAtRiskMiles + 0.5);
        setSquatCount(10);

        expect(Q6AChairStandQuestion.instance.shouldShow(), isTrue);
      });

      test('shows when mobility performance is below Cooper cutoff', () {
        setAgeYears(AnswerConstants.fallRiskAge - 10);
        setRunDistanceMiles(AnswerConstants.cooperAtRiskMiles / 2);
        setSquatCount(10);

        expect(Q6AChairStandQuestion.instance.shouldShow(), isTrue);
      });

      test('shows when bodyweight squat count is zero', () {
        setAgeYears(AnswerConstants.fallRiskAge - 10);
        setRunDistanceMiles(AnswerConstants.cooperAtRiskMiles + 0.5);
        setSquatCount(0);

        expect(Q6AChairStandQuestion.instance.shouldShow(), isTrue);
      });

      test('hides when no chair-stand triggers are present', () {
        setAgeYears(AnswerConstants.fallRiskAge - 10);
        setRunDistanceMiles(AnswerConstants.cooperAtRiskMiles + 0.5);
        setSquatCount(10);

        expect(Q6AChairStandQuestion.instance.shouldShow(), isFalse);
      });
    });

    group('Q6B – single-leg balance', () {
      test('shows when age exceeds the fall-risk threshold', () {
        setAgeYears(AnswerConstants.fallRiskAge);

        expect(Q6BBalanceTestQuestion.instance.shouldShow(), isTrue);
      });

      test('shows when mobility performance is below Cooper cutoff', () {
        setAgeYears(AnswerConstants.fallRiskAge - 10);
        setRunDistanceMiles(AnswerConstants.cooperAtRiskMiles / 2);

        expect(Q6BBalanceTestQuestion.instance.shouldShow(), isTrue);
      });

      test('shows when a previous fall is recorded', () {
        setFallHistory(AnswerConstants.yes);

        expect(Q6BBalanceTestQuestion.instance.shouldShow(), isTrue);
      });

      test('hides when no balance-test triggers are present', () {
        setAgeYears(AnswerConstants.fallRiskAge - 10);
        setFallHistory(AnswerConstants.no);
        setRunDistanceMiles(AnswerConstants.cooperAtRiskMiles + 0.5);

        expect(Q6BBalanceTestQuestion.instance.shouldShow(), isFalse);
      });
    });
  });
}

void resetQuestionState() {
  AgeQuestion.instance.setDateOfBirth(null);
  Q4TwelveMinuteRunQuestion.instance.fromJsonValue(null);
  Q4AFallHistoryQuestion.instance.setFallHistoryAnswer(null);
  Q4BFallRiskFactorsQuestion.instance.setRiskFactors(null);
  Q6BodyweightSquatsQuestion.instance.setSquatsCount(null);
  Q6AChairStandQuestion.instance.setChairStandAbility(null);
  Q6BBalanceTestQuestion.instance.setBalanceTime(null);
}

void setAgeYears(int years) {
  final now = DateTime.now();
  AgeQuestion.instance.setDateOfBirth(
    DateTime(now.year - years, now.month, now.day),
  );
}

void setRunDistanceMiles(double miles, {int timeMinutes = 12}) {
  Q4TwelveMinuteRunQuestion.instance.setRunData(
    distance: miles,
    unit: 'miles',
    timeMinutes: timeMinutes,
  );
}

void setFallHistory(String? value) {
  Q4AFallHistoryQuestion.instance.setFallHistoryAnswer(value);
}

void setSquatCount(int? value) {
  Q6BodyweightSquatsQuestion.instance.setSquatsCount(value);
}
