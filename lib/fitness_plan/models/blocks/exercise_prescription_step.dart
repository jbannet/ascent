import 'block_step.dart';
import '../../enums/block_step_kind.dart';
import '../../enums/item_mode.dart';

class ExercisePrescriptionStep implements BlockStep {
  @override
  BlockStepKind get kind => BlockStepKind.exercise;

  final String exerciseId;
  final String displayName;

  final ItemMode mode;
  final int sets;
  final int? reps;              // when mode == reps
  final int? timeSecPerSet;     // when mode == time

  final int restSecBetweenSets; // applies (sets-1) times
  final String? tempo;
  final List<String> cues;

  // estimation knobs (client-only)
  final double secondsPerRep;   // default pacing for reps
  final int setupTransitionSec; // per set

  ExercisePrescriptionStep({
    required this.exerciseId,
    required this.displayName,
    required this.mode,
    required this.sets,
    this.reps,
    this.timeSecPerSet,
    this.restSecBetweenSets = 90,
    this.tempo,
    List<String>? cues,
    this.secondsPerRep = 3.0,
    this.setupTransitionSec = 5,
  }) : cues = cues ?? const <String>[],
       assert(
         (mode == ItemMode.reps && reps != null) ||
         (mode == ItemMode.time && timeSecPerSet != null),
         'Provide reps for reps-mode or timeSecPerSet for time-mode',
       );

  @override
  int estimateDurationSec() {
    final perSetWork = (mode == ItemMode.time)
        ? (timeSecPerSet ?? 0)
        : ((reps ?? 0) * secondsPerRep).round();

    final work   = perSetWork * sets;
    final rests  = restSecBetweenSets * (sets > 1 ? (sets - 1) : 0);
    final setups = setupTransitionSec * sets;
    return work + rests + setups;
  }

  factory ExercisePrescriptionStep.fromJson(Map<String, dynamic> json) {
    final mode = (json['mode'] == 'time') ? ItemMode.time : ItemMode.reps;
    return ExercisePrescriptionStep(
      exerciseId: json['exercise_id'] as String,
      displayName: (json['display_name'] as String?) ?? json['exercise_id'] as String,
      mode: mode,
      sets: json['sets'] as int,
      reps: json['reps'] as int?,
      timeSecPerSet: json['time_sec_per_set'] as int?,
      restSecBetweenSets: (json['rest_sec_between_sets'] as int?) ?? 90,
      tempo: json['tempo'] as String?,
      cues: (json['cues'] as List?)?.map((e) => e.toString()).toList(),
      secondsPerRep: (json['seconds_per_rep'] as num?)?.toDouble() ?? 3.0,
      setupTransitionSec: (json['setup_transition_sec'] as int?) ?? 5,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'kind': 'exercise',
    'exercise_id': exerciseId,
    'display_name': displayName,
    'mode': mode == ItemMode.time ? 'time' : 'reps',
    'sets': sets,
    'reps': reps,
    'time_sec_per_set': timeSecPerSet,
    'rest_sec_between_sets': restSecBetweenSets,
    'tempo': tempo,
    'cues': cues,
    'seconds_per_rep': secondsPerRep,
    'setup_transition_sec': setupTransitionSec,
  };
}