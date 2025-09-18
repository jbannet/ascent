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
  
  // Fitness goals (fitness_goals_question)
  static const String loseWeight = 'lose_weight';
  static const String buildMuscle = 'build_muscle';
  static const String improveEndurance = 'improve_endurance';
  static const String increaseFlexibility = 'increase_flexibility';
  static const String betterHealth = 'better_health';
  static const String liveLonger = 'live_longer';
  
  // Q7 Free weights comfort levels
  static const String neverUsed = 'never_used';
  static const String triedFew = 'tried_few';
  static const String somewhat = 'somewhat';
  static const String comfortable = 'comfortable';
  static const String veryExperienced = 'very_experienced';
  
  // Workout duration options
  static const String duration15_30 = '15_30';
  static const String duration30_45 = '30_45';
  static const String duration45_60 = '45_60';
  static const String duration60Plus = '60_plus';
  
  // Diet quality levels
  static const String veryHealthy = 'very_healthy';
  static const String mostlyHealthy = 'mostly_healthy';
  static const String average = 'average';
  static const String needsImprovement = 'needs_improvement';
  static const String poor = 'poor';
  
  // Medical restriction types (Q2)
  static const String highImpact = 'high_impact';
  static const String heavyLifting = 'heavy_lifting';
  static const String overhead = 'overhead';
  static const String twisting = 'twisting';
  static const String cardioIntense = 'cardio_intense';
  
  // Equipment types (Q10)
  static const String dumbbells = 'dumbbells';
  static const String resistanceBands = 'resistance_bands';
  static const String barbell = 'barbell';
  static const String cableMachine = 'cable_machine';
  static const String cardioMachines = 'cardio_machines';
  static const String fullGym = 'full_gym';
  
  // Training location preferences (Q11)
  static const String homeOnly = 'home_only';
  static const String gymOnly = 'gym_only';
  static const String preferHome = 'prefer_home';
  static const String preferGym = 'prefer_gym';
  static const String outdoors = 'outdoors';
  static const String anywhere = 'anywhere';
  
  // Cooper test and fall risk thresholds
  static const double cooperAtRiskMiles = 0.36; // 576m = at-risk for mobility limitation (Shirley Ryan AbilityLab)
  static const int fallRiskAge = 65; // Age threshold for fall risk assessment
}

/// Fitness Plan JSON field names
class PlanFields {
  // Plan fields
  static const String scheduleField = 'schedule';
  static const String planProgressField = 'plan_progress';

  // FourWeeks fields
  static const String currentWeekField = 'current_week';
  static const String nextWeeksField = 'next_weeks';

  // WeekOfWorkouts fields
  static const String weekIndexField = 'week_index';
  static const String startDateField = 'start_date';
  static const String workoutsField = 'workouts';

  // PlanProgress fields
  static const String completedWeeksField = 'completed_weeks';

  // Workout fields
  static const String dateField = 'date';
  static const String typeField = 'type';
  static const String styleField = 'style';
  static const String isCompletedField = 'is_completed';
}