/// Application constants
class AppConstants {
  /// Hive box names
  static const String questionBoxName = 'questionBox';
  static const String answerBoxName = 'answerBox';
  static const String fitnessProfileBoxName = 'fitnessProfileBox';
  
  /// Hive storage keys
  static const String questionsStorageKey = 'questions';
  static const String answersStorageKey = 'answers';
  static const String fitnessProfileFeaturesKey = 'fitnessProfileFeatures';
  static const String fitnessProfileDemographicsKey = 'fitnessProfileDemographics';
  
  /// Firebase collection names
  static const String onboardingCollectionName = 'onboarding';
  static const String questionsDocumentName = 'questions';

  static const String usersCollectionName = 'users';
  static const String answersDocumentName = 'answers';
  
  /// Version constants
  static const int localStorageUninitialized = -1;
}