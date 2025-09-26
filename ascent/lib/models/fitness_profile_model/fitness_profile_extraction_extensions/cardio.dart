import '../fitness_profile.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/demographics/age_question.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/demographics/gender_question.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/fitness_assessment/q4_run_vo2_question.dart';
import '../../../constants_and_enums/constants_features.dart';

/// Extension to calculate cardiovascular fitness metrics and training parameters.
///
/// This extension focuses on core cardio metrics:
/// 1. CARDIOVASCULAR FITNESS BASELINE: Current fitness level metrics
///    - VO2max (ml/kg/min) from Cooper test or estimation
///    - METs capacity (metabolic equivalents)
///    - Fitness percentile for age/gender
///
/// 2. WORKOUT CONSTRUCTION PARAMETERS: Values needed to build cardio workouts
///    - Maximum heart rate (age-based)
///    - Target heart rate zones (5 zones)
///    - MET levels for each training zone
///    - Recovery requirements
///
/// Note: Cardio importance is calculated in relative_objective_importance.dart
extension Cardio on FitnessProfile {
  /// Calculate cardiovascular fitness metrics and training parameters
  void calculateCardio() {
    final age = AgeQuestion.instance.calculatedAge;
    final gender = GenderQuestion.instance.genderAnswer;

    if (age == null || gender == null) {
      throw Exception(
        'Missing required answers for cardio calculation: age=$age, gender=$gender',
      );
    }

    // 1. Calculate baseline fitness metrics
    _calculateCardiovascularBaseline(age, gender);

    // 2. Calculate workout parameters including HR zones
    _calculateCardioWorkoutParameters(age, gender);
  }

  /// Calculate baseline cardiovascular fitness metrics from run data
  void _calculateCardiovascularBaseline(int age, String gender) {
    // Get distance and time from the question
    final runData = Q4TwelveMinuteRunQuestion.instance.runPerformanceData;

    if (runData != null &&
        runData.distanceMiles > 0 &&
        runData.timeMinutes > 0) {
      // Calculate pace in minutes per mile
      final paceMinutesPerMile = runData.timeMinutes / runData.distanceMiles;
      featuresMap[CardioConstants.cardioPace] = paceMinutesPerMile;
      // For now, use a placeholder estimation based on pace
      double vo2max = _estimateVO2MaxFromPace(paceMinutesPerMile);
      featuresMap[CardioConstants.vo2max] = vo2max;

      // Convert to METs capacity (VO2max / 3.5)
      featuresMap[CardioConstants.metsCapacity] = vo2MaxToMets(vo2max);

      // Calculate fitness percentile using VO2max and demographic data
      featuresMap[CardioConstants.cardioFitnessPercentile] = _estimatePercentileFromVO2Max(
        vo2max,
        age,
        gender,
      );
    }
  }

  /// Lookup the implied %VO2max based on time range of the run
  double _getVO2MaxPercentageFromTimeRange(int timeMinutes) {
    if (timeMinutes <= 12) {
      return 100.0; // 8–12 min: 2-mile race effort, Cooper test
    } else if (timeMinutes <= 20) {
      return 95.0; // 12–20 min: 5k race pace
    } else if (timeMinutes <= 30) {
      return 90.0; // 20–30 min: 10k race pace
    } else if (timeMinutes <= 45) {
      return 85.0; // 30–45 min: 15k / 10-mile
    } else if (timeMinutes <= 60) {
      return 80.0; // 45–60 min: 60-min run, tempo
    } else if (timeMinutes <= 90) {
      return 75.0; // 60–90 min: Half marathon pace
    } else if (timeMinutes <= 150) {
      return 70.0; // 90–150 min: Marathon pace (for trained runners)
    } else if (timeMinutes <= 240) {
      return 65.0; // 2+ hours: Easy endurance
    } else {
      return 55.0; // 4–6 hours: Ultramarathon, long hikes (average of 50-60%)
    }
  }

  /// Estimate VO2max from pace using time-based %VO2max lookup
  /// This will be enhanced with the full formula from user
  double _estimateVO2MaxFromPace(double paceMinutesPerMile) {
    // Convert pace to speed in meters
    double speedInMetersPerMin =
        1609.34 / paceMinutesPerMile; // meters per minute
    double vo2cost = (CardioConstants.vo2WalkingSpeedMultiplier * speedInMetersPerMin) + CardioConstants.vo2RestingMetabolicRate; // vo2 cost in ml/kg/min

    //use the time at this vo2cost before exhaustion to estimate %VO2max used
    double impliedPercentOfVO2Max = _getVO2MaxPercentageFromTimeRange(
      paceMinutesPerMile.toInt(),
    );

    return vo2cost / (impliedPercentOfVO2Max / 100.0);
  }

  double vo2MaxToMets(double vo2max) {
    return vo2max / CardioConstants.vo2ToMetsConversionFactor;
  }

  double metsToVo2Max(double mets) {
    return mets * CardioConstants.vo2ToMetsConversionFactor;
  }

  /// Estimate fitness percentile from VO2max using ACSM normative data
  double _estimatePercentileFromVO2Max(double vo2max, int age, String gender) {
    // VO2max percentile table data organized by age group and gender
    Map<String, Map<String, List<double>>> percentileData = {
      'male': {
        '20-29': [29.0, 32.1, 40.1, 48.0, 55.2, 61.8, 66.3],
        '30-39': [27.2, 30.2, 35.9, 42.4, 49.2, 56.5, 59.8],
        '40-49': [24.2, 26.8, 31.9, 37.8, 45.0, 52.1, 55.6],
        '50-59': [20.9, 22.8, 27.1, 32.6, 39.7, 45.6, 50.7],
        '60-69': [17.4, 19.8, 23.7, 28.2, 34.5, 40.3, 43.0],
        '70-79': [16.3, 17.1, 20.4, 24.4, 30.4, 36.6, 39.7],
      },
      'female': {
        '20-29': [21.7, 23.9, 30.5, 37.6, 44.7, 51.3, 56.0],
        '30-39': [19.0, 20.9, 25.3, 30.2, 36.1, 41.4, 45.8],
        '40-49': [17.0, 18.8, 22.1, 26.7, 32.4, 38.4, 41.7],
        '50-59': [16.0, 17.3, 19.9, 23.4, 27.6, 32.0, 35.9],
        '60-69': [13.4, 14.6, 17.2, 20.0, 23.8, 27.0, 29.4],
        '70-79': [13.1, 13.6, 15.6, 18.3, 20.8, 23.1, 24.1],
      },
    };

    // Determine age group
    String ageGroup;
    if (age < 30) {
      ageGroup = '20-29';
    } else if (age < 40) {
      ageGroup = '30-39';
    } else if (age < 50) {
      ageGroup = '40-49';
    } else if (age < 60) {
      ageGroup = '50-59';
    } else if (age < 70) {
      ageGroup = '60-69';
    } else {
      ageGroup = '70-79';
    }

    // Get the appropriate percentile data
    List<double>? values = percentileData[gender]?[ageGroup];
    if (values == null) {
      return 50.0; // Default to 50th percentile if data not found
    }

    // Percentiles corresponding to the values: p5, p10, p25, p50, p75, p90, p95
    List<double> percentiles = CardioConstants.percentileValues;

    // Find where the VO2max falls in the range
    for (int i = 0; i < values.length; i++) {
      if (vo2max <= values[i]) {
        if (i == 0) {
          return percentiles[i]; // Below 5th percentile
        }
        // Linear interpolation between percentiles
        double lowerValue = values[i - 1];
        double upperValue = values[i];
        double lowerPercentile = percentiles[i - 1];
        double upperPercentile = percentiles[i];

        double ratio = (vo2max - lowerValue) / (upperValue - lowerValue);
        return lowerPercentile + ratio * (upperPercentile - lowerPercentile);
      }
    }

    // Above 95th percentile
    return 95.0;
  }

  /// Calculate workout parameters including heart rate zones and MET levels
  void _calculateCardioWorkoutParameters(int age, String gender) {
    // Calculate Maximum Heart Rate using Tanaka formula
    // 208 - (0.7 × age) - more accurate than 220-age
    double maxHR = 208 - (0.7 * age);
    featuresMap[CardioConstants.maxHeartRate] = maxHR;

    // Simple 5-zone heart rate system using %MaxHR
    featuresMap[CardioConstants.hrZone1] = maxHR * CardioConstants.hrZone1Multiplier; // Zone 1: Recovery (50-60%)
    featuresMap[CardioConstants.hrZone2] = maxHR * CardioConstants.hrZone2Multiplier; // Zone 2: Aerobic base (60-70%)
    featuresMap[CardioConstants.hrZone3] = maxHR * CardioConstants.hrZone3Multiplier; // Zone 3: Threshold (70-80%)
    featuresMap[CardioConstants.hrZone4] = maxHR * CardioConstants.hrZone4Multiplier; // Zone 4: VO2max (80-90%)
    featuresMap[CardioConstants.hrZone5] = maxHR * CardioConstants.hrZone5Multiplier; // Zone 5: Neuromuscular (90-95%)

    // MET-based training zones
    final mets = featuresMap[CardioConstants.metsCapacity] ?? CardioConstants.defaultMetsCapacity;
    featuresMap[CardioConstants.metZone1] = mets * CardioConstants.metZone1Multiplier; // Recovery
    featuresMap[CardioConstants.metZone2] = mets * CardioConstants.metZone2Multiplier; // Aerobic base
    featuresMap[CardioConstants.metZone3] = mets * CardioConstants.metZone3Multiplier; // Threshold
    featuresMap[CardioConstants.metZone4] = mets * CardioConstants.metZone4Multiplier; // VO2max
    featuresMap[CardioConstants.metZone5] = mets * CardioConstants.metZone5Multiplier; // Neuromuscular

    // Recovery needs based on age (converted to hours for consistency with strength recovery)
    featuresMap['cardio_recovery_hours'] =
        age < AgeThresholds.middleAged ? 24.0 : (age < AgeThresholds.older ? 48.0 : 72.0);
  }
}
