import 'rep_spec.dart';
import 'intensity.dart';
import 'progression.dart';

class ExercisePrescription {
  final String exerciseId;
  final List<String> substitutions;
  final int sets;
  final RepSpec reps; // fixed or range
  final int? timeSec; // optional for time-based work
  final Intensity intensity;
  final int restSec;
  final String? tempo;
  final List<String> cues;
  final Progression progression;

  ExercisePrescription({
    required this.exerciseId,
    List<String>? substitutions,
    this.sets = 3,
    RepSpec? reps,
    this.timeSec,
    Intensity? intensity,
    this.restSec = 90,
    this.tempo,
    List<String>? cues,
    Progression? progression,
  })  : substitutions = substitutions ?? <String>[],
        reps = reps ?? RepSpec.fixed(10),
        intensity = intensity ?? Intensity.rir(target: 2),
        cues = cues ?? <String>[],
        progression = progression ?? Progression.doubleProgression(incrementLb: 5);

  factory ExercisePrescription.fromJson(Map<String, dynamic> json) => ExercisePrescription(
    exerciseId: json['exercise_id'] as String,
    substitutions: (json['substitutions'] as List<dynamic>? )?.map((e)=> e.toString()).toList() ?? <String>[],
    sets: (json['sets'] as int?) ?? 3,
    reps: RepSpec.fromAny(json['reps']),
    timeSec: json['time_sec'] as int?,
    intensity: json['intensity'] != null ? Intensity.fromJson(Map<String, dynamic>.from(json['intensity'])) : Intensity.rir(target: 2),
    restSec: (json['rest_sec'] as int?) ?? 90,
    tempo: json['tempo'] as String?,
    cues: (json['cues'] as List<dynamic>? )?.map((e)=> e.toString()).toList() ?? <String>[],
    progression: json['progression'] != null ? Progression.fromJson(Map<String, dynamic>.from(json['progression'])) : Progression.doubleProgression(incrementLb: 5),
  );

  Map<String, dynamic> toJson() => {
    'exercise_id': exerciseId,
    'substitutions': substitutions,
    'sets': sets,
    'reps': reps.toJson(),
    'time_sec': timeSec,
    'intensity': intensity.toJson(),
    'rest_sec': restSec,
    'tempo': tempo,
    'cues': cues,
    'progression': progression.toJson(),
  };
}