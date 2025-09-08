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
  static const String expert = 'expert';
  
  // Fall risk factors (Q4B)
  static const String fearFalling = 'fear_falling';
  static const String mobilityAids = 'mobility_aids';
  static const String balanceProblems = 'balance';
  static const String none = 'none';
  
  // Gender options (gender_question)
  static const String nonBinary = 'non_binary';
  static const String preferNotToSay = 'prefer_not_to_say';
  
  // Activity types (current_activities_question)
  static const String walkingHiking = 'walking_hiking';
  static const String runningJogging = 'running_jogging';
  static const String weightTraining = 'weight_training';
  static const String yoga = 'yoga';
  static const String swimming = 'swimming';
  static const String cycling = 'cycling';
  static const String teamSports = 'team_sports';
  
  // Exertion levels (q3_stairs_question)
  static const String notAtAll = 'not_at_all';
  static const String slightly = 'slightly';
  static const String moderately = 'moderately';
  static const String very = 'very';
  static const String avoid = 'avoid';
  
  // Injury types (q1_injuries_question)
  static const String back = 'back';
  static const String knee = 'knee';
  static const String shoulder = 'shoulder';
  static const String wristAnkle = 'wrist_ankle';
  static const String other = 'other';
  
  // Motivation types (primary_motivation_question)
  static const String physicalChanges = 'physical_changes';
  static const String feelingStronger = 'feeling_stronger';
  static const String performanceGoals = 'performance_goals';
  static const String socialConnection = 'social_connection';
  static const String stressRelief = 'stress_relief';
  static const String healthLongevity = 'health_longevity';
  
  // Progress tracking types (progress_tracking_question)
  static const String photosMeasurements = 'photos_measurements';
  static const String performanceMetrics = 'performance_metrics';
  static const String dailyFeeling = 'daily_feeling';
  static const String habitStreaks = 'habit_streaks';
  static const String milestones = 'milestones';
  
  // Program experience levels (q6_structured_program_question)
  static const String never = 'never';
  static const String once = 'once';
  static const String completedOne = 'completed_one';
  static const String completedFew = 'completed_few';
  static const String experienced = 'experienced';
}