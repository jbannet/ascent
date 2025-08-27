import 'package:json_annotation/json_annotation.dart';
import 'rep_spec.dart';
import 'intensity.dart';
import 'progression.dart';

part 'exercise_prescription.g.dart';

@JsonSerializable()
class ExercisePrescription {
  @JsonKey(name: 'exercise_id')
  final String exerciseId;
  
  final List<String> substitutions;
  final int sets;
  final RepSpec reps; // fixed or range
  
  @JsonKey(name: 'time_sec')
  final int? timeSec; // optional for time-based work
  
  final Intensity intensity;
  
  @JsonKey(name: 'rest_sec')
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

  factory ExercisePrescription.fromJson(Map<String, dynamic> json) => _$ExercisePrescriptionFromJson(json);
  Map<String, dynamic> toJson() => _$ExercisePrescriptionToJson(this);
}