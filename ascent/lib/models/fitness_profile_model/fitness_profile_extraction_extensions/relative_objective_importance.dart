import '../fitness_profile.dart';
import 'package:ascent/constants_features.dart';
import '../../../workflows/question_bank/questions/demographics/age_question.dart';
import '../../../workflows/question_bank/questions/demographics/gender_question.dart';
import '../../../workflows/question_bank/questions/goals/fitness_goals_question.dart';
import '../../../workflows/question_bank/questions/fitness_assessment/q4a_fall_history_question.dart';
import '../../../workflows/question_bank/questions/fitness_assessment/q4b_fall_risk_factors_question.dart';
import '../../../workflows/question_bank/questions/fitness_assessment/q6a_chair_stand_question.dart';
import '../../../workflows/question_bank/questions/practical_constraints/q1_injuries_question.dart';
import '../../../workflows/question_bank/questions/practical_constraints/q2_high_impact_question.dart';
import '../../../workflows/question_bank/questions/fitness_assessment/glp1_medications_question.dart';
import '../../../workflows/question_bank/questions/demographics/weight_question.dart';
import '../../../workflows/question_bank/questions/demographics/height_question.dart';
import '../../../constants.dart';

/// Extension to calculate relative importance across all exercise modalities.
/// 
/// This replaces individual importance calculations in each extension with a 
/// unified system that ensures relative weighting based on user goals, needs,
/// and constraints. All importance scores sum to 1.0 across modalities.
/// 
/// Evidence-based scoring prioritizes:
/// 1. Goal alignment (primary driver)
/// 2. Individual needs/deficits 
/// 3. Medical/safety considerations
/// 4. Age-related risk factors
extension RelativeImportance on FitnessProfile {

  /// Calculate relative importance for all exercise modalities
  void calculateRelativeImportance() {
    final age = AgeQuestion.instance.calculatedAge;
    final gender = GenderQuestion.instance.genderAnswer;
    
    if (age == null || gender == null) {
      throw Exception('Missing required answers for importance calculation: age=$age, gender=$gender');
    }
    
    // Calculate raw scores for each modality
    final Map<String, double> rawScores = {
      'cardio': _calculateCardioRawScore(age, gender),
      'strength': _calculateStrengthRawScore(age, gender),
      'balance': _calculateBalanceRawScore(age, gender),
      'functional': _calculateFunctionalRawScore(age, gender),
      'stretching': _calculateStretchingRawScore(age, gender),
      'low_impact': _calculateLowImpactRawScore(age, gender),
    };
    
    // Normalize scores to sum to 1.0
    _normalizeImportanceScores(rawScores);
  }
  
  /// Calculate cardio raw importance score based on multiple evidence-based factors
  double _calculateCardioRawScore(int age, String gender) {
    double score = 0.25; // Base importance for everyone
    
    // PRIMARY DRIVER: Goal alignment (strongest predictor of exercise adherence)
    final goals = FitnessGoalsQuestion.instance.getFitnessGoals(answers);
    if (goals.contains(AnswerConstants.loseWeight)) score += 0.4;
    if (goals.contains(AnswerConstants.improveEndurance)) score += 0.5;
    if (goals.contains(AnswerConstants.betterHealth)) score += 0.3;
    if (goals.contains(AnswerConstants.liveLonger)) score += 0.3;
    
    // Current fitness gap (bigger gap = higher cardio need)
    final cardioPercentile = featuresMap['cardio_fitness_percentile'];
    if (cardioPercentile != null && cardioPercentile < 0.4) {
      score += (0.4 - cardioPercentile) * 0.6; // Scale based on fitness gap
    }
    
    // Age-based cardiovascular disease risk (gradual, not exponential)
    if (age >= 40) {
      score += (age - 40) * 0.008; // +0.008 per year after 40 (modest)
    }
    
    // Current activity deficit
    // Activities removed - using performance metrics instead
    final List<String> activities = [];
    final hasCardio = activities.any((a) => 
      [AnswerConstants.runningJogging, AnswerConstants.cycling, 
       AnswerConstants.swimming].contains(a));
    if (!hasCardio) score += 0.25;
    
    // Gender-specific risk factors
    if (gender == AnswerConstants.female && age >= 50) {
      score += 0.1; // Post-menopause cardiovascular risk
    }
    
    return score;
  }
  
  /// Calculate strength raw importance score
  double _calculateStrengthRawScore(int age, String gender) {
    double score = 0.3; // Base importance (higher than cardio due to sarcopenia)
    
    // Goal alignment
    final goals = FitnessGoalsQuestion.instance.getFitnessGoals(answers);
    if (goals.contains(AnswerConstants.buildMuscle)) score += 0.5;
    if (goals.contains(AnswerConstants.betterHealth)) score += 0.25;
    if (goals.contains(AnswerConstants.liveLonger)) score += 0.25;
    
    // Sarcopenia risk (muscle loss with age)
    if (age >= 30) {
      score += (age - 30) * 0.01; // +0.01 per year after 30
    }
    
    // Gender-specific factors
    if (gender == AnswerConstants.female) {
      if (age >= 35) score += 0.1; // Peak bone mass decline
      if (age >= 50) score += 0.15; // Menopause acceleration
    }
    
    // Current strength activity deficit
    // Activities removed - using performance metrics instead
    final List<String> activities = [];
    final hasStrength = activities.contains(AnswerConstants.weightTraining);
    if (!hasStrength) score += 0.2;
    
    // Experience level (beginners need more guidance)
    // Fitness level removed - using performance metrics instead
    final String? fitnessLevel = null;
    if (fitnessLevel == AnswerConstants.beginner) score += 0.15;
    
    // GLP-1 medications - SIGNIFICANT increase due to muscle mass preservation needs
    final isOnGlp1 = Glp1MedicationsQuestion.instance.isOnGlp1Medications(answers);
    if (isOnGlp1) score += 0.6;
    
    // Low weight over 35 - muscle building priority
    if (age >= 35) {
      final weight = WeightQuestion.instance.getWeightPounds(answers);
      final height = HeightQuestion.instance.getHeightInches(answers);
      if (weight != null && height != null) {
        final bmi = (weight / (height * height)) * 703; // BMI calculation
        if (bmi < 20.0) score += 0.4; // Low BMI indicates need for muscle building
      }
    }
    
    return score;
  }
  
  /// Calculate balance raw importance score
  double _calculateBalanceRawScore(int age, String gender) {
    double score = 0.1; // Low base importance for young adults
    
    // Fall history is absolute priority
    final hasFallen = Q4AFallHistoryQuestion.instance.fallHistoryAnswer == AnswerConstants.yes;
    if (hasFallen) {
      return 1.0; // Maximum priority regardless of other factors
    }
    
    // Age-based fall risk (CDC/WHO evidence-based thresholds)
    if (age >= 65) {
      score += 0.6; // Critical transition to high-risk
    } else if (age >= 50) {
      score += 0.3;
    } else if (age >= 40) {
      score += 0.1;
    }
    
    // Fall risk factors
    final fallRiskFactors = Q4BFallRiskFactorsQuestion.instance.riskFactors;
    if (fallRiskFactors.contains(AnswerConstants.balanceProblems)) score += 0.4;
    if (fallRiskFactors.contains(AnswerConstants.fearFalling)) score += 0.2;
    if (fallRiskFactors.contains(AnswerConstants.mobilityAids)) score += 0.3;
    
    // Gender adjustment (women have higher fall risk)
    if (gender == AnswerConstants.female && age >= 45) {
      score += 0.1; // Menopause-related bone density changes
    }
    
    // Sedentary behavior increases fall risk
    // Fitness level removed - using performance metrics instead
    final String? fitnessLevel = null;
    if (fitnessLevel == AnswerConstants.beginner && age >= 50) {
      score += 0.15;
    }
    
    return score;
  }
  
  /// Calculate stretching/flexibility raw importance score
  double _calculateStretchingRawScore(int age, String gender) {
    double score = 0.15; // Moderate base importance
    
    // Goal alignment
    final goals = FitnessGoalsQuestion.instance.getFitnessGoals(answers);
    if (goals.contains(AnswerConstants.increaseFlexibility)) score += 0.4;
    if (goals.contains(AnswerConstants.betterHealth)) score += 0.2;
    
    // Age-based flexibility decline
    if (age >= 30) {
      score += (age - 30) * 0.005; // +0.005 per year after 30 (gradual)
    }
    
    // Injury history indicates need for flexibility
    final injuries = Q1InjuriesQuestion.instance.getInjuries(answers);
    if (injuries.isNotEmpty && !injuries.contains(AnswerConstants.none)) {
      score += 0.25; // Injury recovery/prevention
    }
    
    // Current activity level
    // Activities removed - using performance metrics instead
    final List<String> activities = [];
    final hasFlexibility = activities.contains(AnswerConstants.yoga);
    if (!hasFlexibility) score += 0.15;
    
    // Sedentary lifestyle increases stiffness
    // Fitness level removed - using performance metrics instead
    final String? fitnessLevel = null;
    if (fitnessLevel == AnswerConstants.beginner) score += 0.2;
    
    return score;
  }
  
  /// Calculate functional fitness raw importance score
  double _calculateFunctionalRawScore(int age, String gender) {
    double score = 0.15; // Base importance
    
    // AGE IS PRIMARY DRIVER (functional fitness becomes critical with age)
    if (age >= 80) {
      score += 0.6; // Highest priority for 80+
    } else if (age >= 70) {
      score += 0.45; // Very high priority for 70s
    } else if (age >= 65) {
      score += 0.35; // High priority at retirement age
    } else if (age >= 60) {
      score += 0.25; // Increasing importance
    } else if (age >= 50) {
      score += 0.15; // Starting to matter
    }
    
    // Goal alignment
    final goals = FitnessGoalsQuestion.instance.getFitnessGoals(answers);
    if (goals.contains(AnswerConstants.buildMuscle)) score += 0.25;
    if (goals.contains(AnswerConstants.betterHealth)) score += 0.2;
    
    // Functional deficit (low functional score = higher need)
    final functionalScore = featuresMap['functional_fitness_score'];
    if (functionalScore != null) {
      final scoreVal = functionalScore;
      if (scoreVal < 0.3) {
        score += 0.5; // Critical need
      } else if (scoreVal < 0.5) {
        score += 0.3; // High need
      } else if (scoreVal < 0.7) {
        score += 0.15; // Moderate need
      }
    }
    
    // Fall history massively increases functional importance
    final hasFallen = Q4AFallHistoryQuestion.instance.fallHistoryAnswer == AnswerConstants.yes;
    if (hasFallen) {
      score += 0.5; // Falls indicate functional deficits
    }
    
    // Chair stand inability is critical functional marker
    final canStandFromChair = Q6AChairStandQuestion.instance.chairStandAbility == AnswerConstants.yes;
    if (canStandFromChair == false) {
      score += 0.6; // Maximum priority for basic function restoration
    }
    
    // Gender adjustment (women have higher ADL disability rates)
    if (gender == AnswerConstants.female && age >= 65) {
      score += 0.1;
    }
    
    return score.clamp(0.0, 2.0);
  }
  
  /// Calculate low impact raw importance score
  double _calculateLowImpactRawScore(int age, String gender) {
    double score = 0.1; // Low base importance for most people
    
    // Medical restrictions are primary driver
    final medicalRestrictions = Q2HighImpactQuestion.instance.getMedicalRestrictions(answers);
    if (medicalRestrictions.contains(AnswerConstants.highImpact)) {
      score += 0.5;
    }
    if (medicalRestrictions.contains(AnswerConstants.heavyLifting)) {
      score += 0.3;
    }
    if (medicalRestrictions.contains(AnswerConstants.cardioIntense)) {
      score += 0.4;
    }
    
    // Injury history
    final injuries = Q1InjuriesQuestion.instance.getInjuries(answers);
    if (injuries.contains(AnswerConstants.knee)) {
      score += 0.3;
    }
    if (injuries.contains(AnswerConstants.back)) {
      score += 0.25;
    }
    if (injuries.contains(AnswerConstants.wristAnkle)) {
      score += 0.2;
    }
    
    // Age-based joint stress considerations
    if (age >= 60) {
      score += 0.3;
    } else if (age >= 45) {
      score += 0.15;
    }
    
    // Gender-specific considerations (women have higher osteoarthritis rates)
    if (gender == AnswerConstants.female && age >= 45) {
      score += 0.15;
    }
    
    return score;
  }
  
  /// Normalize raw scores so they sum to 1.0 (true relative importance)
  void _normalizeImportanceScores(Map<String, double> rawScores) {
    final double total = rawScores.values.reduce((a, b) => a + b);
    
    if (total <= 0) {
      // Fallback to equal weighting if no scores
      rawScores.forEach((key, _) => rawScores[key] = 0.2);
      return;
    }
    
    // Normalize and store in featuresMap using proper constants
    featuresMap[FeatureConstants.categoryCardio] = rawScores['cardio']! / total;
    featuresMap[FeatureConstants.categoryStrength] = rawScores['strength']! / total;
    featuresMap[FeatureConstants.categoryBalance] = rawScores['balance']! / total;
    featuresMap[FeatureConstants.categoryStretching] = rawScores['stretching']! / total;
    featuresMap[FeatureConstants.categoryLowImpact] = rawScores['low_impact']! / total;
  }
}