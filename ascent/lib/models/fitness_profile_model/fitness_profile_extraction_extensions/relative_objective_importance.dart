import '../fitness_profile.dart';
import 'package:ascent/constants_and_enums/constants_features.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/demographics/age_question.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/demographics/gender_question.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/goals/fitness_goals_question.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/fitness_assessment/q4a_fall_history_question.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/fitness_assessment/q4b_fall_risk_factors_question.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/fitness_assessment/q6a_chair_stand_question.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/practical_constraints/q1_injuries_question.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/fitness_assessment/glp1_medications_question.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/demographics/weight_question.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/demographics/height_question.dart';
import '../../../constants_and_enums/constants.dart';

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

    // GLP-1 medications - decrease cardio priority to favor strength training
    final isOnGlp1 = Glp1MedicationsQuestion.instance.isOnGlp1Medications(answers);
    if (isOnGlp1) score -= 0.2;

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
    if (isOnGlp1) score += 1;
    
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
    double score = 0.0; // Start at zero

    // Under 50: Only get functional if they have actual deficits
    if (age < 50) {
      // Fall history increases functional need
      final hasFallen = Q4AFallHistoryQuestion.instance.fallHistoryAnswer == AnswerConstants.yes;
      if (hasFallen) {
        score += 0.3; // Moderate functional need for young people with falls
      }

      // Chair stand difficulty is critical functional marker
      final canStandFromChair = Q6AChairStandQuestion.instance.canStandFromChair(answers);
      if (canStandFromChair == false) {
        score += 0.5; // High priority for basic function restoration
      }

      return score.clamp(0.0, 2.0);
    }

    // 50+: Base functional importance starts
    score = 0.1; // Small base for 50+

    // AGE PROGRESSION (functional fitness becomes critical with age)
    if (age >= 80) {
      score += 0.7; // Highest priority for 80+
    } else if (age >= 70) {
      score += 0.5; // Very high priority for 70s
    } else if (age >= 65) {
      score += 0.35; // High priority at retirement age
    } else if (age >= 60) {
      score += 0.25; // Increasing importance
    } else if (age >= 55) {
      score += 0.15; // Starting to matter more
    }

    // DEFICIT MARKERS (regardless of age)
    // Fall history massively increases functional importance
    final hasFallen = Q4AFallHistoryQuestion.instance.fallHistoryAnswer == AnswerConstants.yes;
    if (hasFallen) {
      score += 0.6; // Falls indicate serious functional deficits
    }

    // Chair stand inability is critical functional marker
    final canStandFromChair = Q6AChairStandQuestion.instance.canStandFromChair(answers);
    if (canStandFromChair == false) {
      score += 0.8; // Maximum priority for basic function restoration
    }

    // OTHER RISK FACTORS for 50+
    // Gender adjustment (women have higher ADL disability rates)
    if (gender == AnswerConstants.female && age >= 65) {
      score += 0.1;
    }

    // Health goals for older adults
    final goals = FitnessGoalsQuestion.instance.getFitnessGoals(answers);
    if (goals.contains(AnswerConstants.betterHealth) && age >= 60) {
      score += 0.15; // Health-focused older adults need functional training
    }

    return score.clamp(0.0, 2.0);
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
    featuresMap[FeatureConstants.categoryFunctional] = rawScores['functional']! / total;
  }
}