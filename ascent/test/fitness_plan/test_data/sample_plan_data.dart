import 'package:ascent/models/fitness_plan/plan.dart';
import 'package:ascent/models/plan_concepts/planned_week.dart';
import 'package:ascent/models/plan_concepts/planned_day.dart';
import 'package:ascent/models/plan_concepts/session.dart';
import 'package:ascent/models/blocks/block.dart';
import 'package:ascent/models/blocks/exercise_prescription_step.dart';
import 'package:ascent/enums/goal.dart';
import 'package:ascent/enums/day_of_week.dart';
import 'package:ascent/enums/session_status.dart';
import 'package:ascent/enums/block_type.dart';
import 'package:ascent/enums/item_mode.dart';
import 'package:ascent/enums/session_type.dart';
import 'package:ascent/enums/exercise_style.dart';

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

    // Create sample sessions with different types and styles
    final session1 = Session(
      id: 'session_001',
      title: 'Upper Body Strength',
      blocks: [strengthBlock, coreBlock],
      type: SessionType.macro,
      style: ExerciseStyle.strength,
    );

    final session2 = Session(
      id: 'session_002',
      title: 'Lower Body Strength',
      blocks: [strengthBlock],
      type: SessionType.macro,
      style: ExerciseStyle.strength,
    );

    final session3 = Session(
      id: 'session_003',
      title: 'Quick Cardio',
      blocks: [strengthBlock],
      type: SessionType.micro,
      style: ExerciseStyle.cardio,
    );

    final session4 = Session(
      id: 'session_004',
      title: 'Flexibility Flow',
      blocks: [coreBlock],
      type: SessionType.micro,
      style: ExerciseStyle.flexibility,
    );

    final session5 = Session(
      id: 'session_005',
      title: 'Balance Training',
      blocks: [coreBlock],
      type: SessionType.macro,
      style: ExerciseStyle.balance,
    );

    final session6 = Session(
      id: 'session_006',
      title: 'Functional Movement',
      blocks: [strengthBlock, coreBlock],
      type: SessionType.macro,
      style: ExerciseStyle.functional,
    );

    final session7 = Session(
      id: 'session_007',
      title: 'Morning Stretch',
      blocks: [coreBlock],
      type: SessionType.micro,
      style: ExerciseStyle.flexibility,
    );

    // Create sample planned days for Week 1 (current week with some completed)
    final week1Days = [
      PlannedDay(dow: DayOfWeek.mon, sessionId: 'session_001', status: SessionStatus.completed),
      PlannedDay(dow: DayOfWeek.tue, sessionId: 'session_003', status: SessionStatus.completed),
      PlannedDay(dow: DayOfWeek.wed, sessionId: 'session_002', status: SessionStatus.completed),
      PlannedDay(dow: DayOfWeek.thu, sessionId: 'session_004', status: SessionStatus.planned),
      PlannedDay(dow: DayOfWeek.fri, sessionId: 'session_005', status: SessionStatus.planned),
      PlannedDay(dow: DayOfWeek.sat, sessionId: 'session_006', status: SessionStatus.planned),
      PlannedDay(dow: DayOfWeek.sun, sessionId: 'session_007', status: SessionStatus.planned),
    ];

    // Week 2 - All planned
    final week2Days = [
      PlannedDay(dow: DayOfWeek.mon, sessionId: 'session_002', status: SessionStatus.planned),
      PlannedDay(dow: DayOfWeek.tue, sessionId: 'session_003', status: SessionStatus.planned),
      PlannedDay(dow: DayOfWeek.wed, sessionId: 'session_001', status: SessionStatus.planned),
      PlannedDay(dow: DayOfWeek.thu, sessionId: 'session_004', status: SessionStatus.planned),
      PlannedDay(dow: DayOfWeek.fri, sessionId: 'session_005', status: SessionStatus.planned),
      PlannedDay(dow: DayOfWeek.sat, sessionId: 'session_006', status: SessionStatus.planned),
    ];

    // Week 3 - Mix of sessions
    final week3Days = [
      PlannedDay(dow: DayOfWeek.mon, sessionId: 'session_001', status: SessionStatus.planned),
      PlannedDay(dow: DayOfWeek.wed, sessionId: 'session_003', status: SessionStatus.planned),
      PlannedDay(dow: DayOfWeek.fri, sessionId: 'session_005', status: SessionStatus.planned),
      PlannedDay(dow: DayOfWeek.sat, sessionId: 'session_007', status: SessionStatus.planned),
    ];

    // Week 4 - Lighter week
    final week4Days = [
      PlannedDay(dow: DayOfWeek.tue, sessionId: 'session_003', status: SessionStatus.planned),
      PlannedDay(dow: DayOfWeek.thu, sessionId: 'session_004', status: SessionStatus.planned),
      PlannedDay(dow: DayOfWeek.sat, sessionId: 'session_001', status: SessionStatus.planned),
    ];

    // Create sample weeks (4 weeks total)
    final week1 = PlannedWeek(weekIndex: 1, days: week1Days);
    final week2 = PlannedWeek(weekIndex: 2, days: week2Days);
    final week3 = PlannedWeek(weekIndex: 3, days: week3Days);
    final week4 = PlannedWeek(weekIndex: 4, days: week4Days);

    // Create sample plan
    return Plan(
      planId: 'plan_001',
      userId: 'user_001',
      goal: Goal.getStronger,
      startDate: DateTime.now(), // Start from today
      weeks: [week1, week2, week3, week4],
      sessions: [session1, session2, session3, session4, session5, session6, session7],
      notesCoach: 'Focus on form over speed. Progress gradually.',
    );
  }
}