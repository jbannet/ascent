import 'onboarding_personas_test.dart';

/// 25 diverse personas for testing onboarding flow distribution
class PersonaDefinitions {

  static List<PersonaTestCase> getAllPersonas() {
    return [
      // CRITICAL MEDICAL CONDITIONS (5)
      elderlyWithFallHistory(),
      cannotStandFromChair(),
      glp1WithObesity(),
      extremeObesity(),
      multipleConditions(),

      // AGE-BASED PROFILES (5)
      youngAthlete(),
      middleAgedBeginner(),
      activeSenior(),
      frailElderly(),
      teenStarter(),

      // FITNESS LEVEL VARIANTS (5)
      deconditionedAdult(),
      weekendWarrior(),
      formerAthlete(),
      yogaPractitioner(),
      marathonRunner(),

      // HEALTH CONDITIONS (5)
      postSurgeryRecovery(),
      chronicBackPain(),
      diabetesType2(),
      underweight(),
      postpartum(),

      // LIFESTYLE VARIANTS (5)
      busyExecutive(),
      nightShiftWorker(),
      homeBoundParent(),
      retiree(),
      collegeStudent(),
    ];
  }

  // CRITICAL MEDICAL CONDITIONS

  static PersonaTestCase elderlyWithFallHistory() {
    return PersonaTestCase(
      personaId: 'elderly_fall_history',
      description: '75-year-old with fall history and poor balance',
      answers: {
        'age': '1949-01-15',
        'gender': 'female',
        'height_cm': 162.0,
        'weight_kg': 65.0,
        'primary_motivation': 'better_health',
        'progress_tracking': 'weekly_check_ins',
        'fitness_goals': ['better_health', 'live_longer'],
        'Q4': 0.3, // Very poor 12-min run
        'Q4A': 'yes', // Fall history
        'Q4B': ['medication', 'vision'], // Risk factors
        'Q5': 0.0, // No pushups
        'Q6A': 'yes', // Can stand from chair (barely)
        'glp1_medications': 'no',
        'sleep_hours': 7.0,
        'sugary_treats': 'rarely',
        'sodas': 'never',
        'grains': 'sometimes',
        'alcohol': 'never',
        'session_commitment': 'low',
        'Q1': 'none',
        'Q2': 'avoid',
        'Q10': 'none',
        'Q11': 'home',
      },
      metadata: {
        'category': 'critical_medical',
        'expected_protocol': 'fall_history',
      },
    );
  }

  static PersonaTestCase cannotStandFromChair() {
    return PersonaTestCase(
      personaId: 'cannot_stand_chair',
      description: '68-year-old with severe deconditioning, cannot stand from chair',
      answers: {
        'age': '1956-06-20',
        'gender': 'male',
        'height_cm': 175.0,
        'weight_kg': 85.0,
        'primary_motivation': 'better_health',
        'progress_tracking': 'monthly_check_ins',
        'fitness_goals': ['better_health'],
        'Q4': 0.1, // Cannot complete run
        'Q4A': 'no', // No fall history
        'Q4B': [], // No risk factors
        'Q5': 0.0, // No pushups
        'Q6A': 'no', // Cannot stand from chair
        'glp1_medications': 'no',
        'sleep_hours': 8.0,
        'sugary_treats': 'sometimes',
        'sodas': 'rarely',
        'grains': 'often',
        'alcohol': 'rarely',
        'session_commitment': 'very_low',
        'Q1': 'knee',
        'Q2': 'avoid',
        'Q10': 'none',
        'Q11': 'home',
      },
      metadata: {
        'category': 'critical_medical',
        'expected_protocol': 'chair_stand_failure',
      },
    );
  }

  static PersonaTestCase glp1WithObesity() {
    return PersonaTestCase(
      personaId: 'glp1_obesity',
      description: '45-year-old on GLP-1 medication with obesity',
      answers: {
        'age': '1979-03-10',
        'gender': 'female',
        'height_cm': 165.0,
        'weight_kg': 95.0, // BMI ~35
        'primary_motivation': 'lose_weight',
        'progress_tracking': 'weekly_check_ins',
        'fitness_goals': ['lose_weight', 'better_health'],
        'Q4': 0.6, // Poor cardio
        'Q4A': 'no',
        'Q4B': [],
        'Q5': 2.0, // Very few pushups
        'Q6A': 'yes',
        'glp1_medications': 'yes', // Key trigger
        'sleep_hours': 6.5,
        'sugary_treats': 'rarely', // Improved diet on GLP-1
        'sodas': 'never',
        'grains': 'sometimes',
        'alcohol': 'rarely',
        'session_commitment': 'moderate',
        'Q1': 'none',
        'Q2': 'caution',
        'Q10': 'basic',
        'Q11': 'gym',
      },
      metadata: {
        'category': 'critical_medical',
        'expected_protocol': 'glp1_obesity',
      },
    );
  }

  static PersonaTestCase extremeObesity() {
    return PersonaTestCase(
      personaId: 'extreme_obesity',
      description: '38-year-old with extreme obesity, limited mobility',
      answers: {
        'age': '1986-09-22',
        'gender': 'male',
        'height_cm': 178.0,
        'weight_kg': 130.0, // BMI ~41
        'primary_motivation': 'lose_weight',
        'progress_tracking': 'weekly_check_ins',
        'fitness_goals': ['lose_weight', 'better_health'],
        'Q4': 0.2, // Cannot really run
        'Q4A': 'no',
        'Q4B': [],
        'Q5': 0.0, // No pushups
        'Q6A': 'no', // Struggles with chair
        'glp1_medications': 'no',
        'sleep_hours': 5.5, // Poor sleep
        'sugary_treats': 'often',
        'sodas': 'often',
        'grains': 'often',
        'alcohol': 'sometimes',
        'session_commitment': 'low',
        'Q1': 'knee',
        'Q2': 'avoid',
        'Q10': 'none',
        'Q11': 'home',
      },
      metadata: {
        'category': 'critical_medical',
        'expected_protocol': 'extreme_obesity',
      },
    );
  }

  static PersonaTestCase multipleConditions() {
    return PersonaTestCase(
      personaId: 'multiple_conditions',
      description: '70-year-old with fall history AND obesity',
      answers: {
        'age': '1954-04-15',
        'gender': 'female',
        'height_cm': 160.0,
        'weight_kg': 85.0, // BMI ~33
        'primary_motivation': 'better_health',
        'progress_tracking': 'monthly_check_ins',
        'fitness_goals': ['better_health', 'live_longer'],
        'Q4': 0.4,
        'Q4A': 'yes', // Fall history (should trigger first)
        'Q4B': ['medication', 'balance'],
        'Q5': 0.0,
        'Q6A': 'yes',
        'glp1_medications': 'no',
        'sleep_hours': 7.5,
        'sugary_treats': 'sometimes',
        'sodas': 'rarely',
        'grains': 'often',
        'alcohol': 'never',
        'session_commitment': 'low',
        'Q1': 'hip',
        'Q2': 'avoid',
        'Q10': 'none',
        'Q11': 'home',
      },
      metadata: {
        'category': 'critical_medical',
        'expected_protocol': 'fall_history', // Priority #1
      },
    );
  }

  // AGE-BASED PROFILES

  static PersonaTestCase youngAthlete() {
    return PersonaTestCase(
      personaId: 'young_athlete',
      description: '25-year-old competitive athlete',
      answers: {
        'age': '1999-07-08',
        'gender': 'male',
        'height_cm': 182.0,
        'weight_kg': 78.0,
        'primary_motivation': 'improve_performance',
        'progress_tracking': 'daily_tracking',
        'fitness_goals': ['build_muscle', 'improve_endurance'],
        'Q4': 2.1, // Excellent cardio
        'Q4A': 'no',
        'Q4B': [],
        'Q5': 45.0, // Strong
        'Q6A': 'yes',
        'glp1_medications': 'no',
        'sleep_hours': 8.0,
        'sugary_treats': 'rarely',
        'sodas': 'never',
        'grains': 'often',
        'alcohol': 'sometimes',
        'session_commitment': 'very_high',
        'Q1': 'none',
        'Q2': 'prefer',
        'Q10': 'full_gym',
        'Q11': 'gym',
      },
      metadata: {
        'category': 'age_based',
        'expected_protocol': 'none',
      },
    );
  }

  static PersonaTestCase middleAgedBeginner() {
    return PersonaTestCase(
      personaId: 'middle_aged_beginner',
      description: '42-year-old sedentary starting fitness journey',
      answers: {
        'age': '1982-11-30',
        'gender': 'female',
        'height_cm': 168.0,
        'weight_kg': 72.0,
        'primary_motivation': 'better_health',
        'progress_tracking': 'weekly_check_ins',
        'fitness_goals': ['better_health', 'lose_weight'],
        'Q4': 0.7, // Below average
        'Q4A': 'no',
        'Q4B': [],
        'Q5': 3.0, // Very weak
        'Q6A': 'yes',
        'glp1_medications': 'no',
        'sleep_hours': 6.5,
        'sugary_treats': 'sometimes',
        'sodas': 'sometimes',
        'grains': 'often',
        'alcohol': 'sometimes',
        'session_commitment': 'moderate',
        'Q1': 'none',
        'Q2': 'neutral',
        'Q10': 'basic',
        'Q11': 'gym',
      },
      metadata: {
        'category': 'age_based',
        'expected_protocol': 'none',
      },
    );
  }

  static PersonaTestCase activeSenior() {
    return PersonaTestCase(
      personaId: 'active_senior',
      description: '68-year-old regular walker in good health',
      answers: {
        'age': '1956-02-18',
        'gender': 'male',
        'height_cm': 175.0,
        'weight_kg': 75.0,
        'primary_motivation': 'maintain_fitness',
        'progress_tracking': 'monthly_check_ins',
        'fitness_goals': ['better_health', 'live_longer'],
        'Q4': 1.1, // Good for age
        'Q4A': 'no',
        'Q4B': [],
        'Q5': 8.0, // Decent strength
        'Q6A': 'yes',
        'glp1_medications': 'no',
        'sleep_hours': 7.5,
        'sugary_treats': 'rarely',
        'sodas': 'never',
        'grains': 'sometimes',
        'alcohol': 'rarely',
        'session_commitment': 'moderate',
        'Q1': 'none',
        'Q2': 'caution',
        'Q10': 'basic',
        'Q11': 'outdoor',
      },
      metadata: {
        'category': 'age_based',
        'expected_protocol': 'none',
      },
    );
  }

  static PersonaTestCase frailElderly() {
    return PersonaTestCase(
      personaId: 'frail_elderly',
      description: '82-year-old with minimal activity, needs assistance',
      answers: {
        'age': '1942-08-05',
        'gender': 'female',
        'height_cm': 158.0,
        'weight_kg': 55.0,
        'primary_motivation': 'maintain_independence',
        'progress_tracking': 'family_support',
        'fitness_goals': ['better_health', 'live_longer'],
        'Q4': 0.2, // Cannot really walk far
        'Q4A': 'no', // No falls yet
        'Q4B': ['balance', 'medication'],
        'Q5': 0.0,
        'Q6A': 'no',
        'glp1_medications': 'no',
        'sleep_hours': 9.0,
        'sugary_treats': 'rarely',
        'sodas': 'never',
        'grains': 'sometimes',
        'alcohol': 'never',
        'session_commitment': 'very_low',
        'Q1': 'multiple',
        'Q2': 'avoid',
        'Q10': 'none',
        'Q11': 'home',
      },
      metadata: {
        'category': 'age_based',
        'expected_protocol': 'none',
      },
    );
  }

  static PersonaTestCase teenStarter() {
    return PersonaTestCase(
      personaId: 'teen_starter',
      description: '16-year-old with no fitness background',
      answers: {
        'age': '2008-05-12',
        'gender': 'female',
        'height_cm': 165.0,
        'weight_kg': 58.0,
        'primary_motivation': 'look_better',
        'progress_tracking': 'social_sharing',
        'fitness_goals': ['build_muscle', 'better_health'],
        'Q4': 1.0, // Average for age
        'Q4A': 'no',
        'Q4B': [],
        'Q5': 8.0, // Decent for beginner
        'Q6A': 'yes',
        'glp1_medications': 'no',
        'sleep_hours': 7.0,
        'sugary_treats': 'often',
        'sodas': 'sometimes',
        'grains': 'often',
        'alcohol': 'never',
        'session_commitment': 'moderate',
        'Q1': 'none',
        'Q2': 'prefer',
        'Q10': 'basic',
        'Q11': 'gym',
      },
      metadata: {
        'category': 'age_based',
        'expected_protocol': 'none',
      },
    );
  }

  // FITNESS LEVEL VARIANTS

  static PersonaTestCase deconditionedAdult() {
    return PersonaTestCase(
      personaId: 'deconditioned_adult',
      description: '35-year-old severely deconditioned',
      answers: {
        'age': '1989-12-03',
        'gender': 'male',
        'height_cm': 180.0,
        'weight_kg': 90.0,
        'primary_motivation': 'better_health',
        'progress_tracking': 'weekly_check_ins',
        'fitness_goals': ['lose_weight', 'better_health'],
        'Q4': 0.4, // Very poor
        'Q4A': 'no',
        'Q4B': [],
        'Q5': 0.0, // Cannot do any
        'Q6A': 'yes',
        'glp1_medications': 'no',
        'sleep_hours': 5.5,
        'sugary_treats': 'often',
        'sodas': 'often',
        'grains': 'often',
        'alcohol': 'often',
        'session_commitment': 'low',
        'Q1': 'none',
        'Q2': 'neutral',
        'Q10': 'none',
        'Q11': 'home',
      },
      metadata: {
        'category': 'fitness_level',
        'expected_protocol': 'none',
      },
    );
  }

  static PersonaTestCase weekendWarrior() {
    return PersonaTestCase(
      personaId: 'weekend_warrior',
      description: '48-year-old with moderate but inconsistent fitness',
      answers: {
        'age': '1976-01-20',
        'gender': 'male',
        'height_cm': 178.0,
        'weight_kg': 82.0,
        'primary_motivation': 'maintain_fitness',
        'progress_tracking': 'weekly_check_ins',
        'fitness_goals': ['better_health', 'build_muscle'],
        'Q4': 1.2, // Decent
        'Q4A': 'no',
        'Q4B': [],
        'Q5': 15.0, // Moderate
        'Q6A': 'yes',
        'glp1_medications': 'no',
        'sleep_hours': 6.5,
        'sugary_treats': 'sometimes',
        'sodas': 'rarely',
        'grains': 'often',
        'alcohol': 'often',
        'session_commitment': 'moderate',
        'Q1': 'none',
        'Q2': 'prefer',
        'Q10': 'basic',
        'Q11': 'gym',
      },
      metadata: {
        'category': 'fitness_level',
        'expected_protocol': 'none',
      },
    );
  }

  static PersonaTestCase formerAthlete() {
    return PersonaTestCase(
      personaId: 'former_athlete',
      description: '55-year-old former athlete, good strength but poor cardio',
      answers: {
        'age': '1969-04-14',
        'gender': 'male',
        'height_cm': 185.0,
        'weight_kg': 95.0,
        'primary_motivation': 'better_health',
        'progress_tracking': 'monthly_check_ins',
        'fitness_goals': ['improve_endurance', 'better_health'],
        'Q4': 0.8, // Poor cardio now
        'Q4A': 'no',
        'Q4B': [],
        'Q5': 25.0, // Still strong
        'Q6A': 'yes',
        'glp1_medications': 'no',
        'sleep_hours': 7.0,
        'sugary_treats': 'sometimes',
        'sodas': 'rarely',
        'grains': 'often',
        'alcohol': 'sometimes',
        'session_commitment': 'high',
        'Q1': 'knee',
        'Q2': 'caution',
        'Q10': 'full_gym',
        'Q11': 'gym',
      },
      metadata: {
        'category': 'fitness_level',
        'expected_protocol': 'none',
      },
    );
  }

  static PersonaTestCase yogaPractitioner() {
    return PersonaTestCase(
      personaId: 'yoga_practitioner',
      description: '40-year-old yoga practitioner, flexible but weak strength',
      answers: {
        'age': '1984-10-07',
        'gender': 'female',
        'height_cm': 170.0,
        'weight_kg': 62.0,
        'primary_motivation': 'better_health',
        'progress_tracking': 'mindful_practice',
        'fitness_goals': ['build_muscle', 'increase_flexibility'],
        'Q4': 1.0, // Average cardio
        'Q4A': 'no',
        'Q4B': [],
        'Q5': 5.0, // Weak upper body
        'Q6A': 'yes',
        'glp1_medications': 'no',
        'sleep_hours': 8.0,
        'sugary_treats': 'rarely',
        'sodas': 'never',
        'grains': 'sometimes',
        'alcohol': 'rarely',
        'session_commitment': 'high',
        'Q1': 'none',
        'Q2': 'neutral',
        'Q10': 'basic',
        'Q11': 'home',
      },
      metadata: {
        'category': 'fitness_level',
        'expected_protocol': 'none',
      },
    );
  }

  static PersonaTestCase marathonRunner() {
    return PersonaTestCase(
      personaId: 'marathon_runner',
      description: '33-year-old marathon runner, excellent cardio but poor strength',
      answers: {
        'age': '1991-06-25',
        'gender': 'female',
        'height_cm': 165.0,
        'weight_kg': 55.0,
        'primary_motivation': 'improve_performance',
        'progress_tracking': 'data_driven',
        'fitness_goals': ['build_muscle', 'improve_endurance'],
        'Q4': 2.3, // Excellent cardio
        'Q4A': 'no',
        'Q4B': [],
        'Q5': 2.0, // Very weak strength
        'Q6A': 'yes',
        'glp1_medications': 'no',
        'sleep_hours': 8.5,
        'sugary_treats': 'rarely',
        'sodas': 'never',
        'grains': 'often',
        'alcohol': 'rarely',
        'session_commitment': 'very_high',
        'Q1': 'none',
        'Q2': 'prefer',
        'Q10': 'full_gym',
        'Q11': 'gym',
      },
      metadata: {
        'category': 'fitness_level',
        'expected_protocol': 'none',
      },
    );
  }

  // HEALTH CONDITIONS

  static PersonaTestCase postSurgeryRecovery() {
    return PersonaTestCase(
      personaId: 'post_surgery',
      description: '52-year-old recovering from knee replacement',
      answers: {
        'age': '1972-03-18',
        'gender': 'female',
        'height_cm': 167.0,
        'weight_kg': 78.0,
        'primary_motivation': 'recover_function',
        'progress_tracking': 'medical_guidance',
        'fitness_goals': ['better_health'],
        'Q4': 0.5, // Limited by surgery
        'Q4A': 'no',
        'Q4B': [],
        'Q5': 8.0, // Upper body OK
        'Q6A': 'no', // Post-surgery
        'glp1_medications': 'no',
        'sleep_hours': 7.5,
        'sugary_treats': 'sometimes',
        'sodas': 'rarely',
        'grains': 'often',
        'alcohol': 'rarely',
        'session_commitment': 'moderate',
        'Q1': 'knee',
        'Q2': 'avoid',
        'Q10': 'basic',
        'Q11': 'physical_therapy',
      },
      metadata: {
        'category': 'health_condition',
        'expected_protocol': 'none',
      },
    );
  }

  static PersonaTestCase chronicBackPain() {
    return PersonaTestCase(
      personaId: 'chronic_back_pain',
      description: '46-year-old with chronic back pain, limited high-impact',
      answers: {
        'age': '1978-08-12',
        'gender': 'male',
        'height_cm': 175.0,
        'weight_kg': 85.0,
        'primary_motivation': 'pain_management',
        'progress_tracking': 'symptom_tracking',
        'fitness_goals': ['better_health', 'increase_flexibility'],
        'Q4': 0.9, // Limited cardio options
        'Q4A': 'no',
        'Q4B': [],
        'Q5': 12.0, // Moderate strength
        'Q6A': 'yes',
        'glp1_medications': 'no',
        'sleep_hours': 6.0, // Poor sleep from pain
        'sugary_treats': 'sometimes',
        'sodas': 'sometimes',
        'grains': 'often',
        'alcohol': 'sometimes',
        'session_commitment': 'moderate',
        'Q1': 'back',
        'Q2': 'avoid',
        'Q10': 'basic',
        'Q11': 'home',
      },
      metadata: {
        'category': 'health_condition',
        'expected_protocol': 'none',
      },
    );
  }

  static PersonaTestCase diabetesType2() {
    return PersonaTestCase(
      personaId: 'diabetes_type2',
      description: '58-year-old with Type 2 diabetes, insulin resistant',
      answers: {
        'age': '1966-11-09',
        'gender': 'male',
        'height_cm': 172.0,
        'weight_kg': 88.0, // BMI ~30
        'primary_motivation': 'health_management',
        'progress_tracking': 'medical_guidance',
        'fitness_goals': ['lose_weight', 'better_health'],
        'Q4': 0.7, // Poor cardio
        'Q4A': 'no',
        'Q4B': [],
        'Q5': 6.0, // Weak
        'Q6A': 'yes',
        'glp1_medications': 'no', // Regular diabetes meds
        'sleep_hours': 6.5,
        'sugary_treats': 'rarely', // Diet controlled
        'sodas': 'never',
        'grains': 'sometimes',
        'alcohol': 'rarely',
        'session_commitment': 'high', // Motivated by health
        'Q1': 'none',
        'Q2': 'neutral',
        'Q10': 'basic',
        'Q11': 'gym',
      },
      metadata: {
        'category': 'health_condition',
        'expected_protocol': 'none',
      },
    );
  }

  static PersonaTestCase underweight() {
    return PersonaTestCase(
      personaId: 'underweight',
      description: '28-year-old underweight, needs muscle building',
      answers: {
        'age': '1996-04-22',
        'gender': 'male',
        'height_cm': 180.0,
        'weight_kg': 58.0, // BMI ~18
        'primary_motivation': 'build_muscle',
        'progress_tracking': 'weight_gain',
        'fitness_goals': ['build_muscle', 'better_health'],
        'Q4': 1.3, // Decent cardio but light
        'Q4A': 'no',
        'Q4B': [],
        'Q5': 8.0, // Weak due to low mass
        'Q6A': 'yes',
        'glp1_medications': 'no',
        'sleep_hours': 7.0,
        'sugary_treats': 'often', // Trying to gain weight
        'sodas': 'sometimes',
        'grains': 'often',
        'alcohol': 'sometimes',
        'session_commitment': 'high',
        'Q1': 'none',
        'Q2': 'prefer',
        'Q10': 'full_gym',
        'Q11': 'gym',
      },
      metadata: {
        'category': 'health_condition',
        'expected_protocol': 'none',
      },
    );
  }

  static PersonaTestCase postpartum() {
    return PersonaTestCase(
      personaId: 'postpartum',
      description: '32-year-old 6 months post-birth, core weakness',
      answers: {
        'age': '1992-07-16',
        'gender': 'female',
        'height_cm': 168.0,
        'weight_kg': 75.0, // Still carrying extra weight
        'primary_motivation': 'get_back_in_shape',
        'progress_tracking': 'body_changes',
        'fitness_goals': ['lose_weight', 'build_muscle'],
        'Q4': 0.8, // Recovering fitness
        'Q4A': 'no',
        'Q4B': [],
        'Q5': 3.0, // Weak from pregnancy
        'Q6A': 'yes',
        'glp1_medications': 'no',
        'sleep_hours': 5.0, // New parent exhaustion
        'sugary_treats': 'often', // Stress eating
        'sodas': 'sometimes',
        'grains': 'often',
        'alcohol': 'never', // Breastfeeding
        'session_commitment': 'low', // Limited time
        'Q1': 'core', // Diastasis recti
        'Q2': 'caution',
        'Q10': 'basic',
        'Q11': 'home',
      },
      metadata: {
        'category': 'health_condition',
        'expected_protocol': 'none',
      },
    );
  }

  // LIFESTYLE VARIANTS

  static PersonaTestCase busyExecutive() {
    return PersonaTestCase(
      personaId: 'busy_executive',
      description: '44-year-old executive, maximum 2 sessions per week',
      answers: {
        'age': '1980-02-28',
        'gender': 'male',
        'height_cm': 178.0,
        'weight_kg': 85.0,
        'primary_motivation': 'stress_management',
        'progress_tracking': 'efficiency_focus',
        'fitness_goals': ['better_health', 'build_muscle'],
        'Q4': 0.9, // Declining fitness
        'Q4A': 'no',
        'Q4B': [],
        'Q5': 12.0, // Some strength
        'Q6A': 'yes',
        'glp1_medications': 'no',
        'sleep_hours': 5.5, // Workaholic
        'sugary_treats': 'often', // Stress eating
        'sodas': 'often', // Caffeine dependent
        'grains': 'often',
        'alcohol': 'often', // Business dinners
        'session_commitment': 'low', // Time constraints
        'Q1': 'none',
        'Q2': 'prefer', // Wants intense workouts
        'Q10': 'full_gym',
        'Q11': 'gym',
      },
      metadata: {
        'category': 'lifestyle',
        'expected_protocol': 'none',
      },
    );
  }

  static PersonaTestCase nightShiftWorker() {
    return PersonaTestCase(
      personaId: 'night_shift_worker',
      description: '36-year-old night shift worker, poor sleep and irregular schedule',
      answers: {
        'age': '1988-05-30',
        'gender': 'female',
        'height_cm': 165.0,
        'weight_kg': 70.0,
        'primary_motivation': 'energy_levels',
        'progress_tracking': 'energy_tracking',
        'fitness_goals': ['better_health', 'improve_endurance'],
        'Q4': 0.8, // Tired performance
        'Q4A': 'no',
        'Q4B': [],
        'Q5': 5.0, // Weak from poor recovery
        'Q6A': 'yes',
        'glp1_medications': 'no',
        'sleep_hours': 4.5, // Irregular sleep
        'sugary_treats': 'often', // Energy seeking
        'sodas': 'often', // Caffeine dependent
        'grains': 'often',
        'alcohol': 'rarely',
        'session_commitment': 'low', // Fatigue issues
        'Q1': 'none',
        'Q2': 'neutral',
        'Q10': 'basic',
        'Q11': 'home',
      },
      metadata: {
        'category': 'lifestyle',
        'expected_protocol': 'none',
      },
    );
  }

  static PersonaTestCase homeBoundParent() {
    return PersonaTestCase(
      personaId: 'homebound_parent',
      description: '39-year-old parent, no gym access, limited equipment',
      answers: {
        'age': '1985-09-14',
        'gender': 'female',
        'height_cm': 170.0,
        'weight_kg': 68.0,
        'primary_motivation': 'be_good_example',
        'progress_tracking': 'family_accountability',
        'fitness_goals': ['better_health', 'build_muscle'],
        'Q4': 1.0, // Average
        'Q4A': 'no',
        'Q4B': [],
        'Q5': 8.0, // Moderate
        'Q6A': 'yes',
        'glp1_medications': 'no',
        'sleep_hours': 6.5, // Parent sleep
        'sugary_treats': 'sometimes',
        'sodas': 'rarely',
        'grains': 'often',
        'alcohol': 'rarely',
        'session_commitment': 'moderate',
        'Q1': 'none',
        'Q2': 'neutral',
        'Q10': 'none', // No equipment
        'Q11': 'home',
      },
      metadata: {
        'category': 'lifestyle',
        'expected_protocol': 'none',
      },
    );
  }

  static PersonaTestCase retiree() {
    return PersonaTestCase(
      personaId: 'retiree',
      description: '65-year-old retiree with lots of time and social motivation',
      answers: {
        'age': '1959-01-25',
        'gender': 'male',
        'height_cm': 175.0,
        'weight_kg': 80.0,
        'primary_motivation': 'social_activity',
        'progress_tracking': 'social_sharing',
        'fitness_goals': ['better_health', 'live_longer'],
        'Q4': 0.9, // Decent for age
        'Q4A': 'no',
        'Q4B': [],
        'Q5': 10.0, // Moderate
        'Q6A': 'yes',
        'glp1_medications': 'no',
        'sleep_hours': 8.0, // Good sleep
        'sugary_treats': 'sometimes',
        'sodas': 'rarely',
        'grains': 'often',
        'alcohol': 'sometimes',
        'session_commitment': 'high', // Lots of time
        'Q1': 'none',
        'Q2': 'caution',
        'Q10': 'basic',
        'Q11': 'gym',
      },
      metadata: {
        'category': 'lifestyle',
        'expected_protocol': 'none',
      },
    );
  }

  static PersonaTestCase collegeStudent() {
    return PersonaTestCase(
      personaId: 'college_student',
      description: '20-year-old college student, irregular schedule but gym access',
      answers: {
        'age': '2004-11-08',
        'gender': 'male',
        'height_cm': 175.0,
        'weight_kg': 68.0,
        'primary_motivation': 'look_better',
        'progress_tracking': 'social_media',
        'fitness_goals': ['build_muscle', 'improve_endurance'],
        'Q4': 1.2, // Young and active
        'Q4A': 'no',
        'Q4B': [],
        'Q5': 12.0, // Natural strength
        'Q6A': 'yes',
        'glp1_medications': 'no',
        'sleep_hours': 6.0, // College sleep
        'sugary_treats': 'often', // College diet
        'sodas': 'often',
        'grains': 'often',
        'alcohol': 'often', // College social life
        'session_commitment': 'high', // Motivated
        'Q1': 'none',
        'Q2': 'prefer',
        'Q10': 'full_gym', // Campus gym
        'Q11': 'gym',
      },
      metadata: {
        'category': 'lifestyle',
        'expected_protocol': 'none',
      },
    );
  }
}