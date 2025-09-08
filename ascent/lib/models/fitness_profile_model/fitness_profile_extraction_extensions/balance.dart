import '../fitness_profile.dart';
import '../../../workflows/question_bank/questions/demographics/age_question.dart';
import '../../../workflows/question_bank/questions/demographics/gender_question.dart';
import '../../../workflows/question_bank/questions/fitness_assessment/q4a_fall_history_question.dart';
import '../../../workflows/question_bank/questions/fitness_assessment/q4b_fall_risk_factors_question.dart';
import '../../../workflows/question_bank/questions/fitness_assessment/current_fitness_level_question.dart';
import '../../../constants.dart';

/// Extension to calculate balance and fall risk metrics.
/// 
/// This extension focuses on core balance/fall risk metrics:
/// 1. Fall risk score calculation
/// 2. Balance assessment metrics
/// 3. Mobility and functional movement indicators
/// 4. Age and gender-based risk factors
/// 
/// Based on CDC STEADI Program, WHO Fall Prevention Guidelines.
/// Note: Balance importance is calculated in relative_objective_importance.dart
extension Balance on FitnessProfile {
  
  /// Calculate balance and fall risk metrics
  void calculateBalance() {
    final age = AgeQuestion.instance.getAge(answers);
    final gender = GenderQuestion.instance.getGender(answers);
    final experienceLevel = CurrentFitnessLevelQuestion.instance.getFitnessLevel(answers);
    final hasFallen = Q4AFallHistoryQuestion.instance.hasFallen(answers);
    final fallRiskFactors = Q4BFallRiskFactorsQuestion.instance.getRiskFactors(answers);
    
    if (age == null || gender == null) {
      throw Exception('Missing required answers for balance calculation: age=$age, gender=$gender');
    }
    
    // Calculate core balance/fall risk metrics
    _calculateFallRiskScore(age, gender, hasFallen, fallRiskFactors);
    _calculateBalanceCapacity(age, gender, experienceLevel);
    _calculateMobilityMetrics(age, hasFallen, fallRiskFactors);
  }
  
  /// Calculate comprehensive fall risk score using CDC STEADI guidelines
  void _calculateFallRiskScore(int age, String gender, bool hasFallen, List<String> riskFactors) {
    double fallRiskScore = 0.0;
    
    // Previous fall history (strongest predictor - CDC research)
    if (hasFallen) {
      fallRiskScore = 1.0; // Maximum risk score
    } else {
      // Age-based risk assessment (CDC/WHO thresholds)
      if (age >= 75) {
        fallRiskScore += 0.6;
      } else if (age >= 65) {
        fallRiskScore += 0.4;
      } else if (age >= 50) {
        fallRiskScore += 0.2;
      } else if (age >= 40) {
        fallRiskScore += 0.1;
      }
      
      // Gender-based risk (women have higher fall rates)
      if (gender == AnswerConstants.female && age >= 45) {
        fallRiskScore += 0.15;
      }
      
      // Risk factor contributions
      if (riskFactors.contains(AnswerConstants.balanceProblems)) {
        fallRiskScore += 0.3;
      }
      if (riskFactors.contains(AnswerConstants.mobilityAids)) {
        fallRiskScore += 0.25;
      }
      if (riskFactors.contains(AnswerConstants.fearFalling)) {
        fallRiskScore += 0.2;
      }
    }
    
    featuresMap['fall_risk_score'] = fallRiskScore.clamp(0.0, 1.0);
  }
  
  /// Calculate balance capacity metrics based on age and fitness level
  void _calculateBalanceCapacity(int age, String gender, String? experienceLevel) {
    // Age-related balance decline
    double balanceCapacity = 1.0;
    if (age >= 30) {
      // 1% decline per year after 30 (research-based)
      balanceCapacity -= (age - 30) * 0.01;
    }
    
    // Gender effects (women generally have better balance when young)
    if (gender == AnswerConstants.female && age < 50) {
      balanceCapacity += 0.05;
    }
    
    // Fitness level impact on balance
    if (experienceLevel == AnswerConstants.advanced) {
      balanceCapacity += 0.1;
    } else if (experienceLevel == AnswerConstants.beginner) {
      balanceCapacity -= 0.15;
    }
    
    featuresMap['balance_capacity'] = balanceCapacity.clamp(0.3, 1.0);
  }
  
  /// Calculate mobility and functional movement metrics
  void _calculateMobilityMetrics(int age, bool hasFallen, List<String> riskFactors) {
    double mobilityIndex = 1.0;
    
    // Age-related mobility decline
    if (age >= 65) {
      mobilityIndex -= 0.3;
    } else if (age >= 50) {
      mobilityIndex -= 0.15;
    }
    
    // Impact of fall history on mobility confidence
    if (hasFallen) {
      mobilityIndex -= 0.4; // Significant reduction in mobility confidence
    }
    
    // Mobility aids indicate existing limitations
    if (riskFactors.contains(AnswerConstants.mobilityAids)) {
      mobilityIndex -= 0.3;
    }
    
    // Fear of falling reduces mobility
    if (riskFactors.contains(AnswerConstants.fearFalling)) {
      mobilityIndex -= 0.2;
    }
    
    featuresMap['mobility_index'] = mobilityIndex.clamp(0.2, 1.0);
  }
}