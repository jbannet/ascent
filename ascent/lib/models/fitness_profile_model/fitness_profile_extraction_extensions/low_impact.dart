import '../fitness_profile.dart';
import '../../../workflows/question_bank/questions/demographics/age_question.dart';
import '../../../workflows/question_bank/questions/demographics/gender_question.dart';
import '../../../constants.dart';

/// Extension to calculate joint health and low impact exercise metrics.
/// 
/// This extension focuses on core joint health/low impact metrics:
/// 1. Joint stress tolerance assessment
/// 2. Impact sensitivity scoring
/// 3. Recovery capacity indicators
/// 4. Age and gender-based joint health factors
/// 
/// Based on OARSI Guidelines, American College of Rheumatology.
/// Note: Low impact importance is calculated in relative_objective_importance.dart
extension LowImpact on FitnessProfile {
  
  /// Calculate joint health and low impact exercise metrics
  void calculateLowImpact() {
    final age = AgeQuestion.instance.calculatedAge;
    final gender = GenderQuestion.instance.genderAnswer;
    
    if (age == null || gender == null) {
      throw Exception('Missing required answers for low impact calculation: age=$age, gender=$gender');
    }
    
    // Calculate joint health and impact-related metrics
    _calculateJointHealthMetrics(age, gender);
    _calculateImpactToleranceScoring(age, gender);
    _calculateRecoveryCapacityMetrics(age, gender);
  }
  
  /// Calculate joint health metrics based on age and gender factors
  void _calculateJointHealthMetrics(int age, String gender) {
    double jointHealthScore = 1.0;
    
    // Age-related joint degeneration (osteoarthritis research)
    if (age >= 45) {
      // Joint health declines more rapidly after 45
      jointHealthScore -= (age - 45) * 0.015; // 1.5% per year after 45
    } else if (age >= 30) {
      jointHealthScore -= (age - 30) * 0.005; // 0.5% per year 30-45
    }
    
    // Gender-specific factors (women have higher OA rates)
    if (gender == AnswerConstants.female) {
      if (age >= 45) {
        jointHealthScore -= 0.1; // Hormonal effects on joint health
      }
      if (age >= 55) {
        jointHealthScore -= 0.1; // Post-menopause acceleration
      }
    }
    
    featuresMap['joint_health_score'] = jointHealthScore.clamp(0.3, 1.0);
  }
  
  /// Calculate impact tolerance scoring
  void _calculateImpactToleranceScoring(int age, String gender) {
    double impactTolerance = 1.0;
    
    // Age-related decline in impact tolerance
    if (age >= 50) {
      impactTolerance -= (age - 50) * 0.02; // 2% per year after 50
    } else if (age >= 35) {
      impactTolerance -= (age - 35) * 0.01; // 1% per year 35-50
    }
    
    // Gender effects on impact tolerance
    if (gender == AnswerConstants.female) {
      impactTolerance -= 0.05; // Generally lower impact tolerance
    }
    
    featuresMap['impact_tolerance'] = impactTolerance.clamp(0.2, 1.0);
  }
  
  /// Calculate recovery capacity metrics for joint stress
  void _calculateRecoveryCapacityMetrics(int age, String gender) {
    // Recovery time needed between high-impact activities
    double recoveryHours = 24.0; // Base recovery time
    
    if (age >= 60) {
      recoveryHours = 72.0; // Need 3 days between high-impact
    } else if (age >= 45) {
      recoveryHours = 48.0; // Need 2 days
    } else if (age >= 30) {
      recoveryHours = 36.0; // Need 1.5 days
    }
    
    // Joint loading capacity (how much stress joints can handle)
    double jointLoadingCapacity = 1.0;
    if (age >= 40) {
      jointLoadingCapacity -= (age - 40) * 0.01; // 1% decline per year after 40
    }
    
    featuresMap['joint_recovery_hours'] = recoveryHours;
    featuresMap['joint_loading_capacity'] = jointLoadingCapacity.clamp(0.4, 1.0);
  }
}