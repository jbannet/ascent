import '../fitness_profile.dart';
import '../../../workflows/question_bank/questions/demographics/age_question.dart';
import '../../../workflows/question_bank/questions/demographics/gender_question.dart';
import '../../../workflows/question_bank/questions/demographics/weight_question.dart';
import '../../../workflows/question_bank/questions/demographics/height_question.dart';
import '../../../workflows/question_bank/questions/goals/fitness_goals_question.dart';
import '../../../constants.dart';

/// Extension to calculate weight management metrics and training parameters.
/// 
/// This extension focuses on weight management objectives:
/// 1. WEIGHT MANAGEMENT BASELINE: Current metrics and health indicators
///    - Body Mass Index (BMI) calculation and classification
///    - Weight status categories (underweight, normal, overweight, obese)
///    - Age-adjusted BMI considerations for older adults
/// 
/// 2. WORKOUT CONSTRUCTION PARAMETERS: Values needed for weight management workouts
///    - Caloric expenditure optimization
///    - Exercise modality preferences based on weight status
///    - Training intensity adjustments for different BMI categories
///    - Low-impact exercise recommendations for higher BMI individuals
/// 
/// References:
/// - WHO BMI Classification (2021) - World Health Organization
/// - CDC Adult BMI Guidelines (2022) - Centers for Disease Control and Prevention
/// - ACSM's Guidelines for Exercise Testing and Prescription, 11th Edition (2021)
/// - Jakicic et al. (2019) "Exercise and Weight Management" - ACSM Position Stand
/// - Ross & Janssen (2001) "Physical activity, total and regional obesity" - Medicine & Science
/// - Hunter et al. (2008) "Exercise training prevents regain of visceral fat for 1 year" - Obesity
/// 
/// Note: Weight management importance is calculated in relative_objective_importance.dart
extension WeightManagement on FitnessProfile {
  
  /// Calculate weight management metrics and training parameters
  void calculateWeightManagement() {
    final age = AgeQuestion.instance.calculatedAge;
    final gender = GenderQuestion.instance.genderAnswer;
    final weight = WeightQuestion.instance.getWeightPounds(answers);
    final height = HeightQuestion.instance.getHeightInches(answers);
    final goals = FitnessGoalsQuestion.instance.getFitnessGoals(answers);
    
    // Only proceed if we have both weight and height data
    if (weight == null || height == null) {
      // Set default values indicating no weight management data
      featuresMap['has_weight_data'] = 0.0;
      return;
    }
    
    if (age == null || gender == null) {
      throw Exception('Missing required answers for weight management calculation: age=$age, gender=$gender');
    }
    
    featuresMap['has_weight_data'] = 1.0;
    
    // Store raw measurements
    featuresMap['weight_pounds'] = weight;
    featuresMap['height_inches'] = height;
    
    // 1. Calculate BMI and weight status
    _calculateBMIMetrics(weight, height, age, gender);
    
    // 2. Determine weight management objectives
    _calculateWeightObjectives(goals, age);
    
    // 3. Calculate exercise preferences and parameters
    _calculateWeightManagementExerciseParameters(age, gender);
  }
  
  /// Calculate BMI and related weight status metrics
  void _calculateBMIMetrics(double weightPounds, double heightInches, int age, String gender) {
    // Convert to metric for BMI calculation
    final weightKg = weightPounds * 0.453592;
    final heightM = heightInches * 0.0254;
    
    // Calculate BMI
    final bmi = weightKg / (heightM * heightM);
    featuresMap['bmi'] = bmi;
    
    // WHO BMI Classification with age adjustments
    // Note: BMI categories may be adjusted for older adults (65+)
    // Source: CDC Adult BMI Guidelines and WHO standards
    double bmiCutoffUnderweight = 18.5;
    double bmiCutoffOverweight = 25.0;
    double bmiCutoffObese = 30.0;
    
    // Age-adjusted BMI interpretation for older adults
    if (age >= 65) {
      // Slightly higher BMI may be acceptable for older adults
      // Source: Winter et al. (2014) "BMI and all-cause mortality in older adults"
      bmiCutoffUnderweight = 18.0;
      bmiCutoffOverweight = 27.0; // Slightly more lenient
      bmiCutoffObese = 32.0;
    }
    
    // Weight status classification
    if (bmi < bmiCutoffUnderweight) {
      featuresMap['weight_status'] = 0.0; // Underweight
      featuresMap['weight_status_category'] = 0.0;
      featuresMap['needs_weight_gain'] = 1.0;
      featuresMap['needs_weight_loss'] = 0.0;
    } else if (bmi < bmiCutoffOverweight) {
      featuresMap['weight_status'] = 1.0; // Normal weight
      featuresMap['weight_status_category'] = 1.0;
      featuresMap['needs_weight_gain'] = 0.0;
      featuresMap['needs_weight_loss'] = 0.0;
    } else if (bmi < bmiCutoffObese) {
      featuresMap['weight_status'] = 2.0; // Overweight
      featuresMap['weight_status_category'] = 2.0;
      featuresMap['needs_weight_gain'] = 0.0;
      featuresMap['needs_weight_loss'] = 0.7;
    } else {
      featuresMap['weight_status'] = 3.0; // Obese
      featuresMap['weight_status_category'] = 3.0;
      featuresMap['needs_weight_gain'] = 0.0;
      featuresMap['needs_weight_loss'] = 1.0;
    }
    
    // Health risk indicators based on BMI
    // Source: ACSM Guidelines and WHO BMI health risk assessment
    if (bmi < 16.0) {
      featuresMap['health_risk_bmi'] = 3.0; // Severe underweight - high risk
    } else if (bmi < bmiCutoffUnderweight) {
      featuresMap['health_risk_bmi'] = 1.0; // Mild underweight - low risk
    } else if (bmi < bmiCutoffOverweight) {
      featuresMap['health_risk_bmi'] = 0.0; // Normal - minimal risk
    } else if (bmi < bmiCutoffObese) {
      featuresMap['health_risk_bmi'] = 1.0; // Overweight - increased risk
    } else if (bmi < 35.0) {
      featuresMap['health_risk_bmi'] = 2.0; // Class I obesity - high risk
    } else if (bmi < 40.0) {
      featuresMap['health_risk_bmi'] = 3.0; // Class II obesity - very high risk
    } else {
      featuresMap['health_risk_bmi'] = 4.0; // Class III obesity - extremely high risk
    }
    
    // Ideal weight range calculation
    // Using Metropolitan Life Insurance tables adjusted for frame size
    final heightInchesInt = heightInches.round();
    double idealWeightMin, idealWeightMax;
    
    if (gender == AnswerConstants.male) {
      // Men: 106 lbs for first 5 feet, then 6 lbs for each additional inch
      idealWeightMin = 106 + (heightInchesInt - 60) * 6 - 10; // Small frame (-10 lbs)
      idealWeightMax = 106 + (heightInchesInt - 60) * 6 + 10; // Large frame (+10 lbs)
    } else {
      // Women: 100 lbs for first 5 feet, then 5 lbs for each additional inch  
      idealWeightMin = 100 + (heightInchesInt - 60) * 5 - 10; // Small frame (-10 lbs)
      idealWeightMax = 100 + (heightInchesInt - 60) * 5 + 10; // Large frame (+10 lbs)
    }
    
    featuresMap['ideal_weight_min'] = idealWeightMin.clamp(90, 300);
    featuresMap['ideal_weight_max'] = idealWeightMax.clamp(100, 320);
    
    // Weight deviation from ideal range
    final idealWeightMid = (idealWeightMin + idealWeightMax) / 2;
    final weightDeviation = ((weightPounds - idealWeightMid) / idealWeightMid * 100);
    featuresMap['weight_deviation_percent'] = weightDeviation;
  }
  
  /// Determine weight management objectives based on goals and metrics
  void _calculateWeightObjectives(List<String>? goals, int age) {
    final hasWeightLossGoal = goals?.contains(AnswerConstants.loseWeight) ?? false;
    final hasMuscleGainGoal = goals?.contains(AnswerConstants.buildMuscle) ?? false;
    final needsWeightLoss = (featuresMap['needs_weight_loss'] ?? 0.0) > 0.5;
    final needsWeightGain = (featuresMap['needs_weight_gain'] ?? 0.0) > 0.5;
    
    // Primary weight management objective
    if (hasWeightLossGoal || needsWeightLoss) {
      featuresMap['weight_objective'] = 0.0; // loss
      featuresMap['weight_loss_priority'] = hasWeightLossGoal ? 1.0 : 0.7;
      featuresMap['weight_gain_priority'] = 0.0;
      featuresMap['weight_maintenance_priority'] = 0.2;
    } else if (hasMuscleGainGoal || needsWeightGain) {
      featuresMap['weight_objective'] = 1.0; // gain
      featuresMap['weight_loss_priority'] = 0.0;
      featuresMap['weight_gain_priority'] = needsWeightGain ? 1.0 : 0.8;
      featuresMap['weight_maintenance_priority'] = 0.2;
    } else {
      featuresMap['weight_objective'] = 2.0; // maintenance
      featuresMap['weight_loss_priority'] = 0.0;
      featuresMap['weight_gain_priority'] = 0.0;
      featuresMap['weight_maintenance_priority'] = 1.0;
    }
    
    // Caloric goals based on objective
    // Source: ACSM Position Stand on Weight Loss and Prevention of Weight Regain
    if (featuresMap['weight_objective'] == 0.0) { // loss
      // 1-2 lbs per week = 500-1000 calorie deficit per day
      featuresMap['daily_calorie_adjustment'] = -750.0; // Moderate deficit
      featuresMap['weekly_weight_goal'] = -1.5; // 1.5 lbs per week
    } else if (featuresMap['weight_objective'] == 1.0) { // gain
      // 0.5-1 lb per week = 250-500 calorie surplus per day
      featuresMap['daily_calorie_adjustment'] = 375.0; // Moderate surplus
      featuresMap['weekly_weight_goal'] = 0.75; // 0.75 lbs per week
    } else {
      featuresMap['daily_calorie_adjustment'] = 0.0;
      featuresMap['weekly_weight_goal'] = 0.0;
    }
    
    // Age-specific considerations
    if (age >= 65) {
      // Older adults: Focus on maintaining muscle mass while managing weight
      featuresMap['muscle_preservation_priority'] = 1.0;
      // Reduce aggressive weight loss for older adults
      if (featuresMap['weight_objective'] == 0.0) { // loss
        featuresMap['daily_calorie_adjustment'] = -500.0; // Gentler deficit
        featuresMap['weekly_weight_goal'] = -1.0; // 1 lb per week maximum
      }
    } else {
      featuresMap['muscle_preservation_priority'] = 0.6;
    }
  }
  
  /// Calculate exercise preferences and training parameters for weight management
  void _calculateWeightManagementExerciseParameters(int age, String gender) {
    final bmi = featuresMap['bmi'] as double;
    final weightObjective = featuresMap['weight_objective'] as double;
    
    // Exercise modality preferences based on BMI and objectives
    // Source: Jakicic et al. ACSM Position Stand on Exercise and Weight Management
    
    // Cardio preferences for weight management
    if (weightObjective == 0.0) { // loss
      featuresMap['cardio_priority_weight'] = 1.0;
      featuresMap['resistance_priority_weight'] = 0.7;
      // Higher BMI = more emphasis on low-impact cardio
      if (bmi >= 35) {
        featuresMap['low_impact_cardio_preference'] = 1.0;
        featuresMap['high_impact_cardio_preference'] = 0.2;
      } else if (bmi >= 30) {
        featuresMap['low_impact_cardio_preference'] = 0.8;
        featuresMap['high_impact_cardio_preference'] = 0.5;
      } else {
        featuresMap['low_impact_cardio_preference'] = 0.6;
        featuresMap['high_impact_cardio_preference'] = 0.8;
      }
    } else if (weightObjective == 1.0) { // gain
      featuresMap['cardio_priority_weight'] = 0.4;
      featuresMap['resistance_priority_weight'] = 1.0;
      featuresMap['low_impact_cardio_preference'] = 0.5;
      featuresMap['high_impact_cardio_preference'] = 0.3;
    } else {
      featuresMap['cardio_priority_weight'] = 0.8;
      featuresMap['resistance_priority_weight'] = 0.8;
      featuresMap['low_impact_cardio_preference'] = 0.7;
      featuresMap['high_impact_cardio_preference'] = 0.7;
    }
    
    // Training intensity recommendations
    // Source: ACSM Guidelines for different BMI categories
    if (bmi >= 35) {
      // Very high BMI: Start with low-moderate intensity
      featuresMap['max_training_intensity'] = 0.6; // 60% max effort
      featuresMap['preferred_training_intensity'] = 0.4; // 40% preferred
      featuresMap['joint_stress_modifier'] = 0.3; // High joint stress concern
    } else if (bmi >= 30) {
      // High BMI: Moderate intensity focus
      featuresMap['max_training_intensity'] = 0.75;
      featuresMap['preferred_training_intensity'] = 0.55;
      featuresMap['joint_stress_modifier'] = 0.5;
    } else if (bmi < 18.5) {
      // Underweight: Focus on strength and moderate cardio
      featuresMap['max_training_intensity'] = 0.85;
      featuresMap['preferred_training_intensity'] = 0.65;
      featuresMap['joint_stress_modifier'] = 0.9; // Low joint stress concern
    } else {
      // Normal BMI: Full intensity range available
      featuresMap['max_training_intensity'] = 0.9;
      featuresMap['preferred_training_intensity'] = 0.7;
      featuresMap['joint_stress_modifier'] = 0.8;
    }
    
    // Exercise duration recommendations
    // Source: ACSM recommendations for weight management
    if (weightObjective == 0.0) { // loss
      // Weight loss: 250+ minutes per week for significant weight loss
      featuresMap['weekly_cardio_minutes_target'] = 300.0;
      featuresMap['session_duration_min'] = 30.0;
      featuresMap['session_duration_max'] = 60.0;
    } else if (weightObjective == 1.0) { // gain
      // Weight gain: Moderate cardio to preserve cardiovascular health
      featuresMap['weekly_cardio_minutes_target'] = 150.0;
      featuresMap['session_duration_min'] = 20.0;
      featuresMap['session_duration_max'] = 45.0;
    } else {
      // Maintenance: Standard guidelines
      featuresMap['weekly_cardio_minutes_target'] = 200.0;
      featuresMap['session_duration_min'] = 25.0;
      featuresMap['session_duration_max'] = 50.0;
    }
    
    // Recovery considerations for higher BMI individuals
    if (bmi >= 30) {
      featuresMap['recovery_time_multiplier'] = 1.3; // 30% longer recovery
      featuresMap['progression_rate_modifier'] = 0.7; // Slower progression
    } else {
      featuresMap['recovery_time_multiplier'] = 1.0;
      featuresMap['progression_rate_modifier'] = 1.0;
    }
    
    // Water-based exercise preference for joint protection
    if (bmi >= 35 || age >= 70) {
      featuresMap['water_exercise_preference'] = 1.0;
    } else if (bmi >= 30 || age >= 60) {
      featuresMap['water_exercise_preference'] = 0.7;
    } else {
      featuresMap['water_exercise_preference'] = 0.4;
    }
  }
}