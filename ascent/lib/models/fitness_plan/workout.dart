import '../../constants_and_enums/session_type.dart';
import '../../constants_and_enums/constants.dart';
import '../../constants_and_enums/workout_enums/workout_style_enum.dart';

class Workout{

  DateTime? date; //Sunday date of the week
  SessionType type; // Micro or full workout
  WorkoutStyle style; // Training style using enum for type safety
  bool _isCompleted = false;

  Workout({
    this.date,
    required this.type,
    required this.style,
    bool isCompleted = false,
  }) : _isCompleted = isCompleted;

  get isCompleted => _isCompleted;
  
  void markCompleted(){
    _isCompleted = true;
  }

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      date: json[PlanFields.dateField] != null ? DateTime.parse(json[PlanFields.dateField] as String) : null,
      type: sessionTypeFromString(json[PlanFields.typeField] as String),
      style: WorkoutStyle.fromJson(json[PlanFields.styleField] as String),
      isCompleted: json[PlanFields.isCompletedField] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    PlanFields.dateField: date?.toIso8601String(),
    PlanFields.typeField: sessionTypeToString(type),
    PlanFields.styleField: style.toJson(),
    PlanFields.isCompletedField: _isCompleted,
  };
}
