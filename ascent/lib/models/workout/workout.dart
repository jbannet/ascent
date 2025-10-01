import 'dart:math';
import '../../constants_and_enums/session_type.dart';
import '../../constants_and_enums/constants.dart';
import '../../constants_and_enums/workout_enums/workout_style_enum.dart';
import '../../constants_and_enums/workout_enums/pattern_with_preference.dart';
import '../../services_and_utilities/exercises/load_exercises_service.dart';
import 'block.dart';
import 'warmup_block.dart';
import 'cooldown_block.dart';
import 'exercise_block.dart';

class Workout{

  DateTime? date; //Sunday date of the week
  SessionType type; // Micro or full workout
  WorkoutStyle style; // Training style using enum for type safety
  int durationMinutes; // Total workout duration in minutes
  bool _isCompleted = false;
  List<Block>? blocks; // Generated workout blocks

  Workout({
    this.date,
    required this.type,
    required this.style,
    required this.durationMinutes,
    bool isCompleted = false,
    this.blocks,
  }) : _isCompleted = isCompleted;

  get isCompleted => _isCompleted;

  void markCompleted(){
    _isCompleted = true;
  }

  //MARK: GENERATE
  /// Generate workout blocks based on style and duration
  Future<List<Block>> generateBlocks() async {
    // Generate warmup, main work, and cooldown blocks
    final warmupBlock = await _generateWarmupBlock();
    final mainBlocks = await _generateMainWorkBlocks();
    final cooldownBlock = await _generateCooldownBlock();

    // Combine all blocks and update local state for serialization callers
    final allBlocks = [warmupBlock, ...mainBlocks, cooldownBlock];
    blocks = allBlocks;
    return allBlocks;
  }

  Future<WarmupBlock> _generateWarmupBlock() async {
    return WarmupBlock(durationSec: (durationMinutes * 60 * WorkoutDuration.warmupPercent).round());
  }

  Future<CooldownBlock> _generateCooldownBlock() async {
    return CooldownBlock(durationSec: (durationMinutes * 60 * WorkoutDuration.cooldownPercent).round());
  }

  Future<List<ExerciseBlock>> _generateMainWorkBlocks() async {
    final patternsWithPrefs = style.mainWorkPatterns;
    if (patternsWithPrefs.isEmpty) return const <ExerciseBlock>[];

    final availableTimeSec = (durationMinutes * 60 * WorkoutDuration.mainWorkPercent).round();
    if (availableTimeSec <= 0) return const <ExerciseBlock>[];

    final blocks = <ExerciseBlock>[];
    final random = Random();
    final sets = style.calculateSets(durationMinutes);
    final reps = style.calculateReps(durationMinutes);
    final rest = style.calculateRestSeconds(durationMinutes);

    var usedTimeSec = 0;
    var patternIndex = 0;
    var consecutiveEmptyPatterns = 0;

    while (usedTimeSec < availableTimeSec) {
      if (consecutiveEmptyPatterns >= patternsWithPrefs.length) {
        break;
      }

      final patternWithPref = patternsWithPrefs[patternIndex % patternsWithPrefs.length];

      final exercises = await LoadExercisesService.getExercises(
        patternWithPref.pattern,
        preferCompound: patternWithPref.preferCompound,
      );

      if (exercises.isEmpty) {
        patternIndex++;
        consecutiveEmptyPatterns++;
        continue;
      }

      consecutiveEmptyPatterns = 0;

      final exercise = exercises[random.nextInt(exercises.length)];

      final block = ExerciseBlock(
        label: patternWithPref.pattern.name,
        exerciseId: exercise.id,
        displayName: exercise.name,
        sets: sets,
        reps: reps,
        restSecBetweenSets: rest,
      );

      final blockDuration = block.estimateDurationSec();
      if (usedTimeSec + blockDuration > availableTimeSec) {
        if (blocks.isEmpty) {
          blocks.add(block);
        }
        break;
      }

      blocks.add(block);
      usedTimeSec += blockDuration;
      patternIndex++;
    }

    if (blocks.isEmpty) {
      final patternNames = patternsWithPrefs.map((p) => p.pattern.name).join(', ');
      throw StateError('No exercises available for patterns: $patternNames');
    }

    return blocks;
  }

  factory Workout.fromJson(Map<String, dynamic> json) {
    List<Block>? blocks;
    if (json['blocks'] != null) {
      blocks = (json['blocks'] as List<dynamic>)
          .map((blockJson) => Block.fromJson(blockJson))
          .toList();
    }

    // Handle legacy data: if durationMinutes is null, derive from type
    final type = sessionTypeFromString(json[PlanFields.typeField] as String);
    final durationMinutes = json['durationMinutes'] as int? ??
        (type == SessionType.micro ? 15 : 45);

    return Workout(
      date: json[PlanFields.dateField] != null ? DateTime.parse(json[PlanFields.dateField] as String) : null,
      type: type,
      style: WorkoutStyle.fromJson(json[PlanFields.styleField] as String),
      durationMinutes: durationMinutes,
      isCompleted: json[PlanFields.isCompletedField] as bool? ?? false,
      blocks: blocks,
    );
  }

  Map<String, dynamic> toJson() => {
    PlanFields.dateField: date?.toIso8601String(),
    PlanFields.typeField: sessionTypeToString(type),
    PlanFields.styleField: style.toJson(),
    'durationMinutes': durationMinutes,
    PlanFields.isCompletedField: _isCompleted,
    'blocks': blocks?.map((block) => block.toJson()).toList(),
  };
}
