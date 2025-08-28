import 'package:ascent/fitness_plan/models/plan.dart';
import 'package:ascent/fitness_plan/models/planned_week.dart';
import 'package:ascent/fitness_plan/models/planned_day.dart';
import 'package:ascent/fitness_plan/models/session.dart';
import 'package:ascent/fitness_plan/models/blocks/block.dart';
import 'package:ascent/fitness_plan/models/blocks/exercise_prescription_step.dart';
import 'package:ascent/fitness_plan/enums/goal.dart';
import 'package:ascent/fitness_plan/enums/day_of_week.dart';
import 'package:ascent/fitness_plan/enums/session_status.dart';
import 'package:ascent/fitness_plan/enums/block_type.dart';
import 'package:ascent/fitness_plan/enums/item_mode.dart';

class SamplePlanData {
  static Plan createSamplePlan() {
    // Create sample exercises
    final squatExercise = ExercisePrescriptionStep(
      exerciseId: 'squat_001',
      displayName: 'Bodyweight Squat',
      mode: ItemMode.reps,
      sets: 3,
      reps: 15,
      restSecBetweenSets: 60,
      tempo: '2-1-2-1',
      cues: ['Keep chest up', 'Knees track over toes', 'Full depth'],
    );

    final pushupExercise = ExercisePrescriptionStep(
      exerciseId: 'pushup_001',
      displayName: 'Push-ups',
      mode: ItemMode.reps,
      sets: 3,
      reps: 12,
      restSecBetweenSets: 45,
      cues: ['Tight core', 'Full range of motion'],
    );

    final plankExercise = ExercisePrescriptionStep(
      exerciseId: 'plank_001',
      displayName: 'Plank Hold',
      mode: ItemMode.time,
      sets: 3,
      timeSecPerSet: 30,
      restSecBetweenSets: 30,
      cues: ['Straight line', 'Breathe steadily'],
    );

    // Create sample blocks
    final strengthBlock = Block(
      type: BlockType.main,
      rounds: 1,
      items: [squatExercise, pushupExercise],
    );

    final coreBlock = Block(
      type: BlockType.main,
      rounds: 2,
      restSecBetweenRounds: 60,
      items: [plankExercise],
    );

    // Create sample sessions
    final session1 = Session(
      id: 'session_001',
      title: 'Upper Body Strength',
      blocks: [strengthBlock, coreBlock],
    );

    final session2 = Session(
      id: 'session_002',
      title: 'Lower Body Strength',
      blocks: [strengthBlock],
    );

    // Create sample planned days
    final day1 = PlannedDay(
      dow: DayOfWeek.mon,
      sessionId: 'session_001',
      status: SessionStatus.planned,
    );

    final day2 = PlannedDay(
      dow: DayOfWeek.wed,
      sessionId: 'session_002',
      status: SessionStatus.planned,
    );

    final day3 = PlannedDay(
      dow: DayOfWeek.fri,
      sessionId: 'session_001',
      status: SessionStatus.completed,
    );

    // Create sample weeks
    final week1 = PlannedWeek(
      weekIndex: 1,
      days: [day1, day2, day3],
    );

    final week2 = PlannedWeek(
      weekIndex: 2,
      days: [day1, day2],
    );

    // Create sample plan
    return Plan(
      planId: 'plan_001',
      userId: 'user_001',
      goal: Goal.getStronger,
      startDate: DateTime.now().subtract(const Duration(days: 7)),
      weeks: [week1, week2],
      sessions: [session1, session2],
      notesCoach: 'Focus on form over speed. Progress gradually.',
    );
  }
}