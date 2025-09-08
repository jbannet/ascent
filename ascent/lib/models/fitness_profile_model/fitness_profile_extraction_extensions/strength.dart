import '../fitness_profile.dart';
import '../reference_data/acsm_pushup_norms.dart';
import '../../../workflows/question_bank/questions/demographics/age_question.dart';
import '../../../workflows/question_bank/questions/demographics/gender_question.dart';
import '../../../workflows/question_bank/questions/fitness_assessment/q5_pushups_question.dart';
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
    final age = AgeQuestion.instance.getAge(answers);
    final gender = GenderQuestion.instance.getGender(answers);
    
    if (age == null || gender == null) {
      throw Exception('Missing required answers for strength calculation: age=$age, gender=$gender');
    }
    
    // 1. Calculate baseline fitness metrics
    _calculateStrengthBaseline(age, gender);
    
    // 2. Calculate workout parameters
    _calculateStrengthWorkoutParameters(age, gender);
  }
  
  /// Calculate baseline strength metrics from push-up assessment
  void _calculateStrengthBaseline(int age, String gender) {
    // Use push-up test if available (following cardio pattern with Cooper test)
    final pushupCount = Q5PushupsQuestion.instance.getPushupsCount(answers);
    if (pushupCount != null && pushupCount >= 0) {
      // Get strength fitness percentile using ACSM data
      double strengthPercentile = ACSMPushupNorms.getPercentile(
        pushupCount, age, gender
      );
      featuresMap['strength_fitness_percentile'] = strengthPercentile;
      
      // Calculate equivalent strength age
      featuresMap['strength_equivalent_age'] = ACSMPushupNorms.getEquivalentAge(
        pushupCount, age, gender
      ).toDouble();
      
      // Store raw push-up performance
      featuresMap['pushup_count'] = pushupCount.toDouble();
      
      // Calculate muscle endurance capacity (normalized to age/gender norms)
      // Higher percentile = better muscle endurance
      featuresMap['muscle_endurance_capacity'] = strengthPercentile;
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