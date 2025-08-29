import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'fitness_plan/models/plan.dart';
import 'fitness_plan/models/session.dart';
import 'fitness_plan/models/planned_week.dart';
import 'fitness_plan/models/planned_day.dart';
import 'fitness_plan/models/blocks/block.dart';
import 'fitness_plan/models/blocks/exercise_prescription_step.dart';
import 'fitness_plan/enums/goal.dart';
import 'fitness_plan/enums/day_of_week.dart';
import 'fitness_plan/enums/session_status.dart';
import 'fitness_plan/enums/block_type.dart';
import 'fitness_plan/enums/item_mode.dart';
import 'routing/route_names.dart';

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

  /// Create mock Plan data for testing fitness views
  Plan _createMockPlan() {
    final mockSessions = [
      Session(
        id: 'session_1',
        title: 'Upper Body Strength',
        blocks: [_createMockBlock(), _createMockBlock2()],
      ),
      Session(
        id: 'session_2',
        title: 'Lower Body Power',
        blocks: [_createMockBlock(), _createMockBlock2()],
      ),
      Session(
        id: 'session_3', 
        title: 'Full Body Conditioning',
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