import 'block_step.dart';

class ExercisePrescriptionStep extends BlockStep {
  final String exerciseId;
  final String displayName;
  final int sets;
  final int reps;
  final int restSecBetweenSets;
  final int? repDurationSec; // Optional: time per rep (e.g., for holds)

  ExercisePrescriptionStep({
    required this.exerciseId,
    required this.displayName,
    required this.sets,
    required this.reps,
    required this.restSecBetweenSets,
    this.repDurationSec,
  });

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
        'exerciseId': exerciseId,
        'displayName': displayName,
        'sets': sets,
        'reps': reps,
        'restSecBetweenSets': restSecBetweenSets,
        'repDurationSec': repDurationSec,
      };

  factory ExercisePrescriptionStep.fromJson(Map<String, dynamic> json) {
    return ExercisePrescriptionStep(
      exerciseId: json['exerciseId'] as String,
      displayName: json['displayName'] as String,
      sets: json['sets'] as int,
      reps: json['reps'] as int,
      restSecBetweenSets: json['restSecBetweenSets'] as int,
      repDurationSec: json['repDurationSec'] as int?,
    );
  }
}
