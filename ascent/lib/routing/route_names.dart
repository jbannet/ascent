class RouteNames {
  static const String onboarding = '/';
  static const String plan = '/plan';
  static const String week = '/plan/week/:weekIndex';
  static const String day = '/plan/week/:weekIndex/day/:dayName';
  static const String block = '/plan/week/:weekIndex/day/:dayName/block/:blockIndex';
  static const String exercise = '/exercise/:exerciseId';
  
  static String planPath() => '/plan';
  
  static String weekPath(int weekIndex) =>
      '/plan/week/$weekIndex';

  static String dayPath(int weekIndex, String dayName) =>
      '/plan/week/$weekIndex/day/$dayName';

  static String blockPath(int weekIndex, String dayName, int blockIndex) =>
      '/plan/week/$weekIndex/day/$dayName/block/$blockIndex';
  
  static String exercisePath(String exerciseId) => 
      '/exercise/$exerciseId';
}