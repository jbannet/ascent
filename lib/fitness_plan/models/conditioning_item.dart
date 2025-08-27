class ConditioningItem {
  final String exerciseId;
  final int timeMin;
  final String? zone; // e.g., "easy"

  ConditioningItem({ required this.exerciseId, required this.timeMin, this.zone });

  factory ConditioningItem.fromJson(Map<String, dynamic> json) => ConditioningItem(
    exerciseId: json['exercise_id'] as String,
    timeMin: json['time_min'] as int,
    zone: json['zone'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'exercise_id': exerciseId,
    'time_min': timeMin,
    'zone': zone,
  };
}