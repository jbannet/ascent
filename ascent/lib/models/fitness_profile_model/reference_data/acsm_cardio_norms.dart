/// Cooper 12-minute run test cardiovascular fitness norms
/// based on verified Cooper Institute data.
///
/// These norms provide age and gender-specific percentile estimates for cardiovascular fitness
/// assessment based on distance covered in 12 minutes.
/// Data source: Cooper Institute norm tables and ACSM guidelines
class ACSMCardioNorms {
  // Distance norms in miles for verified fitness category boundaries
  // Based on Cooper Institute published norm tables

  static const Map<String, Map<String, Map<int, double>>> _fitnessNorms = {
    'male': {
      '20-29': {
        10: 0.99, // Very Poor/Poor boundary (<1600m)
        30: 1.37, // Poor/Fair boundary (2200m)
        50: 1.49, // Fair/Good boundary (2400m)
        70: 1.74, // Good/Excellent boundary (2800m)
        90: 1.99, // Excellent threshold (3200m)
      },
      '30-39': {
        10: 0.93, // Very Poor/Poor boundary (<1500m)
        30: 1.18, // Poor/Fair boundary (1900m)
        50: 1.43, // Fair/Good boundary (2300m)
        70: 1.68, // Good/Excellent boundary (2700m)
        90: 1.93, // Excellent threshold (3100m)
      },
      '40-49': {
        10: 0.87, // Very Poor/Poor boundary (<1400m)
        30: 1.06, // Poor/Fair boundary (1700m)
        50: 1.30, // Fair/Good boundary (2100m)
        70: 1.55, // Good/Excellent boundary (2500m)
        90: 1.86, // Excellent threshold (3000m)
      },
      '50-59': {
        10: 0.81, // Very Poor/Poor boundary (<1300m)
        30: 0.99, // Poor/Fair boundary (1600m)
        50: 1.24, // Fair/Good boundary (2000m)
        70: 1.49, // Good/Excellent boundary (2400m)
        90: 1.80, // Excellent threshold (2900m)
      },
      '60-69': {
        10: 0.75, // Very Poor/Poor boundary (<1200m)
        30: 0.99, // Poor/Fair boundary (1600m)
        50: 1.24, // Fair/Good boundary (2000m)
        70: 1.49, // Good/Excellent boundary (2400m)
        90: 1.74, // Excellent threshold (2800m)
      },
      '70+': {
        10: 0.68, // Very Poor/Poor boundary (<1100m)
        30: 0.93, // Poor/Fair boundary (1500m)
        50: 1.18, // Fair/Good boundary (1900m)
        70: 1.43, // Good/Excellent boundary (2300m)
        90: 1.68, // Excellent threshold (2700m)
      },
    },
    'female': {
      '20-29': {
        10: 0.93, // Very Poor/Poor boundary (<1500m)
        30: 1.12, // Poor/Fair boundary (1800m)
        50: 1.37, // Fair/Good boundary (2200m)
        70: 1.68, // Good/Excellent boundary (2700m)
        90: 1.86, // Excellent threshold (3000m)
      },
      '30-39': {
        10: 0.87, // Very Poor/Poor boundary (<1400m)
        30: 1.06, // Poor/Fair boundary (1700m)
        50: 1.24, // Fair/Good boundary (2000m)
        70: 1.55, // Good/Excellent boundary (2500m)
        90: 1.80, // Excellent threshold (2900m)
      },
      '40-49': {
        10: 0.75, // Very Poor/Poor boundary (<1200m)
        30: 0.93, // Poor/Fair boundary (1500m)
        50: 1.18, // Fair/Good boundary (1900m)
        70: 1.43, // Good/Excellent boundary (2300m)
        90: 1.74, // Excellent threshold (2800m)
      },
      '50-59': {
        10: 0.68, // Very Poor/Poor boundary (<1100m)
        30: 0.87, // Poor/Fair boundary (1400m)
        50: 1.06, // Fair/Good boundary (1700m)
        70: 1.37, // Good/Excellent boundary (2200m)
        90: 1.68, // Excellent threshold (2700m)
      },
      '60-69': {
        10: 0.68, // Very Poor/Poor boundary (<1100m)
        30: 0.87, // Poor/Fair boundary (1400m)
        50: 1.12, // Fair/Good boundary (1800m)
        70: 1.37, // Good/Excellent boundary (2200m)
        90: 1.62, // Excellent threshold (2600m)
      },
      '70+': {
        10: 0.62, // Very Poor/Poor boundary (<1000m)
        30: 0.81, // Poor/Fair boundary (1300m)
        50: 1.06, // Fair/Good boundary (1700m)
        70: 1.30, // Good/Excellent boundary (2100m)
        90: 1.55, // Excellent threshold (2500m)
      },
    },
  };

  /// Get cardiovascular fitness percentile for a given distance
  ///
  /// [distanceMiles] - Distance covered in 12 minutes (miles)
  /// [age] - Person's age in years
  /// [gender] - 'male' or 'female'
  ///
  /// Returns percentile from 0.0 (very poor) to 100.0 (superior)
  static double getPercentile(double distanceMiles, int age, String gender) {
    final normalizedGender = gender.toLowerCase();
    if (!_fitnessNorms.containsKey(normalizedGender)) {
      return 50.0; // Default if gender not recognized
    }

    final ageGroup = _getAgeGroup(age);
    final percentileData = _fitnessNorms[normalizedGender]![ageGroup];

    if (percentileData == null) return 50.0; // Fallback

    // Handle distances below 10th percentile
    if (distanceMiles <= percentileData[10]!) {
      final ratio = distanceMiles / percentileData[10]!;
      return (ratio * 10.0).clamp(0.0, 10.0);
    }

    // Handle distances above 90th percentile
    if (distanceMiles >= percentileData[90]!) {
      final extraDistance = distanceMiles - percentileData[90]!;
      final bonus = (extraDistance / percentileData[90]!) * 0.10;
      return (90.0 + bonus).clamp(90.0, 100.0);
    }

    // Find the two adjacent percentiles and interpolate
    final percentiles = percentileData.keys.toList()..sort();

    for (int i = 0; i < percentiles.length - 1; i++) {
      final lowerP = percentiles[i];
      final upperP = percentiles[i + 1];
      final lowerDistance = percentileData[lowerP]!;
      final upperDistance = percentileData[upperP]!;

      if (distanceMiles >= lowerDistance && distanceMiles <= upperDistance) {
        final progress =
            (distanceMiles - lowerDistance) / (upperDistance - lowerDistance);
        final lowerPercentile = lowerP.toDouble();
        final upperPercentile = upperP.toDouble();
        return lowerPercentile +
            (progress * (upperPercentile - lowerPercentile));
      }
    }

    return 50.0; // Fallback
  }

  /// Get fitness category label for a given percentile
  static String getFitnessCategory(double percentile) {
    if (percentile < 20) return 'Very Poor';
    if (percentile < 40) return 'Poor';
    if (percentile < 60) return 'Fair';
    if (percentile < 80) return 'Good';
    if (percentile < 95) return 'Excellent';
    return 'Superior';
  }

  /// Get expected distance range for age/gender in miles
  static Map<String, double> getExpectedRange(int age, String gender) {
    final normalizedGender = gender.toLowerCase();
    if (!_fitnessNorms.containsKey(normalizedGender)) {
      return {
        '10th_percentile': 0.8,
        '50th_percentile': 1.2,
        '90th_percentile': 1.6,
      };
    }

    final ageGroup = _getAgeGroup(age);
    final percentileData = _fitnessNorms[normalizedGender]![ageGroup]!;

    return {
      '10th_percentile': percentileData[10]!,
      '30th_percentile': percentileData[30]!,
      '50th_percentile': percentileData[50]!,
      '70th_percentile': percentileData[70]!,
      '90th_percentile': percentileData[90]!,
    };
  }

  /// Convert distance to estimated VO2 max (ml/kg/min)
  /// Using Cooper's 12-minute run test formula adapted for miles
  static double estimateVO2Max(double distanceMiles) {
    // Cooper formula adapted for miles: VO2 max = ((miles * 1609.34) - 505) / 45
    // Simplifying: VO2 max = (miles * 35.76) - 11.22
    final vo2Max = (distanceMiles * 35.76) - 11.22;
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
