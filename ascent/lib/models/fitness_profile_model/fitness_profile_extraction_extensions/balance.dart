import '../fitness_profile.dart';
import '../../../../workflow_views/onboarding_workflow/question_bank/questions/demographics/age_question.dart';
import '../../../../workflow_views/onboarding_workflow/question_bank/questions/demographics/gender_question.dart';
import '../../../../workflow_views/onboarding_workflow/question_bank/questions/fitness_assessment/q4a_fall_history_question.dart';
import '../../../../workflow_views/onboarding_workflow/question_bank/questions/fitness_assessment/q4b_fall_risk_factors_question.dart';
import '../../../../constants.dart';

/// Extension to calculate balance and fall risk metrics.
/// 
/// This extension calculates three critical metrics that work together to create a 
/// comprehensive safety and capability profile for personalizing fitness programs:
/// 
/// ## 1. FALL RISK SCORE (0.0-1.0)
/// Measures probability of falling based on CDC STEADI guidelines.
/// - Previous fall = automatic 1.0 (maximum risk)
/// - Otherwise calculated from age thresholds, gender, and risk factors
/// - 0.0-0.3: Low risk - standard exercises appropriate
/// - 0.3-0.6: Moderate risk - needs balance focus, avoid high-impact
/// - 0.6-1.0: High risk - requires supervised/seated exercises
/// 
/// ## 2. BALANCE CAPACITY (0.3-1.0)
/// Measures actual physical balance ability.
/// - Accounts for age decline (1% per year after 30)
/// - Modified by fitness level and gender
/// - 0.8-1.0: Excellent - can handle dynamic challenges (single-leg work)
/// - 0.6-0.8: Good - standard balance exercises appropriate
/// - Below 0.6: Needs basic stability training first
/// 
/// ## 3. MOBILITY INDEX (0.2-1.0)
/// Measures functional movement capacity and confidence.
/// - Combines physical limitations with psychological factors
/// - Heavily impacted by fall history (-0.4), mobility aids (-0.3), fear (-0.2)
/// - 0.8-1.0: Full range movements, sports training appropriate
/// - 0.4-0.8: Modified exercises, confidence building needed
/// - Below 0.4: Chair-based or rehabilitation focus
/// 
/// ## USAGE IN FITNESS APP:
/// 1. Fall Risk Score is the primary safety gate - if ≥0.6, override other metrics
/// 2. Balance Capacity determines exercise complexity you can assign
/// 3. Mobility Index guides movement range and psychological readiness
/// 
/// Example: A 70-year-old with fall history might have:
/// - fallRiskScore=1.0 (maximum due to fall)
/// - balanceCapacity=0.5 (age-related decline)
/// - mobilityIndex=0.3 (low confidence after fall)
/// Result: Seated exercises with gradual balance rehabilitation focus
/// 
/// Based on CDC STEADI Program, WHO Fall Prevention Guidelines.
/// Note: Balance importance is calculated in relative_objective_importance.dart
extension Balance on FitnessProfile {
  
  /// Calculate balance and fall risk metrics
  void calculateBalance() {
    final age = AgeQuestion.instance.calculatedAge;
    final gender = GenderQuestion.instance.genderAnswer;
    // Experience level removed - using performance metrics instead
    final hasFallen = Q4AFallHistoryQuestion.instance.fallHistoryAnswer == AnswerConstants.yes;
    final fallRiskFactors = Q4BFallRiskFactorsQuestion.instance.riskFactors;
    
    if (age == null || gender == null) {
      throw Exception('Missing required answers for balance calculation: age=$age, gender=$gender');
    }
    
    // Calculate core balance/fall risk metrics
    _calculateFallRiskScore(age, gender, hasFallen, fallRiskFactors);
    _calculateBalanceCapacity(age, gender);
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
  
  /// Calculate balance capacity metrics based on age
  void _calculateBalanceCapacity(int age, String gender) {
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
    
    // Without fitness level, use neutral baseline
    
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