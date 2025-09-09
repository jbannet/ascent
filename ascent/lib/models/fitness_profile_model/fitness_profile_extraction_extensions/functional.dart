import '../fitness_profile.dart';
import '../../../workflows/question_bank/questions/demographics/age_question.dart';
import '../../../workflows/question_bank/questions/demographics/gender_question.dart';
import '../../../workflows/question_bank/questions/fitness_assessment/q5_pushups_question.dart';
import '../../../workflows/question_bank/questions/fitness_assessment/q6_bodyweight_squats_question.dart';
import '../../../workflows/question_bank/questions/fitness_assessment/q6a_chair_stand_question.dart';
import '../../../workflows/question_bank/questions/fitness_assessment/q4a_fall_history_question.dart';
import '../../../constants.dart';

/// Extension to calculate functional fitness metrics for Activities of Daily Living (ADLs).
/// 
/// Functional fitness determines ability to perform daily tasks independently:
/// - Getting up from chairs/floor
/// - Carrying groceries
/// - Climbing stairs
/// - Reaching overhead
/// - Bending to pick things up
/// 
/// This assessment uses existing strength tests as proxies for functional capacity:
/// - SQUATS: Primary indicator of lower body function (sit-to-stand, stairs)
/// - CHAIR STAND: Basic functional threshold for those unable to squat
/// - PUSH-UPS: Upper body function (lifting, carrying, pushing)
/// 
/// Three Functional Levels:
/// - HIGH (0.7-1.0): Independent, dynamic movements, no limitations
/// - MODERATE (0.3-0.7): Some limitations, needs exercise modifications
/// - LOW (0.0-0.3): Significant limitations, needs assisted/seated exercises
/// 
/// Based on: Short Physical Performance Battery (SPPB), 30-Second Chair Stand Test
extension FunctionalFitness on FitnessProfile {
  
  /// Calculate functional fitness metrics
  void calculateFunctional() {
    final age = AgeQuestion.instance.calculatedAge;
    final gender = GenderQuestion.instance.genderAnswer;
    
    if (age == null || gender == null) {
      throw Exception('Missing required answers for functional calculation: age=$age, gender=$gender');
    }
    
    // Calculate functional fitness score (0-1)
    _calculateFunctionalFitnessScore(age, gender);
    
    // Determine functional capacity level
    _calculateFunctionalCapacityLevel();
    
    // Calculate ADL independence predictions
    _calculateADLIndependence(age);
  }
  
  /// Calculate comprehensive functional fitness score
  void _calculateFunctionalFitnessScore(int age, String gender) {
    double functionalScore = 0.0;
    double lowerBodyFunction = 0.0;
    double upperBodyFunction = 0.0;
    
    // LOWER BODY FUNCTIONAL ASSESSMENT (60% weight)
    final squatCount = Q6BodyweightSquatsQuestion.instance.getSquatsCount(answers);
    
    if (squatCount != null && squatCount > 0) {
      // Use squat performance as primary functional indicator
      // Functional thresholds based on SPPB and chair stand norms
      if (age < 60) {
        // Younger adults: higher functional expectations
        if (squatCount >= 20) {
          lowerBodyFunction = 1.0; // Excellent function
        } else if (squatCount >= 15) {
          lowerBodyFunction = 0.8; // Good function
        } else if (squatCount >= 10) {
          lowerBodyFunction = 0.6; // Moderate function
        } else if (squatCount >= 5) {
          lowerBodyFunction = 0.4; // Limited function
        } else {
          lowerBodyFunction = 0.2; // Poor function
        }
      } else if (age < 70) {
        // Older adults: adjusted expectations
        if (squatCount >= 15) {
          lowerBodyFunction = 1.0;
        } else if (squatCount >= 10) {
          lowerBodyFunction = 0.8;
        } else if (squatCount >= 7) {
          lowerBodyFunction = 0.6;
        } else if (squatCount >= 4) {
          lowerBodyFunction = 0.4;
        } else {
          lowerBodyFunction = 0.25;
        }
      } else {
        // 70+ years: further adjusted
        if (squatCount >= 10) {
          lowerBodyFunction = 1.0;
        } else if (squatCount >= 7) {
          lowerBodyFunction = 0.8;
        } else if (squatCount >= 5) {
          lowerBodyFunction = 0.6;
        } else if (squatCount >= 3) {
          lowerBodyFunction = 0.4;
        } else {
          lowerBodyFunction = 0.3;
        }
      }
    } else if (squatCount == 0) {
      // Check chair stand ability as fallback
      final canStandFromChair = Q6AChairStandQuestion.instance.canStandFromChair(answers);
      if (canStandFromChair == true) {
        // Can do chair stand but not squats: basic functional capacity
        lowerBodyFunction = 0.3;
      } else {
        // Cannot do chair stand: minimal functional capacity
        lowerBodyFunction = 0.1;
      }
    }
    
    // UPPER BODY FUNCTIONAL ASSESSMENT (40% weight)
    final pushupCount = Q5PushupsQuestion.instance.getPushupsCount(answers);
    
    if (pushupCount != null && pushupCount >= 0) {
      // Functional thresholds for daily tasks (lifting, carrying)
      if (gender == AnswerConstants.male) {
        if (age < 60) {
          if (pushupCount >= 15) {
            upperBodyFunction = 1.0;
          } else if (pushupCount >= 10) {
            upperBodyFunction = 0.7;
          } else if (pushupCount >= 5) {
            upperBodyFunction = 0.5;
          } else if (pushupCount >= 2) {
            upperBodyFunction = 0.3;
          } else {
            upperBodyFunction = 0.15;
          }
        } else {
          // 60+ adjusted expectations
          if (pushupCount >= 10) {
            upperBodyFunction = 1.0;
          } else if (pushupCount >= 5) {
            upperBodyFunction = 0.7;
          } else if (pushupCount >= 2) {
            upperBodyFunction = 0.5;
          } else if (pushupCount >= 1) {
            upperBodyFunction = 0.3;
          } else {
            upperBodyFunction = 0.2;
          }
        }
      } else {
        // Female thresholds
        if (age < 60) {
          if (pushupCount >= 10) {
            upperBodyFunction = 1.0;
          } else if (pushupCount >= 5) {
            upperBodyFunction = 0.7;
          } else if (pushupCount >= 2) {
            upperBodyFunction = 0.5;
          } else if (pushupCount >= 1) {
            upperBodyFunction = 0.3;
          } else {
            upperBodyFunction = 0.15;
          }
        } else {
          // 60+ adjusted
          if (pushupCount >= 5) {
            upperBodyFunction = 1.0;
          } else if (pushupCount >= 2) {
            upperBodyFunction = 0.7;
          } else if (pushupCount >= 1) {
            upperBodyFunction = 0.5;
          } else {
            upperBodyFunction = 0.25;
          }
        }
      }
    }
    
    // COMBINE SCORES (lower body more important for ADLs)
    functionalScore = (lowerBodyFunction * 0.6) + (upperBodyFunction * 0.4);
    
    // APPLY FALL HISTORY MODIFIER
    final hasFallen = Q4AFallHistoryQuestion.instance.fallHistoryAnswer == AnswerConstants.yes;
    if (hasFallen) {
      // Previous fall indicates functional limitations
      functionalScore *= 0.7;
    }
    
    // Store functional fitness score
    featuresMap['functional_fitness_score'] = functionalScore.clamp(0.0, 1.0);
    featuresMap['lower_body_function'] = lowerBodyFunction;
    featuresMap['upper_body_function'] = upperBodyFunction;
  }
  
  /// Determine functional capacity level for exercise prescription
  void _calculateFunctionalCapacityLevel() {
    final functionalScore = featuresMap['functional_fitness_score'] as double;
    
    if (functionalScore >= 0.7) {
      featuresMap['functional_capacity_level'] = 3.0; // High function
    } else if (functionalScore >= 0.3) {
      featuresMap['functional_capacity_level'] = 2.0; // Moderate function
    } else {
      featuresMap['functional_capacity_level'] = 1.0; // Low function
    }
    
    // Determine exercise modifications needed
    featuresMap['needs_seated_exercises'] = functionalScore < 0.3 ? 1.0 : 0.0;
    featuresMap['needs_assisted_exercises'] = functionalScore < 0.5 ? 1.0 : 0.0;
    featuresMap['can_do_floor_exercises'] = functionalScore >= 0.5 ? 1.0 : 0.0;
  }
  
  /// Calculate ADL independence predictions
  void _calculateADLIndependence(int age) {
    final functionalScore = featuresMap['functional_fitness_score'] as double;
    final lowerBodyFunction = featuresMap['lower_body_function'] as double;
    
    // Basic ADL independence (dressing, bathing, transfers)
    double basicADL = functionalScore;
    if (age >= 75) {
      basicADL *= 0.9; // Age adjustment
    }
    featuresMap['basic_adl_independence'] = basicADL.clamp(0.0, 1.0);
    
    // Instrumental ADL independence (shopping, housework, meal prep)
    double instrumentalADL = functionalScore;
    if (lowerBodyFunction < 0.5) {
      instrumentalADL *= 0.7; // Lower body crucial for iADLs
    }
    if (age >= 80) {
      instrumentalADL *= 0.85; // Age adjustment
    }
    featuresMap['instrumental_adl_independence'] = instrumentalADL.clamp(0.0, 1.0);
    
    // Risk of functional decline
    double declineRisk = 0.0;
    if (functionalScore < 0.5) declineRisk += 0.3;
    if (age >= 70) declineRisk += 0.2;
    if (age >= 80) declineRisk += 0.2;
    if (featuresMap['fall_risk_score'] != null) {
      declineRisk += (featuresMap['fall_risk_score'] as double) * 0.3;
    }
    featuresMap['functional_decline_risk'] = declineRisk.clamp(0.0, 1.0);
  }
}