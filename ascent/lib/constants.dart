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

/// Question Answer Constants
class AnswerConstants {
  // Gender options
  static const String male = 'male';
  static const String female = 'female';
  
  // Yes/No options
  static const String yes = 'yes';
  static const String no = 'no';
  
  // Experience level options
  static const String beginner = 'beginner';
  static const String intermediate = 'intermediate';
  static const String advanced = 'advanced';
  
  // Fall risk factors (Q4B)
  static const String fearFalling = 'fear_falling';
  static const String mobilityAids = 'mobility_aids';
  static const String balanceProblems = 'balance';
  static const String none = 'none';
}