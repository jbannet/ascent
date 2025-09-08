import 'package:ascent/constants_features.dart';
import '../fitness_profile.dart';
import '../../../workflows/question_bank/questions/demographics/age_question.dart';
import '../../../workflows/question_bank/questions/demographics/gender_question.dart';
import '../../../workflows/question_bank/questions/fitness_assessment/q4a_fall_history_question.dart';
import '../../../workflows/question_bank/questions/fitness_assessment/q4b_fall_risk_factors_question.dart';
import '../../../workflows/question_bank/questions/fitness_assessment/current_fitness_level_question.dart';
import '../../../constants.dart';

/// Extension to calculate balance feature importance.
/// 
/// Uses age, gender, physical limitations, experience level, and fall risk factors
/// to determine balance training importance.
/// Based on CDC STEADI Program, WHO Fall Prevention Guidelines.
extension Balance on FitnessProfile {
  
  /// Calculate balance training importance based on multiple factors
  void calculateBalance() {
    final age = AgeQuestion.instance.getAge(answers);
    final gender = GenderQuestion.instance.getGender(answers);
    final experienceLevel = CurrentFitnessLevelQuestion.instance.getFitnessLevel(answers);
    final hasFallen = Q4AFallHistoryQuestion.instance.hasFallen(answers);
    final fallRiskFactors = Q4BFallRiskFactorsQuestion.instance.getRiskFactors(answers);
    
    if (age == null || gender == null) {
      throw Exception('Missing required answers for balance calculation: age=$age, gender=$gender');
    }
    
    double importance = _calculateBalanceImportance(age, gender);
    importance = _applyActivityLevelModifiers(importance, experienceLevel, age);
    importance = _applyFallRiskModifiers(importance, hasFallen, fallRiskFactors);
    
    featuresMap[FeatureConstants.categoryBalance] = importance.clamp(0.0, 1.0);
  }
  
  /// Calculate base balance importance with evidence-based age thresholds
  double _calculateBalanceImportance(int age, String gender) {
    double baseImportance;
    
    // CDC/WHO evidence-based age thresholds for fall risk
    if (age < 30) baseImportance = 0.1;
    else if (age < 40) baseImportance = 0.2;
    else if (age < 50) baseImportance = 0.35;
    else if (age < 60) baseImportance = 0.5;
    else if (age < 65) baseImportance = 0.65;  // Critical transition
    else if (age < 75) baseImportance = 0.8;   // High-risk group
    else baseImportance = 1.0;                 // Maximum priority
    
    // Gender adjustments for women (higher fall risk)
    if (gender == AnswerConstants.female) {
      if (age >= 35) baseImportance += 0.05; // Peak bone mass decline begins
      if (age >= 45) baseImportance += 0.1;  // Perimenopause effects
      if (age >= 55) baseImportance += 0.1;  // Post-menopause acceleration
    }
    
    return baseImportance;
  }

  
  /// Apply modifiers based on activity level and sedentary behavior
  double _applyActivityLevelModifiers(double baseImportance, String? level, int age) {
    // Sedentary lifestyle increases fall risk, especially in older adults
    if (level == AnswerConstants.beginner && age >= 50) {
      return baseImportance + 0.1;
    }
    // Very active individuals may have slightly lower balance priority
    else if (level == AnswerConstants.advanced && age < 50) {
      return baseImportance - 0.05;
    }
    return baseImportance;
  }
  
  /// Apply modifiers based on fall history and risk factors
  double _applyFallRiskModifiers(double baseImportance, bool hasFallen, List<String> riskFactors) {
    // Previous fall is strongest predictor of future falls
    // If they've fallen, balance training becomes absolute priority
    if (hasFallen) {
      return 1.5; // Maximum priority regardless of age or other factors
    }
    
    double modifier = 0.0;
    
    // Additional risk factors from Q4B - already typed as List<String>
    if (riskFactors.contains(AnswerConstants.fearFalling)) {
      modifier += 0.1;  // Fear of falling affects movement patterns
    }
    
    if (riskFactors.contains(AnswerConstants.mobilityAids)) {
      modifier += 0.15;  // Using mobility aids indicates significant balance issues
    }
    
    if (riskFactors.contains(AnswerConstants.balanceProblems)) {
      modifier += 0.15;  // balance problems are direct risk factors
    }
    
    // Cap the total fall risk modifier at 0.4
    return baseImportance + modifier.clamp(0.0, 0.4);
  }
}