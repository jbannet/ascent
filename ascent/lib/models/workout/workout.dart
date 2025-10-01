import '../../constants_and_enums/session_type.dart';
import '../../constants_and_enums/constants.dart';
import '../../constants_and_enums/workout_enums/workout_style_enum.dart';
import '../../constants_and_enums/workout_enums/movement_pattern.dart';
import '../../services_and_utilities/exercises/load_exercises_service.dart';
import 'block.dart';
import 'exercise.dart';
import 'warmup_step.dart';
import 'cooldown_step.dart';
import 'exercise_prescription_step.dart';

class Workout{

  DateTime? date; //Sunday date of the week
  SessionType type; // Micro or full workout
  WorkoutStyle style; // Training style using enum for type safety
  bool _isCompleted = false;
  List<Block>? blocks; // Generated workout blocks

  Workout({
    this.date,
    required this.type,
    required this.style,
    bool isCompleted = false,
    this.blocks,
  }) : _isCompleted = isCompleted;

  get isCompleted => _isCompleted;
  
  void markCompleted(){
    _isCompleted = true;
  }

  /// Generate workout blocks based on style and duration
  Future<List<Block>> generateBlocks() async {
    // Determine target duration based on session type
    final durationMinutes = type == SessionType.micro ? 12 : 60;

    // Generate warmup, main work, and cooldown blocks
    final warmupBlock = await _generateWarmupBlock(durationMinutes);
    final mainBlocks = await _generateMainWorkBlocks(durationMinutes);
    final cooldownBlock = await _generateCooldownBlock(durationMinutes);

    // Combine all blocks
    final allBlocks = [warmupBlock, ...mainBlocks, cooldownBlock];

    // Validate and adjust duration if needed
    final totalDuration = allBlocks.fold<int>(
      0,
      (sum, block) => sum + block.estimateDurationSec(),
    );
    final targetDuration = durationMinutes * 60;

    // If over by 10%, adjust
    if (totalDuration > targetDuration * 1.10) {
      _adjustBlocksForDuration(mainBlocks, targetDuration, totalDuration);
    }

    return allBlocks;
  }

  Future<Block> _generateWarmupBlock(int durationMinutes) async {
    final patterns = style.warmupPatterns;
    final warmupDuration = (durationMinutes * 60 * 0.15).round(); // 15% of total
    final perPatternDuration = (warmupDuration / patterns.length).round();

    final items = patterns.map((pattern) {
      return WarmupStep(
        pattern: pattern,
        durationSec: perPatternDuration,
      );
    }).toList();

    return Block(
      label: 'Warmup',
      type: BlockType.warmup,
      items: items,
    );
  }

  Future<Block> _generateCooldownBlock(int durationMinutes) async {
    final patterns = style.cooldownPatterns;
    final cooldownDuration = (durationMinutes * 60 * 0.12).round(); // 12% of total
    final perPatternDuration = (cooldownDuration / patterns.length).round();

    final items = patterns.map((pattern) {
      return CooldownStep(
        pattern: pattern,
        durationSec: perPatternDuration,
      );
    }).toList();

    return Block(
      label: 'Cooldown',
      type: BlockType.cooldown,
      items: items,
    );
  }

  Future<List<Block>> _generateMainWorkBlocks(int durationMinutes) async {
    final patterns = style.mainWorkPatterns;
    final blocks = <Block>[];

    // Determine number of patterns to use based on compression strategy
    final patternsToUse = _selectPatternsForDuration(patterns, durationMinutes);

    for (final pattern in patternsToUse) {
      // Load exercises for this pattern
      final exercises = await _loadExercisesWithFallback(pattern);

      if (exercises.isEmpty) {
        // Skip pattern if no exercises found
        continue;
      }

      // Select best exercise
      final exercise = _selectBestExercise(exercises);

      // Create block with exercise
      final sets = style.calculateSets(durationMinutes);
      final reps = style.calculateReps(durationMinutes);
      final rest = style.calculateRestSeconds(durationMinutes);

      final block = Block(
        label: pattern.name,
        type: BlockType.main,
        items: [
          ExercisePrescriptionStep(
            exerciseId: exercise.id,
            displayName: exercise.name,
            sets: sets,
            reps: reps,
            restSecBetweenSets: rest,
          ),
        ],
      );

      blocks.add(block);
    }

    return blocks;
  }

  List<MovementPattern> _selectPatternsForDuration(
    List<MovementPattern> patterns,
    int durationMinutes,
  ) {
    if (durationMinutes <= 15) {
      // Micro workout: take first 2-3 patterns
      return patterns.take(2).toList();
    } else if (durationMinutes <= 30) {
      // Short workout: take first 3-4 patterns
      return patterns.take(patterns.length > 4 ? 4 : patterns.length).toList();
    } else {
      // Full workout: use all patterns
      return patterns;
    }
  }

  Future<List<Exercise>> _loadExercisesWithFallback(
    MovementPattern pattern,
  ) async {
    // Try primary query with style filter
    var exercises = await LoadExercisesService.loadExercisesForPattern(
      pattern,
      style.value,
    );

    if (exercises.isNotEmpty) return exercises;

    // Fallback 1: Remove style filter
    exercises = await LoadExercisesService.loadExercisesForPattern(pattern);

    if (exercises.isNotEmpty) return exercises;

    // Fallback 2: Try similar pattern
    final similarPattern = _getSimilarPattern(pattern);
    if (similarPattern != null) {
      exercises = await LoadExercisesService.loadExercisesForPattern(
        similarPattern,
      );
    }

    return exercises;
  }

  MovementPattern? _getSimilarPattern(MovementPattern pattern) {
    final similarPatterns = {
      MovementPattern.squat: MovementPattern.lunge,
      MovementPattern.hinge: MovementPattern.squat,
      MovementPattern.horizontalPush: MovementPattern.verticalPush,
      MovementPattern.horizontalPull: MovementPattern.verticalPull,
      MovementPattern.verticalPush: MovementPattern.horizontalPush,
      MovementPattern.verticalPull: MovementPattern.horizontalPull,
    };

    return similarPatterns[pattern];
  }

  Exercise _selectBestExercise(List<Exercise> exercises) {
    // Score each exercise
    final scored = exercises.map((exercise) {
      var score = 0;

      // Prefer compound movements
      if (exercise.mechanic == 'compound') score += 10;

      // Has instructions
      if (exercise.instructions.isNotEmpty) score += 3;

      return MapEntry(exercise, score);
    }).toList();

    // Sort by score descending
    scored.sort((a, b) => b.value.compareTo(a.value));

    // Return highest scored (or random from top tied)
    return scored.first.key;
  }

  void _adjustBlocksForDuration(
    List<Block> mainBlocks,
    int targetDuration,
    int currentDuration,
  ) {
    // Strategy 1: Reduce sets
    for (final block in mainBlocks) {
      for (final item in block.items) {
        if (item is ExercisePrescriptionStep) {
          if (item.sets > 1) {
            // Create new step with reduced sets (immutable pattern)
            final index = block.items.indexOf(item);
            block.items[index] = ExercisePrescriptionStep(
              exerciseId: item.exerciseId,
              displayName: item.displayName,
              sets: item.sets - 1,
              reps: item.reps,
              restSecBetweenSets: item.restSecBetweenSets,
              repDurationSec: item.repDurationSec,
            );
          }
        }
      }
    }

    // Check duration again
    final newDuration = mainBlocks.fold<int>(
      0,
      (sum, block) => sum + block.estimateDurationSec(),
    );

    // Strategy 2: Reduce rest if still over
    if (newDuration > targetDuration * 1.10) {
      for (final block in mainBlocks) {
        for (final item in block.items) {
          if (item is ExercisePrescriptionStep) {
            if (item.restSecBetweenSets > 30) {
              final index = block.items.indexOf(item);
              block.items[index] = ExercisePrescriptionStep(
                exerciseId: item.exerciseId,
                displayName: item.displayName,
                sets: item.sets,
                reps: item.reps,
                restSecBetweenSets: (item.restSecBetweenSets - 15).clamp(30, 180),
                repDurationSec: item.repDurationSec,
              );
            }
          }
        }
      }
    }
  }

  factory Workout.fromJson(Map<String, dynamic> json) {
    List<Block>? blocks;
    if (json['blocks'] != null) {
      blocks = (json['blocks'] as List<dynamic>)
          .map((blockJson) => Block.fromJson(blockJson))
          .toList();
    }

    return Workout(
      date: json[PlanFields.dateField] != null ? DateTime.parse(json[PlanFields.dateField] as String) : null,
      type: sessionTypeFromString(json[PlanFields.typeField] as String),
      style: WorkoutStyle.fromJson(json[PlanFields.styleField] as String),
      isCompleted: json[PlanFields.isCompletedField] as bool? ?? false,
      blocks: blocks,
    );
  }

  Map<String, dynamic> toJson() => {
    PlanFields.dateField: date?.toIso8601String(),
    PlanFields.typeField: sessionTypeToString(type),
    PlanFields.styleField: style.toJson(),
    PlanFields.isCompletedField: _isCompleted,
    'blocks': blocks?.map((block) => block.toJson()).toList(),
  };
}
