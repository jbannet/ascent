import '../fitness_profile.dart';
import '../reference_data/acsm_pushup_norms.dart';
import '../reference_data/acsm_squat_norms.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/demographics/age_question.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/demographics/gender_question.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/fitness_assessment/q5_pushups_question.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/fitness_assessment/q6_bodyweight_squats_question.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/fitness_assessment/q6a_chair_stand_question.dart';
import '../../../constants.dart';

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
      
      // Calculate equivalent strength age based on pushups
      featuresMap['upper_body_equivalent_age'] = ACSMPushupNorms.getEquivalentAge(
        pushupCount, age, gender
      ).toDouble();
      
      // Store raw push-up performance
      featuresMap['pushup_count'] = pushupCount.toDouble();
      
      // Upper body endurance capacity
      featuresMap['upper_body_endurance_capacity'] = upperBodyPercentile;
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
          
          // Equivalent age is older but not maximum
          featuresMap['lower_body_equivalent_age'] = (age + 15).toDouble();
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
          
          // Equivalent age is significantly older
          featuresMap['lower_body_equivalent_age'] = (age + 25).toDouble();
        } else {
          // Chair stand question not answered (shouldn't happen with condition)
          // Use conservative estimates
          lowerBodyPercentile = 0.1;
          featuresMap['lower_body_strength_percentile'] = lowerBodyPercentile;
          featuresMap['needs_functional_training'] = 1.0;
          featuresMap['lower_body_equivalent_age'] = (age + 20).toDouble();
        }
      } else {
        // Can do squats - use normal percentile calculation
        lowerBodyPercentile = ACSMSquatNorms.getPercentile(
          squatCount, age, gender
        );
        featuresMap['lower_body_strength_percentile'] = lowerBodyPercentile;
        
        // Calculate equivalent strength age based on squats
        featuresMap['lower_body_equivalent_age'] = ACSMSquatNorms.getEquivalentAge(
          squatCount, age, gender
        ).toDouble();
        
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
      
      // Lower body endurance capacity
      featuresMap['lower_body_endurance_capacity'] = lowerBodyPercentile;
    }
    
    // OVERALL STRENGTH: Combine upper and lower body if both available
    if (upperBodyPercentile != null && lowerBodyPercentile != null) {
      // Weighted average: lower body slightly more important for functional fitness
      featuresMap['strength_fitness_percentile'] = 
        (upperBodyPercentile * 0.4 + lowerBodyPercentile * 0.6);
      
      // Overall muscle endurance capacity
      featuresMap['muscle_endurance_capacity'] = 
        featuresMap['strength_fitness_percentile'] as double;
      
      // Combined equivalent age
      final upperAge = featuresMap['upper_body_equivalent_age'] as double;
      final lowerAge = featuresMap['lower_body_equivalent_age'] as double;
      featuresMap['strength_equivalent_age'] = (upperAge * 0.4 + lowerAge * 0.6);
    } else if (upperBodyPercentile != null) {
      // Only upper body data available
      featuresMap['strength_fitness_percentile'] = upperBodyPercentile;
      featuresMap['muscle_endurance_capacity'] = upperBodyPercentile;
      featuresMap['strength_equivalent_age'] = featuresMap['upper_body_equivalent_age'] as double;
    } else if (lowerBodyPercentile != null) {
      // Only lower body data available
      featuresMap['strength_fitness_percentile'] = lowerBodyPercentile;
      featuresMap['muscle_endurance_capacity'] = lowerBodyPercentile;
      featuresMap['strength_equivalent_age'] = featuresMap['lower_body_equivalent_age'] as double;
    }
    
    // Age-based strength decline factors
    // Based on: Cruz-Jentoft et al. 2019 - European Working Group on Sarcopenia
    // Muscle mass decreases 3-8% per decade after age 30
    // Muscle strength decreases 10-15% per decade after age 50
    if (age >= 30) {
      double declineRate;
      if (age < 50) {
        // 3-8% muscle mass loss per decade, avg 5%
        declineRate = 0.005; // 0.5% per year
      } else if (age < 70) {
        // 10-15% strength loss per decade, avg 12.5%
        declineRate = 0.0125; // 1.25% per year
      } else {
        // Accelerated loss after 70
        declineRate = 0.02; // 2% per year
      }
      final strengthDeclineFactor = 1.0 - ((age - 30) * declineRate);
      featuresMap['strength_age_factor'] = strengthDeclineFactor.clamp(0.4, 1.0);
    } else {
      featuresMap['strength_age_factor'] = 1.0;
    }
    
    // Gender-based strength differences
    // Based on: Janssen et al. (2000) J Appl Physiol - "Skeletal muscle mass and distribution"
    // Women have ~66% of men's muscle mass on average
    // Upper body strength difference is greater (~50-60% of male strength)
    if (gender == AnswerConstants.female) {
      featuresMap['strength_gender_factor'] = 0.6; // Women ~60% of male upper body strength
    } else {
      featuresMap['strength_gender_factor'] = 1.0;
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
    
    // Training volume tolerance
    // Based on: Fragala et al. (2019) "Resistance Training for Older Adults" - NSCA Position Statement
    // - Younger adults: Can handle higher training volumes
    // - Middle-aged: 15-20% reduction in volume capacity
    // - Older adults: 30-40% reduction in volume capacity
    if (age < 40) {
      featuresMap['strength_volume_factor'] = 1.0;
    } else if (age < 60) {
      featuresMap['strength_volume_factor'] = 0.8; // 20% reduction
    } else {
      featuresMap['strength_volume_factor'] = 0.65; // 35% reduction
    }
    
    // Optimal rep ranges based on age
    // Based on: Grgic et al. (2018) "Effects of Rest Interval Duration" - Sports Medicine
    // Older adults benefit from moderate rep ranges (8-12) vs heavy loads
    if (age < 50) {
      featuresMap['strength_optimal_rep_range_min'] = 6.0;
      featuresMap['strength_optimal_rep_range_max'] = 12.0;
    } else {
      featuresMap['strength_optimal_rep_range_min'] = 8.0;
      featuresMap['strength_optimal_rep_range_max'] = 15.0;
    }
  }
}