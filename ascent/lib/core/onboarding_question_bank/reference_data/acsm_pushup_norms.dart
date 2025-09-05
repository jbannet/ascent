/// ACSM push-up test norms for fitness assessment.
/// 
/// Based on American College of Sports Medicine guidelines for
/// age and gender-adjusted push-up performance standards.
class ACSMPushupNorms {
  /// Get the percentile rank for a push-up count based on age and gender.
  /// 
  /// Returns a value between 0.0 and 1.0 representing the percentile.
  /// Example: 0.5 = 50th percentile, 0.9 = 90th percentile
  static double getPercentile(int pushUpCount, int age, String gender) {
    final ageGroup = _getAgeGroup(age);
    final genderLower = gender.toLowerCase();
    
    // Get the appropriate norms table
    final norms = genderLower == 'male' ? _maleNorms : _femaleNorms;
    final ageNorms = norms[ageGroup];
    
    if (ageNorms == null) return 0.0;
    
    // Find which percentile bracket this count falls into
    for (final entry in ageNorms.entries) {
      if (pushUpCount >= entry.value) {
        return entry.key / 100.0; // Convert percentile to 0-1 range
      }
    }
    
    return 0.0; // Below all norms
  }
  
  /// Get the equivalent fitness age based on push-up performance
  static int getEquivalentAge(int pushUpCount, int actualAge, String gender) {
    // Find which age group would have this as 50th percentile performance
    final genderLower = gender.toLowerCase();
    final norms = genderLower == 'male' ? _maleNorms : _femaleNorms;
    
    for (final ageGroup in norms.keys) {
      final median = norms[ageGroup]?[50] ?? 0;
      if (pushUpCount >= median) {
        return _ageGroupMidpoint(ageGroup);
      }
    }
    
    return actualAge + 10; // Performance suggests older fitness age
  }
  
  static String _getAgeGroup(int age) {
    if (age < 20) return '18-19';
    if (age < 30) return '20-29';
    if (age < 40) return '30-39';
    if (age < 50) return '40-49';
    if (age < 60) return '50-59';
    return '60+';
  }
  
  static int _ageGroupMidpoint(String ageGroup) {
    switch (ageGroup) {
      case '18-19': return 19;
      case '20-29': return 25;
      case '30-39': return 35;
      case '40-49': return 45;
      case '50-59': return 55;
      case '60+': return 65;
      default: return 35;
    }
  }
  
  // ACSM norms: Map<AgeGroup, Map<Percentile, MinPushUps>>
  // Percentiles from highest (99th) to lowest (10th)
  static const Map<String, Map<int, int>> _maleNorms = {
    '20-29': {
      90: 57,
      75: 44,
      50: 33, // 50th percentile (median)
      25: 24,
      10: 18,
    },
    '30-39': {
      90: 46,
      75: 36,
      50: 27,
      25: 19,
      10: 13,
    },
    '40-49': {
      90: 36,
      75: 29,
      50: 21,
      25: 13,
      10: 9,
    },
    '50-59': {
      90: 30,
      75: 24,
      50: 15,
      25: 9,
      10: 6,
    },
    '60+': {
      90: 26,
      75: 22,
      50: 15,
      25: 7,
      10: 4,
    },
  };
  
  // Female norms (modified push-ups from knees)
  static const Map<String, Map<int, int>> _femaleNorms = {
    '20-29': {
      90: 42,
      75: 34,
      50: 25,
      25: 19,
      10: 12,
    },
    '30-39': {
      90: 36,
      75: 29,
      50: 21,
      25: 14,
      10: 8,
    },
    '40-49': {
      90: 28,
      75: 21,
      50: 15,
      25: 9,
      10: 2,
    },
    '50-59': {
      90: 25,
      75: 20,
      50: 13,
      25: 9,
      10: 1,
    },
    '60+': {
      90: 17,
      75: 15,
      50: 8,
      25: 2,
      10: 0,
    },
  };
}