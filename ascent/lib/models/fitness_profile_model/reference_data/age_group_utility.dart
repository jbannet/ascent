/// Utility class for age group categorization used across different fitness assessments.
/// 
/// Provides standardized age group lookups to avoid code duplication across
/// various fitness norm classes (ACSM cardio, pushup, etc.)
class AgeGroupUtility {
  
  /// Standard ACSM age groups used for cardio and general fitness norms
  static String getStandardAgeGroup(int age) {
    if (age < 30) return '20-29';
    if (age < 40) return '30-39';
    if (age < 50) return '40-49';
    if (age < 60) return '50-59';
    if (age < 70) return '60-69';
    return '70+';
  }
  
  /// Extended age groups used for pushup norms (includes 18-19 bracket)
  static String getPushupAgeGroup(int age) {
    if (age < 20) return '18-19';
    if (age < 30) return '20-29';
    if (age < 40) return '30-39';
    if (age < 50) return '40-49';
    if (age < 60) return '50-59';
    return '60+';
  }
  
  /// Get the midpoint age for a given age group string
  /// Useful for fitness age calculations
  static int getAgeGroupMidpoint(String ageGroup) {
    switch (ageGroup) {
      case '18-19': return 19;
      case '20-29': return 25;
      case '30-39': return 35;
      case '40-49': return 45;
      case '50-59': return 55;
      case '60-69': return 65;
      case '60+': return 65;
      case '70+': return 75;
      default: return 35; // Fallback to mid-adult age
    }
  }
}