/// ACSM (American College of Sports Medicine) cardiovascular fitness norms
/// based on 12-minute run/walk test distances.
/// 
/// These norms provide age and gender-specific percentiles for cardiovascular fitness
/// assessment based on distance covered in 12 minutes.
class ACSMCardioNorms {
  
  // Distance ranges in meters for different fitness levels
  // Based on ACSM's Guidelines for Exercise Testing and Prescription
  
  static const Map<String, Map<String, List<double>>> _fitnessNorms = {
    'male': {
      '20-29': [1600, 2000, 2400, 2800, 3200], // Very Poor to Superior
      '30-39': [1500, 1900, 2300, 2700, 3100],
      '40-49': [1400, 1800, 2200, 2600, 3000],
      '50-59': [1300, 1700, 2100, 2500, 2900],
      '60-69': [1200, 1600, 2000, 2400, 2800],
      '70+': [1100, 1500, 1900, 2300, 2700],
    },
    'female': {
      '20-29': [1500, 1800, 2200, 2600, 3000],
      '30-39': [1400, 1700, 2100, 2500, 2900],
      '40-49': [1300, 1600, 2000, 2400, 2800],
      '50-59': [1200, 1500, 1900, 2300, 2700],
      '60-69': [1100, 1400, 1800, 2200, 2600],
      '70+': [1000, 1300, 1700, 2100, 2500],
    },
  };
  
  /// Get cardiovascular fitness percentile for a given distance
  /// 
  /// [distance] - Distance covered in 12 minutes (meters)
  /// [age] - Person's age in years
  /// [gender] - 'male' or 'female'
  /// 
  /// Returns percentile from 0.0 (very poor) to 1.0 (superior)
  static double getPercentile(double distance, int age, String gender) {
    final normalizedGender = gender.toLowerCase();
    if (!_fitnessNorms.containsKey(normalizedGender)) {
      return 0.5; // Default if gender not recognized
    }
    
    final ageGroup = _getAgeGroup(age);
    final norms = _fitnessNorms[normalizedGender]![ageGroup];
    
    if (norms == null) return 0.5; // Fallback
    
    // Find where the distance falls in the norm ranges
    if (distance <= norms[0]) {
      // Very Poor (0-20th percentile)
      return (distance / norms[0]) * 0.2;
    } else if (distance <= norms[1]) {
      // Poor (20-40th percentile)
      final progress = (distance - norms[0]) / (norms[1] - norms[0]);
      return 0.2 + (progress * 0.2);
    } else if (distance <= norms[2]) {
      // Fair (40-60th percentile)
      final progress = (distance - norms[1]) / (norms[2] - norms[1]);
      return 0.4 + (progress * 0.2);
    } else if (distance <= norms[3]) {
      // Good (60-80th percentile)
      final progress = (distance - norms[2]) / (norms[3] - norms[2]);
      return 0.6 + (progress * 0.2);
    } else if (distance <= norms[4]) {
      // Excellent (80-95th percentile)
      final progress = (distance - norms[3]) / (norms[4] - norms[3]);
      return 0.8 + (progress * 0.15);
    } else {
      // Superior (95th+ percentile)
      // Cap at 1.0 but allow some scaling beyond the norm
      final extraDistance = distance - norms[4];
      final bonus = (extraDistance / norms[4]) * 0.05;
      return (0.95 + bonus).clamp(0.95, 1.0);
    }
  }
  
  /// Get fitness category label for a given percentile
  static String getFitnessCategory(double percentile) {
    if (percentile < 0.2) return 'Very Poor';
    if (percentile < 0.4) return 'Poor';
    if (percentile < 0.6) return 'Fair';
    if (percentile < 0.8) return 'Good';
    if (percentile < 0.95) return 'Excellent';
    return 'Superior';
  }
  
  /// Get expected distance range for age/gender
  static Map<String, double> getExpectedRange(int age, String gender) {
    final normalizedGender = gender.toLowerCase();
    if (!_fitnessNorms.containsKey(normalizedGender)) {
      return {'min': 1000.0, 'average': 2000.0, 'max': 3000.0};
    }
    
    final ageGroup = _getAgeGroup(age);
    final norms = _fitnessNorms[normalizedGender]![ageGroup]!;
    
    return {
      'very_poor': norms[0],
      'poor': norms[1],
      'fair': norms[2], // This is typically the average
      'good': norms[3],
      'excellent': norms[4],
    };
  }
  
  /// Convert distance to estimated VO2 max (ml/kg/min)
  /// Using Cooper's 12-minute run test formula
  static double estimateVO2Max(double distanceMeters) {
    // Cooper formula: VO2 max = (distance in meters - 505) / 45
    final vo2Max = (distanceMeters - 505) / 45;
    return vo2Max.clamp(15.0, 80.0); // Reasonable physiological limits
  }
  
  /// Get appropriate age group for norms lookup
  static String _getAgeGroup(int age) {
    if (age < 30) return '20-29';
    if (age < 40) return '30-39';
    if (age < 50) return '40-49';
    if (age < 60) return '50-59';
    if (age < 70) return '60-69';
    return '70+';
  }
}