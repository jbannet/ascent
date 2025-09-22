import 'package:ascent/models/fitness_plan/workout.dart';
import 'package:ascent/workflow_views/onboarding_workflow/views/onboarding_summary_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'constants_and_enums/constants_features.dart';
import 'constants_and_enums/item_mode.dart';
import 'constants_and_enums/session_type.dart';
import 'constants_and_enums/workout_style_enum.dart';
import 'models/blocks/cooldown_step.dart';
import 'models/blocks/exercise_prescription_step.dart';
import 'models/blocks/rest_step.dart';
import 'models/blocks/warmup_step.dart';
import 'models/fitness_plan/four_weeks.dart';
import 'models/fitness_plan/plan.dart';
import 'models/fitness_plan/plan_progress.dart';
import 'models/fitness_plan/week_of_workouts.dart';
import 'models/fitness_profile_model/fitness_profile.dart';
import 'routing/route_names.dart';
import 'services_and_utilities/app_state/app_state.dart';
import 'temporary_mapping_tool.dart';
import 'workflow_views/fitness_plan/views/block_cards/cooldown_step_card.dart';
import 'workflow_views/fitness_plan/views/block_cards/exercise_step_card.dart';
import 'workflow_views/fitness_plan/views/block_cards/rest_step_card.dart';
import 'workflow_views/fitness_plan/views/block_cards/warmup_step_card.dart';

/// Temporary development navigation screen to access all views during development
class TemporaryNavigatorView extends StatelessWidget {
  const TemporaryNavigatorView({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final featureOrder = appState.featureOrder;

    final summaryProfile = appState.profile ?? _createMockFitnessProfileWithMetrics(featureOrder);
    final planProfile = appState.profile ?? _createMockFitnessProfile(featureOrder);
    final planForNavigation = appState.plan ??
        (appState.hasProfile
            ? Plan.generateFromFitnessProfile(appState.profile!)
            : _createMockPlan(planProfile));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Development Navigator'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Choose a view to test:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          _buildNavigationTile(
            context,
            title: 'Onboarding Workflow',
            subtitle: 'Test the onboarding survey flow',
            icon: Icons.assignment,
            onTap: () => context.push('/onboarding'),
          ),

          _buildNavigationTile(
            context,
            title: 'Onboarding Summary',
            subtitle: 'View fitness profile summary after onboarding',
            icon: Icons.analytics,
            onTap: () => _showSummaryView(context, summaryProfile),
          ),

          _buildNavigationTile(
            context,
            title: 'Plan View',
            subtitle: 'View the fitness plan overview',
            icon: Icons.fitness_center,
            onTap: () => context.push(
              RouteNames.planPath(),
              extra: planForNavigation,
            ),
          ),
          
          
          

          const Divider(),
          const Text(
            'Block Step Cards:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          _buildNavigationTile(
            context,
            title: 'Exercise Step Card',
            subtitle: 'Preview exercise step card design',
            icon: Icons.fitness_center,
            onTap: () => _showCardPreview(
              context,
              'Exercise Step Card',
              ExerciseStepCard(step: _createMockRepExercise('Push-ups', 12)),
            ),
          ),

          _buildNavigationTile(
            context,
            title: 'Rest Step Card',
            subtitle: 'Preview rest timer card design',
            icon: Icons.timer,
            onTap: () => _showCardPreview(
              context,
              'Rest Step Card',
              RestStepCard(step: RestStep(seconds: 90, label: 'Rest between sets')),
            ),
          ),

          _buildNavigationTile(
            context,
            title: 'Warmup Step Card',
            subtitle: 'Preview warmup step card design',
            icon: Icons.self_improvement,
            onTap: () => _showCardPreview(
              context,
              'Warmup Step Card',
              WarmupStepCard(step: WarmupStep(displayName: 'Dynamic Stretching', timeSec: 300)),
            ),
          ),

          _buildNavigationTile(
            context,
            title: 'Cooldown Step Card',
            subtitle: 'Preview cooldown step card design',
            icon: Icons.spa,
            onTap: () => _showCardPreview(
              context,
              'Cooldown Step Card',
              CooldownStepCard(step: CooldownStep(displayName: 'Static Stretching', timeSec: 600)),
            ),
          ),

          const Divider(),
          const Text(
            'Development Tools:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          _buildNavigationTile(
            context,
            title: 'Body Map Coordinate Mapper',
            subtitle: 'Map body part coordinates on gender-specific images',
            icon: Icons.touch_app,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const TemporaryMappingTool(),
              ),
            ),
          ),

          const Divider(),
          const Text(
            'Swipable Card Demo:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          _buildNavigationTile(
            context,
            title: 'Swipable Block Steps',
            subtitle: 'Demo all cards in swipable PageView',
            icon: Icons.swipe,
            onTap: () => _showSwipableDemo(context),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: Icon(icon, size: 32, color: Colors.blue),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _showCardPreview(BuildContext context, String title, Widget card) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(title),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: card,
            ),
          ),
        ),
      ),
    );
  }

  void _showSwipableDemo(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _SwipableCardDemo(),
      ),
    );
  }

  void _showSummaryView(BuildContext context, FitnessProfile profile) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OnboardingSummaryView(
          fitnessProfile: profile,
        ),
      ),
    );
  }

  /// Create mock Plan data for testing fitness views
  Plan _createMockPlan(FitnessProfile profile) {

    final mockWeeks = [
      // Week 1 - This week
      WeekOfWorkouts(
        weekIndex: 1,
        startDate: DateTime.now(),
        workouts: [
          Workout(type: SessionType.full, style: WorkoutStyle.upperLowerSplit, isCompleted: true),
          Workout(type: SessionType.micro, style: WorkoutStyle.enduranceDominant, isCompleted: true),
          Workout(type: SessionType.full, style: WorkoutStyle.yogaFocused, isCompleted: false),
        ],
      ),
      // Week 2 - Next week
      WeekOfWorkouts(
        weekIndex: 2,
        startDate: DateTime.now(),
        workouts: [
          Workout(type: SessionType.full, style: WorkoutStyle.pushPullLegs, isCompleted: false),
          Workout(type: SessionType.micro, style: WorkoutStyle.seniorSpecific, isCompleted: false),
          Workout(type: SessionType.full, style: WorkoutStyle.circuitMetabolic, isCompleted: false),
        ],
      ),
      // Week 3
      WeekOfWorkouts(
        weekIndex: 3,
        startDate: DateTime.now(),
        workouts: [
          Workout(type: SessionType.full, style: WorkoutStyle.functionalMovement, isCompleted: false),
          Workout(type: SessionType.micro, style: WorkoutStyle.pilatesStyle, isCompleted: false),
        ],
      ),
      // Week 4
      WeekOfWorkouts(
        weekIndex: 4,
        startDate: DateTime.now(),
        workouts: [
          Workout(type: SessionType.micro, style: WorkoutStyle.seniorSpecific, isCompleted: false),
          Workout(type: SessionType.full, style: WorkoutStyle.strongmanFunctional, isCompleted: false),
        ],
      ),
    ];

    return Plan(
      planProgress: PlanProgress(),
      nextFourWeeks: FourWeeks(
        currentWeek: mockWeeks[0],
        nextWeeks: mockWeeks.sublist(1),
      ),
      fitnessProfile: profile,
    );
  }

  /// Create mock FitnessProfile data for testing the plan view
  FitnessProfile _createMockFitnessProfile(List<String> featureOrder) {
    final mockAnswers = <String, dynamic>{
      'age': 35,
      'experience_level': 'intermediate',
      'goals': ['strength', 'cardio'],
    };

    // Use internal constructor to avoid calculateAllFeatures() call
    final profile = FitnessProfile.createFitnessProfileFromStorage(featureOrder, mockAnswers);

    // Manually set some feature values to show meaningful category allocations
    profile.featuresMap[FeatureConstants.categoryCardio] = 0.35;     // 35%
    profile.featuresMap[FeatureConstants.categoryStrength] = 0.40;   // 40%
    profile.featuresMap[FeatureConstants.categoryBalance] = 0.15;    // 15%
    profile.featuresMap[FeatureConstants.categoryStretching] = 0.10; // 10%
    profile.featuresMap[FeatureConstants.fullSessionsPerWeek] = 3.0;
    profile.featuresMap[FeatureConstants.microSessionsPerWeek] = 2.0;

    return profile;
  }

  /// Create mock FitnessProfile with detailed fitness metrics for summary view
  FitnessProfile _createMockFitnessProfileWithMetrics(List<String> featureOrder) {
    final mockAnswers = <String, dynamic>{
      'age': 35,
      'gender': 'female',
      'weight': 140,
      'height': 66,
      'experience_level': 'intermediate',
      'goals': ['strength', 'cardio'],
    };

    // Create profile with storage factory to avoid auto-calculation
    final profile = FitnessProfile.createFitnessProfileFromStorage(featureOrder, mockAnswers);

    // Set category allocations
    profile.featuresMap[FeatureConstants.categoryCardio] = 0.35;     // 35%
    profile.featuresMap[FeatureConstants.categoryStrength] = 0.40;   // 40%
    profile.featuresMap[FeatureConstants.categoryBalance] = 0.15;    // 15%
    profile.featuresMap[FeatureConstants.categoryStretching] = 0.10; // 10%
    profile.featuresMap[FeatureConstants.categoryFunctional] = 0.0;  // 0%

    // Session commitment
    profile.featuresMap[FeatureConstants.fullSessionsPerWeek] = 3.0;
    profile.featuresMap[FeatureConstants.microSessionsPerWeek] = 2.0;
    profile.featuresMap['weekly_training_minutes'] = 180.0;
    profile.featuresMap['total_training_days'] = 5.0;

    // Cardio metrics
    profile.featuresMap['vo2max'] = 42.5;
    profile.featuresMap['mets_capacity'] = 12.1;
    profile.featuresMap['cardio_fitness_percentile'] = 75.0;
    profile.featuresMap['cardio_recovery_days'] = 1.0;

    // Strength metrics
    profile.featuresMap['upper_body_strength_percentile'] = 68.0;
    profile.featuresMap['lower_body_strength_percentile'] = 72.0;
    profile.featuresMap['strength_optimal_rep_range_min'] = 8.0;
    profile.featuresMap['strength_optimal_rep_range_max'] = 12.0;
    profile.featuresMap['strength_recovery_hours'] = 48.0;

    // Heart rate zones (age 35, so max HR ~185)
    profile.featuresMap['hr_zone1'] = 111.0;  // 60% max HR
    profile.featuresMap['hr_zone2'] = 130.0;  // 70% max HR
    profile.featuresMap['hr_zone3'] = 148.0;  // 80% max HR
    profile.featuresMap['hr_zone4'] = 167.0;  // 90% max HR
    profile.featuresMap['hr_zone5'] = 185.0;  // 100% max HR

    // Risk factors (good health)
    profile.featuresMap['fall_risk_score'] = 0.0;
    profile.featuresMap['joint_health_score'] = 8.5;
    profile.featuresMap['impact_tolerance'] = 9.0;

    return profile;
  }

  /// Create mock ExercisePrescriptionStep for reps-based exercises
  ExercisePrescriptionStep _createMockRepExercise(String name, int reps) {
    return ExercisePrescriptionStep(
      exerciseId: 'mock_${name.toLowerCase().replaceAll(' ', '_')}',
      displayName: name,
      mode: ItemMode.reps,
      sets: 3,
      reps: reps,
      restSecBetweenSets: 90,
      cues: ['Keep form tight', 'Controlled movement'],
    );
  }

}

class _SwipableCardDemo extends StatefulWidget {
  @override
  State<_SwipableCardDemo> createState() => _SwipableCardDemoState();
}

class _SwipableCardDemoState extends State<_SwipableCardDemo> {
  late PageController _pageController;
  int _currentIndex = 0;

  final List<String> _stepNames = [
    'Warmup',
    'Exercise 1',
    'Rest',
    'Exercise 2', 
    'Rest',
    'Cooldown',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Swipable Block Steps Demo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Step ${_currentIndex + 1} of ${_stepNames.length}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      _stepNames[_currentIndex],
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (_currentIndex + 1) / _stepNames.length,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
              ],
            ),
          ),
          // Swipable cards
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              children: [
                // Warmup
                WarmupStepCard(
                  step: WarmupStep(displayName: 'Dynamic Stretching', timeSec: 300),
                ),
                // Exercise 1 - Reps
                ExerciseStepCard(
                  step: ExercisePrescriptionStep(
                    exerciseId: 'push_ups',
                    displayName: 'Push-ups',
                    mode: ItemMode.reps,
                    sets: 3,
                    reps: 15,
                    restSecBetweenSets: 60,
                    tempo: '2-0-1-0',
                    cues: ['Keep body straight', 'Full range of motion', 'Control the descent'],
                  ),
                ),
                // Rest 1
                RestStepCard(
                  step: RestStep(seconds: 120, label: 'Rest between exercises'),
                ),
                // Exercise 2 - Time
                ExerciseStepCard(
                  step: ExercisePrescriptionStep(
                    exerciseId: 'plank',
                    displayName: 'Plank Hold',
                    mode: ItemMode.time,
                    sets: 3,
                    timeSecPerSet: 45,
                    restSecBetweenSets: 90,
                    cues: ['Maintain straight line', 'Engage core', 'Breathe normally'],
                  ),
                ),
                // Rest 2
                RestStepCard(
                  step: RestStep(seconds: 90, label: 'Final rest'),
                ),
                // Cooldown
                CooldownStepCard(
                  step: CooldownStep(displayName: 'Static Stretching', timeSec: 600),
                ),
              ],
            ),
          ),
          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_currentIndex > 0)
                  OutlinedButton.icon(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Previous'),
                  )
                else
                  const SizedBox(width: 100),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _currentIndex < _stepNames.length - 1
                      ? () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : () => Navigator.of(context).pop(),
                  icon: Icon(_currentIndex < _stepNames.length - 1 
                      ? Icons.arrow_forward 
                      : Icons.check),
                  label: Text(_currentIndex < _stepNames.length - 1 
                      ? 'Next Step' 
                      : 'Complete'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
