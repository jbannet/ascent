import 'age_group_utility.dart';

/// ACSM push-up test norms for fitness assessment.
///
/// Based on American College of Sports Medicine guidelines for
/// age and gender-adjusted push-up performance standards.
class ACSMPushupNorms {
  /// Get the percentile rank for a push-up count based on age and gender.
  ///
  /// Returns a value between 0 and 100 representing the percentile.
  /// Example: 50 = 50th percentile, 90 = 90th percentile
  static double getPercentile(int pushUpCount, int age, String gender) {
    final ageGroup = AgeGroupUtility.getPushupAgeGroup(age);
    final genderLower = gender.toLowerCase();

    final norms = genderLower == 'male' ? _maleNorms : _femaleNorms;
    final ageNorms = norms[ageGroup];

    if (ageNorms == null || ageNorms.isEmpty) {
      return 0.0;
    }

    final value = pushUpCount.toDouble();
    final entries =
        ageNorms.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

    final lowest = entries.first;
    final highest = entries.last;

    if (value <= lowest.value) {
      if (lowest.value <= 0) return 0.0;
      final ratio = (value / lowest.value).clamp(0.0, 1.0);
      return (ratio * lowest.key).clamp(0.0, lowest.key.toDouble());
    }

    for (var i = 0; i < entries.length - 1; i++) {
      final lower = entries[i];
      final upper = entries[i + 1];
      if (value <= upper.value) {
        final span = upper.value - lower.value;
        if (span <= 0) {
          return upper.key.toDouble();
        }
        final progress = (value - lower.value) / span;
        final percentileSpan = (upper.key - lower.key).toDouble();
        final percentile = lower.key + progress * percentileSpan;
        return percentile.clamp(
          lower.key.toDouble(),
          upper.key.toDouble(),
        );
      }
    }

    final prev = entries[entries.length - 2];
    final span = highest.value - prev.value;
    if (span <= 0) {
      return highest.key.toDouble().clamp(0.0, 100.0);
    }
    final percentileSpan = (highest.key - prev.key).toDouble();
    final progress = (value - highest.value) / span;
    final estimated = highest.key + progress * percentileSpan;
    return estimated.clamp(highest.key.toDouble(), 100.0);
  }

  /// Get the equivalent fitness age based on push-up performance
  static int getEquivalentAge(int pushUpCount, int actualAge, String gender) {
    // Find which age group would have this as 50th percentile performance
    final genderLower = gender.toLowerCase();
    final norms = genderLower == 'male' ? _maleNorms : _femaleNorms;

    for (final ageGroup in norms.keys) {
      final median = norms[ageGroup]?[50] ?? 0;
      if (pushUpCount >= median) {
        return AgeGroupUtility.getAgeGroupMidpoint(ageGroup);
      }
    }

    return actualAge + 10; // Performance suggests older fitness age
  }

  // ACSM norms: Map<AgeGroup, Map<Percentile, MinPushUps>>
  // Percentiles from highest (99th) to lowest (10th)
  static const Map<String, Map<int, double>> _maleNorms = {
    '20-29': {
      99: 101,
      95: 62,
      90: 57,
      85: 51,
      80: 47,
      75: 44,
      70: 41,
      65: 39,
      60: 37,
      55: 35,
      50: 33,
      45: 31,
      40: 29,
      35: 27,
      30: 26,
      25: 24,
      20: 22,
      15: 20,
      10: 18,
      5: 13,
    },
    '30-39': {
      99: 87,
      95: 52,
      90: 46,
      85: 41,
      80: 39,
      75: 36,
      70: 34,
      65: 31,
      60: 30,
      55: 27,
      50: 25,
      45: 23,
      40: 21,
      35: 20,
      30: 19,
      25: 17,
      20: 15,
      15: 13,
      10: 10,
      5: 9,
    },
    '40-49': {
      99: 65,
      95: 40,
      90: 36,
      85: 34,
      80: 30,
      75: 29,
      70: 26,
      65: 25,
      60: 24,
      55: 22,
      50: 21,
      45: 19,
      40: 18,
      35: 16,
      30: 15,
      25: 14,
      20: 11,
      15: 10,
      10: 9,
      5: 5,
    },
    '50-59': {
      99: 52,
      95: 39,
      90: 30,
      85: 28,
      80: 25,
      75: 24,
      70: 21,
      65: 20,
      60: 19,
      55: 17,
      50: 15,
      45: 15,
      40: 13,
      35: 11,
      30: 10,
      25: 9,
      20: 9,
      15: 7,
      10: 6,
      5: 3,
    },
    '60+': {
      99: 40,
      95: 28,
      90: 26,
      85: 24,
      80: 23,
      75: 22,
      70: 20,
      65: 20,
      60: 18,
      55: 16,
      50: 15,
      45: 14,
      40: 13,
      35: 11,
      30: 10,
      25: 9,
      20: 5,
      15: 4,
      10: 3,
      5: 2,
    },
  };

  static const Map<String, Map<int, double>> _femaleNorms = {
    '20-29': {
      99: 71,
      95: 45,
      90: 42,
      85: 39,
      80: 36,
      75: 34,
      70: 32,
      65: 30,
      60: 26,
      55: 24,
      50: 22,
      45: 21,
      40: 20,
      35: 18,
      30: 17,
      25: 16,
      20: 15,
      15: 14,
      10: 12,
      5: 9,
    },
    '30-39': {
      99: 57,
      95: 39,
      90: 32,
      85: 30,
      80: 31,
      75: 29,
      70: 28,
      65: 24,
      60: 23,
      55: 21,
      50: 19,
      45: 17,
      40: 16,
      35: 15,
      30: 13,
      25: 10,
      20: 9,
      15: 8,
      10: 6,
      5: 4,
    },
    '40-49': {
      99: 51,
      95: 33,
      90: 28,
      85: 24,
      80: 24,
      75: 22,
      70: 20,
      65: 18,
      60: 17,
      55: 16,
      50: 15,
      45: 13,
      40: 12,
      35: 11,
      30: 10,
      25: 9,
      20: 8,
      15: 7,
      10: 4,
      5: 2,
    },
    '50-59': {
      99: 32,
      95: 28,
      90: 25,
      85: 23,
      80: 21,
      75: 20,
      70: 19,
      65: 17,
      60: 16,
      55: 15,
      50: 13,
      45: 12,
      40: 11,
      35: 10,
      30: 9,
      25: 8,
      20: 7,
      15: 6,
      10: 2,
      5: 1,
    },
    '60+': {
      99: 21,
      95: 17,
      90: 17,
      85: 15,
      80: 15,
      75: 14,
      70: 13,
      65: 12,
      60: 11,
      55: 10,
      50: 9,
      45: 8,
      40: 7,
      35: 6,
      30: 5,
      25: 4,
      20: 3,
      15: 2,
      10: 1,
      5: 0,
    },
  };
}
