class RouteNames {
  static const String onboarding = '/';
  static const String plan = '/plan';
  static const String exercise = '/exercise/:exerciseId';
  
  static String planPath() => '/plan';
  
  
  static String exercisePath(String exerciseId) => 
      '/exercise/$exerciseId';
}