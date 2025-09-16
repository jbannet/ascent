import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'models/fitness_plan/plan.dart';
import 'models/plan_concepts/session.dart';
import 'models/plan_concepts/planned_week.dart';
import 'models/plan_concepts/planned_day.dart';
import 'models/blocks/block.dart';
import 'models/blocks/exercise_prescription_step.dart';
import 'models/blocks/rest_step.dart';
import 'models/blocks/warmup_step.dart';
import 'models/blocks/cooldown_step.dart';
import 'workflow_views/fitness_plan/views/block_cards/exercise_step_card.dart';
import 'workflow_views/fitness_plan/views/block_cards/rest_step_card.dart';
import 'workflow_views/fitness_plan/views/block_cards/warmup_step_card.dart';
import 'workflow_views/fitness_plan/views/block_cards/cooldown_step_card.dart';
import 'enums/goal.dart';
import 'enums/day_of_week.dart';
import 'enums/session_status.dart';
import 'enums/session_type.dart';
import 'enums/exercise_style.dart';
import 'enums/block_type.dart';
import 'enums/item_mode.dart';
import 'routing/route_names.dart';
import 'temporary_mapping_tool.dart';

/// Temporary development navigation screen to access all views during development
class TemporaryNavigatorView extends StatelessWidget {
  const TemporaryNavigatorView({super.key});

  @override
  Widget build(BuildContext context) {
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
            title: 'Plan View',
            subtitle: 'View the fitness plan overview',
            icon: Icons.fitness_center,
            onTap: () => context.push(
              RouteNames.planPath(),
              extra: _createMockPlan(),
            ),
          ),
          
          _buildNavigationTile(
            context,
            title: 'Week View',
            subtitle: 'View a weekly training schedule',
            icon: Icons.calendar_view_week,
            onTap: () {
              final plan = _createMockPlan();
              context.push(
                RouteNames.weekPath(plan.planId, 1),
                extra: plan,
              );
            },
          ),
          
          _buildNavigationTile(
            context,
            title: 'Day View',
            subtitle: 'View a daily training session',
            icon: Icons.today,
            onTap: () {
              final plan = _createMockPlan();
              context.push(
                RouteNames.dayPath(plan.planId, 1, 'mon'),
                extra: plan,
              );
            },
          ),
          
          _buildNavigationTile(
            context,
            title: 'Block View',
            subtitle: 'View a training block/circuit',
            icon: Icons.view_module,
            onTap: () {
              final plan = _createMockPlan();
              context.push(
                RouteNames.blockPath(plan.planId, 1, 'mon', 0),
                extra: plan,
              );
            },
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

  /// Create mock Plan data for testing fitness views
  Plan _createMockPlan() {
    final mockSessions = [
      Session(
        id: 'session_1',
        title: 'Upper Body Strength',
        type: SessionType.macro,
        style: ExerciseStyle.strength,
        blocks: [_createMockBlock(), _createMockBlock2()],
      ),
      Session(
        id: 'session_2',
        title: 'Lower Body Power',
        type: SessionType.macro,
        style: ExerciseStyle.strength,
        blocks: [_createMockBlock(), _createMockBlock2()],
      ),
      Session(
        id: 'session_3',
        title: 'Full Body Conditioning',
        type: SessionType.macro,
        style: ExerciseStyle.cardio,
        blocks: [_createMockBlock()],
      ),
    ];

    final mockWeeks = [
      PlannedWeek(
        weekIndex: 1,
        days: [
          PlannedDay(dow: DayOfWeek.mon, sessionId: 'session_1', status: SessionStatus.planned),
          PlannedDay(dow: DayOfWeek.tue, sessionId: 'session_2', status: SessionStatus.planned),
          PlannedDay(dow: DayOfWeek.wed, sessionId: 'session_3', status: SessionStatus.completed),
          PlannedDay(dow: DayOfWeek.thu, sessionId: 'session_1', status: SessionStatus.planned),
          PlannedDay(dow: DayOfWeek.fri, sessionId: 'session_2', status: SessionStatus.skipped),
          PlannedDay(dow: DayOfWeek.sat, sessionId: 'session_3', status: SessionStatus.planned),
          PlannedDay(dow: DayOfWeek.sun, sessionId: 'session_1', status: SessionStatus.planned),
        ],
      ),
    ];

    return Plan(
      planId: 'mock_plan_123',
      userId: 'mock_user_456',
      goal: Goal.buildMuscle,
      startDate: DateTime.now(),
      weeks: mockWeeks,
      sessions: mockSessions,
      notesCoach: 'This is a mock plan for development testing.',
    );
  }

  /// Create mock Block data for testing
  Block _createMockBlock() {
    return Block(
      type: BlockType.superset,
      rounds: 3,
      restSecBetweenRounds: 120,
      items: [
        _createMockRepExercise('Push-ups', 12),
        _createMockRepExercise('Squats', 15),
        _createMockTimeExercise('Plank', 60),
      ],
    );
  }

  Block _createMockBlock2() {
    return Block(
      type: BlockType.main,
      rounds: 1,
      restSecBetweenRounds: 0,
      items: [
        _createMockRepExercise('Bench Press', 8),
        _createMockRepExercise('Row', 10),
        _createMockRepExercise('Overhead Press', 6),
      ],
    );
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

  /// Create mock ExercisePrescriptionStep for time-based exercises
  ExercisePrescriptionStep _createMockTimeExercise(String name, int timeSeconds) {
    return ExercisePrescriptionStep(
      exerciseId: 'mock_${name.toLowerCase().replaceAll(' ', '_')}',
      displayName: name,
      mode: ItemMode.time,
      sets: 3,
      timeSecPerSet: timeSeconds,
      restSecBetweenSets: 60,
      cues: ['Maintain position', 'Breathe steadily'],
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