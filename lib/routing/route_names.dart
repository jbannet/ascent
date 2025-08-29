class RouteNames {
  static const String onboarding = '/';
  static const String plan = '/plan';
  static const String week = '/plan/:planId/week/:weekIndex';
  static const String day = '/plan/:planId/week/:weekIndex/day/:dayName';
  static const String block = '/plan/:planId/week/:weekIndex/day/:dayName/block/:blockIndex';
  static const String exercise = '/exercise/:exerciseId';
  
  static String planPath() => '/plan';
  
  static String weekPath(String planId, int weekIndex) => 
      '/plan/$planId/week/$weekIndex';
  
  static String dayPath(String planId, int weekIndex, String dayName) => 
      '/plan/$planId/week/$weekIndex/day/$dayName';
  
  static String blockPath(String planId, int weekIndex, String dayName, int blockIndex) => 
      '/plan/$planId/week/$weekIndex/day/$dayName/block/$blockIndex';
  
  static String exercisePath(String exerciseId) => 
      '/exercise/$exerciseId';
}