import 'dart:math';
import '../../constants_and_enums/session_type.dart';
import '../../constants_and_enums/constants.dart';
import '../../constants_and_enums/workout_enums/workout_style_enum.dart';
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

    // Combine all blocks
    return [warmupBlock, ...mainBlocks, cooldownBlock];
  }

  Future<WarmupBlock> _generateWarmupBlock() async {
    return WarmupBlock(durationSec: (durationMinutes * 60 * WorkoutDuration.warmupPercent).round());
  }

  Future<CooldownBlock> _generateCooldownBlock() async {
    return CooldownBlock(durationSec: (durationMinutes * 60 * WorkoutDuration.cooldownPercent).round());
  }

  Future<List<ExerciseBlock>> _generateMainWorkBlocks() async {
    final patternsWithPrefs = style.mainWorkPatterns;
    final blocks = <ExerciseBlock>[];
    final random = Random();

    // Calculate available time for main work (73% of total)
    final availableTimeSec = (durationMinutes * 60 * WorkoutDuration.mainWorkPercent).round();
    int usedTimeSec = 0;

    // Keep adding exercises until we run out of time
    int patternIndex = 0;
    int consecutiveEmptyPatterns = 0;

    while (usedTimeSec < availableTimeSec) {
      // Safety check: if all patterns are empty, break to prevent infinite loop
      if (consecutiveEmptyPatterns >= patternsWithPrefs.length) {
        break;
      }

      // Cycle through movement patterns
      final patternWithPref = patternsWithPrefs[patternIndex % patternsWithPrefs.length];

      // Get exercises filtered by mechanic preference
      final exercises = await LoadExercisesService.getExercises(
        patternWithPref.pattern,
        preferCompound: patternWithPref.preferCompound,
      );

      if (exercises.isEmpty) {
        // Skip to next pattern if no exercises found
        patternIndex++;
        consecutiveEmptyPatterns++;
        continue;
      }

      // Reset empty pattern counter - we found exercises
      consecutiveEmptyPatterns = 0;

      // Select random exercise from filtered list
      final exercise = exercises[random.nextInt(exercises.length)];

      // Create block with exercise
      final sets = style.calculateSets(durationMinutes);
      final reps = style.calculateReps(durationMinutes);
      final rest = style.calculateRestSeconds(durationMinutes);

      final block = ExerciseBlock(
        label: patternWithPref.pattern.name,
        exerciseId: exercise.id,
        displayName: exercise.name,
        sets: sets,
        reps: reps,
        restSecBetweenSets: rest,
      );

      final blockDuration = block.estimateDurationSec();

      // Check if adding this block would go too far over
      if (usedTimeSec + blockDuration > availableTimeSec * 1.10) {
        // If we have at least one block and this pushes us too far over, stop
        if (blocks.isNotEmpty) {
          break;
        }
        // If this is the first block and it's too big, add it anyway and stop
        blocks.add(block);
        break;
      }

      blocks.add(block);
      usedTimeSec += blockDuration;
      patternIndex++;
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
