/// Application constants
class AppConstants {
  /// Hive box names
  static const String questionBoxName = 'questionBox';
  static const String answerBoxName = 'answerBox';
  static const String fitnessProfileBoxName = 'fitnessProfileBox';
  static const String planBoxName = 'planBox';
  
  /// Hive storage keys
  static const String questionsStorageKey = 'questions';
  static const String answersStorageKey = 'answers';
  static const String fitnessProfileJsonKey = 'fitnessProfile';
  static const String fitnessProfileFeaturesKey = 'fitnessProfileFeatures';
  static const String fitnessProfileDemographicsKey = 'fitnessProfileDemographics';
  static const String planJsonKey = 'plan';
  
  /// Firebase collection names
  static const String onboardingCollectionName = 'onboarding';
  static const String questionsDocumentName = 'questions';

  static const String usersCollectionName = 'users';
  static const String answersDocumentName = 'answers';
  
  /// Version constants
  static const int localStorageUninitialized = -1;
}

/// Question ID Constants
class QuestionIds {
  // Demographics
  static const String age = 'age';
  static const String gender = 'gender';
  static const String height = 'height';
  static const String weight = 'weight';

  // Motivation
  static const String primaryMotivation = 'primary_motivation';
  static const String progressTracking = 'progress_tracking';

  // Goals
  static const String fitnessGoals = 'fitness_goals';

  // Fitness Assessment
  static const String runWalk = 'Q4';
  static const String fallHistory = 'Q4A';
  static const String fallRiskFactors = 'Q4B';
  static const String pushups = 'Q5';
  static const String squats = 'Q6';
  static const String chairStand = 'Q6A';
  static const String balanceTest = 'Q6B';

  // Lifestyle
  static const String glp1Medications = 'glp1_medications';
  static const String sleepHours = 'sleep_hours';
  static const String currentExerciseDays = 'current_exercise_days';
  static const String stretchingDays = 'stretching_days';
  static const String sedentaryJob = 'sedentary_job';

  // Nutrition
  static const String sugaryTreats = 'sugary_treats';
  static const String sodas = 'sodas';
  static const String grains = 'grains';
  static const String alcohol = 'alcohol';

  // Schedule and Commitment
  static const String sessionCommitment = 'session_commitment';

  // Physical Constraints
  static const String injuries = 'Q1';
  static const String highImpact = 'Q2';
  static const String equipment = 'Q10';
  static const String trainingLocation = 'Q11';
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

  // Run performance data JSON keys (q4_twelve_minute_run_question)
  static const String runDistanceMiles = 'distanceMiles';
  static const String runTimeMinutes = 'timeMinutes';
  static const String runSelectedUnit = 'selectedUnit';
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

/// Body part constants for injury/pain tracking
/// These match the anatomical order used in BodyMapWidget
class BodyPartConstants {
  // Head and neck
  static const String neck = 'neck';

  // Upper body
  static const String shoulders = 'shoulders';
  static const String chest = 'chest';
  static const String lats = 'lats';
  static const String traps = 'traps';
  static const String biceps = 'biceps';
  static const String triceps = 'triceps';
  static const String elbows = 'elbows';
  static const String forearms = 'forearms';
  static const String wrists = 'wrists';

  // Core and back
  static const String abdominals = 'abdominals';
  static const String lowerBack = 'lower_back';

  // Lower body
  static const String hips = 'hips';
  static const String glutes = 'glutes';
  static const String quadriceps = 'quadriceps';
  static const String hamstrings = 'hamstrings';
  static const String knees = 'knees';
  static const String calves = 'calves';
  static const String shins = 'shins';
  static const String ankles = 'ankles';
  static const String feet = 'feet';

  /// All body parts in anatomical order (head to toe)
  static const List<String> allBodyParts = [
    neck, shoulders, chest, lats, traps,
    biceps, triceps, elbows, forearms, wrists,
    abdominals, lowerBack,
    hips, glutes, quadriceps, hamstrings,
    knees, calves, shins, ankles, feet
  ];

  // Scoring constants for injury assessment
  static const int noIssue = 0;
  static const int strengthen = 50; // Positive value for pain areas to strengthen
  static const int maxInt = 9223372036854775807; // Max int for injuries to avoid
  static const int avoid = -maxInt; // Negative max int for injuries
}

/// Workout icon constants
class WorkoutIcons {
  // Icon constants
  static const String heart = '❤️';
  static const String muscle = '💪';
  static const String yoga = '🧘';
  static const String timer = '⏱️';
  static const String fire = '🔥';
  static const String mountain = '⛰️';
  static const String star = '⭐';
  static const String diamond = '💎';
  static const String lightning = '⚡';

  // Training style constants
  static const String fullBody = 'full_body';
  static const String upperLowerSplit = 'upper_lower_split';
  static const String pushPullLegs = 'push_pull_legs';
  static const String concurrentHybrid = 'concurrent_hybrid';
  static const String circuitMetabolic = 'circuit_metabolic';
  static const String enduranceDominant = 'endurance_dominant';
  static const String strongmanFunctional = 'strongman_functional';
  static const String crossfitMixed = 'crossfit_mixed';
  static const String functionalMovement = 'functional_movement';
  static const String yogaFocused = 'yoga_focused';
  static const String seniorSpecific = 'senior_specific';
  static const String pilatesStyle = 'pilates_style';
  static const String athleticConditioning = 'athletic_conditioning';

  // Training style to icon mapping (style is the key)
  static const Map<String, String> styleIcons = {
    fullBody: timer,                    // ⏱️
    upperLowerSplit: muscle,           // 💪
    pushPullLegs: muscle,               // 💪
    concurrentHybrid: timer,             // ⏱️
    circuitMetabolic: fire,              // 🔥
    enduranceDominant: heart,            // ❤️
    strongmanFunctional: mountain,       // ⛰️
    crossfitMixed: timer,                // ⏱️
    functionalMovement: diamond,         // 💎
    yogaFocused: yoga,                   // 🧘
    seniorSpecific: star,                // ⭐
    pilatesStyle: diamond,               // 💎
    athleticConditioning: lightning,     // ⚡
  };

  // Training style display names
  static const Map<String, String> styleDisplayNames = {
    fullBody: 'Full-Body (FB)',
    upperLowerSplit: 'Upper/Lower Split (UL)',
    pushPullLegs: 'Push/Pull/Legs (PPL)',
    concurrentHybrid: 'Concurrent / Hybrid',
    circuitMetabolic: 'Circuit / Metabolic Conditioning',
    enduranceDominant: 'Endurance-Dominant',
    strongmanFunctional: 'Strongman / Functional Strength',
    crossfitMixed: 'CrossFit / Mixed Modal',
    functionalMovement: 'Functional Fitness / Movement Quality',
    yogaFocused: 'Yoga-Focused',
    seniorSpecific: 'Senior-Specific',
    pilatesStyle: 'Pilates Style',
    athleticConditioning: 'Athletic Conditioning',
  };

  // Category to training styles mapping
  static const Map<String, List<String>> categoryToStyles = {
    'cardio': [enduranceDominant, circuitMetabolic, athleticConditioning, concurrentHybrid],
    'strength': [upperLowerSplit, pushPullLegs, concurrentHybrid, fullBody, yogaFocused, pilatesStyle],
    'balance': [seniorSpecific, functionalMovement, yogaFocused],
    'flexibility': [yogaFocused, pilatesStyle],
    'functional': [functionalMovement, seniorSpecific],
  };
}

/// Workout duration constants
class WorkoutDuration {
  /// Percentage of total workout for warmup (15%)
  static const double warmupPercent = 0.15;

  /// Percentage of total workout for cooldown (12%)
  static const double cooldownPercent = 0.12;

  /// Percentage of total workout for main work (73%)
  static const double mainWorkPercent = 0.73;
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
