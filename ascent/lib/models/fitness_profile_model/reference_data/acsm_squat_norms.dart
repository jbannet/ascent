import 'age_group_utility.dart';

/// Bodyweight squat test norms for fitness assessment.
/// 
/// Based on functional fitness standards and research from:
/// - NSCA (National Strength and Conditioning Association) guidelines
/// - ACE (American Council on Exercise) fitness standards
/// - Functional movement screening research
/// 
/// These norms assess lower body strength endurance through
/// continuous bodyweight squats with proper form.
class ACSMSquatNorms {
  /// Get the percentile rank for a squat count based on age and gender.
  /// 
  /// Returns a value between 0.0 and 1.0 representing the percentile.
  /// Example: 0.5 = 50th percentile, 0.9 = 90th percentile
  static double getPercentile(int squatCount, int age, String gender) {
    final ageGroup = _getAgeGroup(age);
    final genderLower = gender.toLowerCase();
    
    // Get the appropriate norms table
    final norms = genderLower == 'male' ? _maleNorms : _femaleNorms;
    final ageNorms = norms[ageGroup];
    
    if (ageNorms == null) return 0.0;
    
    // Find which percentile bracket this count falls into
    for (final entry in ageNorms.entries) {
      if (squatCount >= entry.value) {
        return entry.key / 100.0; // Convert percentile to 0-1 range
      }
    }
    
    return 0.0; // Below all norms
  }
  
  /// Get the equivalent fitness age based on squat performance
  static int getEquivalentAge(int squatCount, int actualAge, String gender) {
    // Find which age group would have this as 50th percentile performance
    final genderLower = gender.toLowerCase();
    final norms = genderLower == 'male' ? _maleNorms : _femaleNorms;
    
    for (final ageGroup in norms.keys) {
      final median = norms[ageGroup]?[50] ?? 0;
      if (squatCount >= median) {
        return AgeGroupUtility.getAgeGroupMidpoint(ageGroup);
      }
    }
    
    return actualAge + 10; // Performance suggests older fitness age
  }
  
  /// Get appropriate age group for norms lookup
  static String _getAgeGroup(int age) {
    if (age < 30) return '20-29';
    if (age < 40) return '30-39';
    if (age < 50) return '40-49';
    if (age < 60) return '50-59';
    return '60+';
  }
  
  // Squat norms: Map<AgeGroup, Map<Percentile, MinSquats>>
  // Based on continuous bodyweight squats with proper form
  // Percentiles from highest (90th) to lowest (10th)
  static const Map<String, Map<int, int>> _maleNorms = {
    '20-29': {
      90: 50,  // Excellent
      75: 40,  // Good
      50: 30,  // Average (median)
      25: 22,  // Below average
      10: 15,  // Poor
    },
    '30-39': {
      90: 45,
      75: 35,
      50: 27,
      25: 20,
      10: 12,
    },
    '40-49': {
      90: 40,
      75: 30,
      50: 22,
      25: 16,
      10: 10,
    },
    '50-59': {
      90: 35,
      75: 25,
      50: 18,
      25: 12,
      10: 8,
    },
    '60+': {
      90: 30,
      75: 20,
      50: 15,
      25: 10,
      10: 5,
    },
  };
  
  // Female norms (typically slightly lower due to muscle mass differences)
  static const Map<String, Map<int, int>> _femaleNorms = {
    '20-29': {
      90: 45,  // Excellent
      75: 35,  // Good
      50: 27,  // Average (median)
      25: 20,  // Below average
      10: 12,  // Poor
    },
    '30-39': {
      90: 40,
      75: 30,
      50: 23,
      25: 17,
      10: 10,
    },
    '40-49': {
      90: 35,
      75: 25,
      50: 18,
      25: 13,
      10: 8,
    },
    '50-59': {
      90: 30,
      75: 20,
      50: 15,
      25: 10,
      10: 6,
    },
    '60+': {
      90: 25,
      75: 17,
      50: 12,
      25: 8,
      10: 4,
    },
  };
  
  /// Get fitness category label for a given percentile
  static String getFitnessCategory(double percentile) {
    if (percentile >= 0.9) return 'Excellent';
    if (percentile >= 0.75) return 'Good';
    if (percentile >= 0.5) return 'Average';
    if (percentile >= 0.25) return 'Below Average';
    return 'Needs Improvement';
  }
  
  /// Check if someone needs functional strength training
  /// Based on ability to perform basic functional movements
  static bool needsFunctionalTraining(int squatCount, int age) {
    // Basic functional threshold: ~10-15 squats for most ages
    // This indicates ability to rise from chairs, stairs, etc.
    if (age < 50) {
      return squatCount < 15;
    } else if (age < 70) {
      return squatCount < 10;
    } else {
      return squatCount < 5;
    }
  }
}