import '../fitness_profile.dart';
import '../reference_data/acsm_pushup_norms.dart';
import '../reference_data/acsm_squat_norms.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/demographics/age_question.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/demographics/gender_question.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/fitness_assessment/q5_pushups_question.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/fitness_assessment/q6_bodyweight_squats_question.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/fitness_assessment/q6a_chair_stand_question.dart';
import '../../../constants_and_enums/constants.dart';

/// Extension to calculate strength fitness metrics and training parameters.
/// 
/// This extension focuses on core strength metrics:
/// 1. STRENGTH FITNESS BASELINE: Current fitness level metrics
///    - Push-up performance percentile (ACSM norms)
///    - Equivalent strength age based on performance
///    - Muscle endurance capacity
/// 
/// 2. WORKOUT CONSTRUCTION PARAMETERS: Values needed to build strength workouts
///    - Recovery requirements between sessions
///    - Training volume tolerance
///    - Age-related strength decline factors
/// 
/// References:
/// - ACSM's Guidelines for Exercise Testing and Prescription, 11th Edition (2021)
/// - Schoenfeld et al. (2019) "Resistance Training Volume Enhances Muscle Hypertrophy" - Sports Medicine
/// - Grgic et al. (2018) "Effects of Rest Interval Duration in Resistance Training" - Sports Medicine
/// - Cruz-Jentoft et al. (2019) "Sarcopenia: revised European consensus" - Age and Ageing
/// 
/// Note: Strength importance is calculated in relative_objective_importance.dart
extension Strength on FitnessProfile {
  
  /// Calculate strength fitness metrics and training parameters
  void calculateStrength() {
    final age = AgeQuestion.instance.calculatedAge;
    final gender = GenderQuestion.instance.genderAnswer;
    
    if (age == null || gender == null) {
      throw Exception('Missing required answers for strength calculation: age=$age, gender=$gender');
    }
    
    // 1. Calculate baseline fitness metrics
    _calculateStrengthBaseline(age, gender);
    
    // 2. Calculate workout parameters
    _calculateStrengthWorkoutParameters(age, gender);
  }
  
  /// Calculate baseline strength metrics from push-up and squat assessments
  void _calculateStrengthBaseline(int age, String gender) {
    double? upperBodyPercentile;
    double? lowerBodyPercentile;
    
    // UPPER BODY: Use push-up test if available
    final pushupCount = Q5PushupsQuestion.instance.getPushupsCount(answers);
    if (pushupCount != null && pushupCount >= 0) {
      upperBodyPercentile = ACSMPushupNorms.getPercentile(
        pushupCount, age, gender
      );
      featuresMap['upper_body_strength_percentile'] = upperBodyPercentile;
      
      
      // Store raw push-up performance
      featuresMap['pushup_count'] = pushupCount.toDouble();
      
    }
    
    // LOWER BODY: Use squat test if available
    final squatCount = Q6BodyweightSquatsQuestion.instance.getSquatsCount(answers);
    if (squatCount != null && squatCount >= 0) {
      // Store raw squat performance
      featuresMap['squat_count'] = squatCount.toDouble();
      
      if (squatCount == 0) {
        // Cannot do squats - check chair stand ability for functional assessment
        final canStandFromChair = Q6AChairStandQuestion.instance.canStandFromChair(answers);
        
        if (canStandFromChair == true) {
          // Can do chair stand but not squats - basic functional strength
          lowerBodyPercentile = 0.15; // Very low but functional
          featuresMap['lower_body_strength_percentile'] = lowerBodyPercentile;
          featuresMap['functional_strength_level'] = 0.3;
          featuresMap['needs_basic_strength'] = 1.0;
          featuresMap['needs_functional_training'] = 1.0;
          featuresMap['needs_seated_exercises'] = 0.0;
          featuresMap['can_do_chair_stand'] = 1.0;
          
        } else if (canStandFromChair == false) {
          // Cannot do chair stand - no functional strength
          lowerBodyPercentile = 0.0;
          featuresMap['lower_body_strength_percentile'] = lowerBodyPercentile;
          featuresMap['functional_strength_level'] = 0.0;
          featuresMap['needs_basic_strength'] = 1.0;
          featuresMap['needs_functional_training'] = 1.0;
          featuresMap['needs_seated_exercises'] = 1.0;
          featuresMap['can_do_chair_stand'] = 0.0;
          
          // Add fall risk modifier
          featuresMap['fall_risk_modifier'] = 0.3;
          
        } else {
          // Chair stand question not answered (shouldn't happen with condition)
          // Use conservative estimates
          lowerBodyPercentile = 0.1;
          featuresMap['lower_body_strength_percentile'] = lowerBodyPercentile;
          featuresMap['needs_functional_training'] = 1.0;
        }
      } else {
        // Can do squats - use normal percentile calculation
        lowerBodyPercentile = ACSMSquatNorms.getPercentile(
          squatCount, age, gender
        );
        featuresMap['lower_body_strength_percentile'] = lowerBodyPercentile;
        
        
        // Check if needs functional training
        featuresMap['needs_functional_training'] = 
          ACSMSquatNorms.needsFunctionalTraining(squatCount, age) ? 1.0 : 0.0;
        
        // They can do squats, so they don't need seated exercises
        featuresMap['needs_seated_exercises'] = 0.0;
        featuresMap['can_do_chair_stand'] = 1.0; // If can squat, can definitely do chair stand
        
        // Set functional strength level based on squat count
        if (squatCount >= 15) {
          featuresMap['functional_strength_level'] = 1.0; // Full functional
        } else if (squatCount >= 10) {
          featuresMap['functional_strength_level'] = 0.7; // Good functional
        } else if (squatCount >= 5) {
          featuresMap['functional_strength_level'] = 0.5; // Moderate functional
        } else {
          featuresMap['functional_strength_level'] = 0.3; // Basic functional
        }
      }
      
    }
    
    // OVERALL STRENGTH: Combine upper and lower body if both available
    if (upperBodyPercentile != null && lowerBodyPercentile != null) {
      // Weighted average: lower body slightly more important for functional fitness
      featuresMap['strength_fitness_percentile'] = 
        (upperBodyPercentile * 0.4 + lowerBodyPercentile * 0.6);
      
      
    } else if (upperBodyPercentile != null) {
      // Only upper body data available
      featuresMap['strength_fitness_percentile'] = upperBodyPercentile;
    } else if (lowerBodyPercentile != null) {
      // Only lower body data available
      featuresMap['strength_fitness_percentile'] = lowerBodyPercentile;
    }
    
  }
  
  /// Calculate strength training parameters based on scientific evidence
  void _calculateStrengthWorkoutParameters(int age, String gender) {
    // Recovery time between strength sessions
    // Based on: Schoenfeld et al. (2016) "Effects of Resistance Training Frequency" - Sports Medicine
    // - Younger individuals: 48 hours for muscle protein synthesis
    // - Middle-aged: 48-72 hours due to slower recovery
    // - Older adults: 72-96 hours for complete recovery
    if (age < 40) {
      featuresMap['strength_recovery_hours'] = 48.0;
    } else if (age < 60) {
      featuresMap['strength_recovery_hours'] = 72.0;
    } else {
      featuresMap['strength_recovery_hours'] = 96.0;
    }
    
    
    // Calculate all training parameters
    _calculateTrainingParameters(age);
  }

  /// Calculate all strength training parameters
  void _calculateTrainingParameters(int age) {
    final strengthPercentile = featuresMap['strength_fitness_percentile'] as double? ?? 0.5;

    // Optimal rep ranges based on age
    if (age >= 50 || strengthPercentile < 0.25) {
      featuresMap['strength_optimal_rep_range_min'] = 10.0;
      featuresMap['strength_optimal_rep_range_max'] = 15.0;
    } else {
      featuresMap['strength_optimal_rep_range_min'] = 8.0;
      featuresMap['strength_optimal_rep_range_max'] = 12.0;
    }

    // Time between sets (seconds)
    if (age >= 60) {
      featuresMap['strength_time_between_sets'] = 45.0; // 30-60 sec range, use middle
    } else if (strengthPercentile > 0.75) {
      featuresMap['strength_time_between_sets'] = 150.0; // 2.5 min for strength/power
    } else {
      featuresMap['strength_time_between_sets'] = 90.0; // 1.5 min for hypertrophy
    }

    // Percent of 1RM
    if (age >= 50 && strengthPercentile < 0.5) {
      featuresMap['strength_percent_of_1RM'] = 45.0; // 40-50% for older novice
    } else if (strengthPercentile < 0.25) {
      featuresMap['strength_percent_of_1RM'] = 40.0; // Very weak, focus on form
    } else if (strengthPercentile > 0.75) {
      featuresMap['strength_percent_of_1RM'] = 80.0; // Experienced lifters
    } else {
      featuresMap['strength_percent_of_1RM'] = 55.0; // 50-60% novice to intermediate
    }

    // Optimal sets range
    if (strengthPercentile < 0.10) {
      featuresMap['strength_optimal_sets_range_min'] = 1.0; // 1-3 sets, learning form
      featuresMap['strength_optimal_sets_range_max'] = 3.0;
    } else if (strengthPercentile > 0.75) {
      featuresMap['strength_optimal_sets_range_min'] = 3.0; // 3-5 sets for advanced
      featuresMap['strength_optimal_sets_range_max'] = 5.0;
    } else {
      featuresMap['strength_optimal_sets_range_min'] = 2.0; // 2-4 sets normal
      featuresMap['strength_optimal_sets_range_max'] = 4.0;
    }
  }
}