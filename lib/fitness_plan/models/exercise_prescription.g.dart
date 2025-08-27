// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_prescription.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExercisePrescription _$ExercisePrescriptionFromJson(
  Map<String, dynamic> json,
) => ExercisePrescription(
  exerciseId: json['exercise_id'] as String,
  substitutions:
      (json['substitutions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
  sets: (json['sets'] as num?)?.toInt() ?? 3,
  reps:
      json['reps'] == null
          ? null
          : RepSpec.fromJson(json['reps'] as Map<String, dynamic>),
  timeSec: (json['time_sec'] as num?)?.toInt(),
  intensity:
      json['intensity'] == null
          ? null
          : Intensity.fromJson(json['intensity'] as Map<String, dynamic>),
  restSec: (json['rest_sec'] as num?)?.toInt() ?? 90,
  tempo: json['tempo'] as String?,
  cues: (json['cues'] as List<dynamic>?)?.map((e) => e as String).toList(),
  progression:
      json['progression'] == null
          ? null
          : Progression.fromJson(json['progression'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ExercisePrescriptionToJson(
  ExercisePrescription instance,
) => <String, dynamic>{
  'exercise_id': instance.exerciseId,
  'substitutions': instance.substitutions,
  'sets': instance.sets,
  'reps': instance.reps,
  'time_sec': instance.timeSec,
  'intensity': instance.intensity,
  'rest_sec': instance.restSec,
  'tempo': instance.tempo,
  'cues': instance.cues,
  'progression': instance.progression,
};
