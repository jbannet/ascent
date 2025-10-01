import 'block.dart';

class ExerciseBlock extends Block {
  final String exerciseId;
  final String displayName;
  final int sets;
  final int reps;
  final int restSecBetweenSets;
  final int? repDurationSec; // Optional: time per rep (e.g., for holds)

  ExerciseBlock({
    required String label,
    required this.exerciseId,
    required this.displayName,
    required this.sets,
    required this.reps,
    required this.restSecBetweenSets,
    this.repDurationSec,
  }) : super(label: label);

  @override
  int estimateDurationSec() {
    // Estimate: sets * (reps * repDuration + rest between sets)
    // Default rep duration is 3 seconds if not specified
    final repDur = repDurationSec ?? 3;
    final workTime = sets * reps * repDur;
    final restTime = (sets - 1) * restSecBetweenSets;
    return workTime + restTime;
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': 'exercise',
        'label': label,
        'exerciseId': exerciseId,
        'displayName': displayName,
        'sets': sets,
        'reps': reps,
        'restSecBetweenSets': restSecBetweenSets,
        'repDurationSec': repDurationSec,
      };

  factory ExerciseBlock.fromJson(Map<String, dynamic> json) {
    return ExerciseBlock(
      label: json['label'] as String,
      exerciseId: json['exerciseId'] as String,
      displayName: json['displayName'] as String,
      sets: json['sets'] as int,
      reps: json['reps'] as int,
      restSecBetweenSets: json['restSecBetweenSets'] as int,
      repDurationSec: json['repDurationSec'] as int?,
    );
  }
}
