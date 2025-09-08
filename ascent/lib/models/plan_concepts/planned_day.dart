import '../../enums/day_of_week.dart';
import '../../enums/session_status.dart';

class PlannedDay {
  final DayOfWeek dow;
  final String sessionId;
  final SessionStatus status;
  final DateTime? changedAt;
  final String changedReason;

  PlannedDay({
    required this.dow,
    required this.sessionId,
    this.status = SessionStatus.planned,
    this.changedAt,
    this.changedReason = '',
  });

  factory PlannedDay.fromJson(Map<String, dynamic> json) => PlannedDay(
    dow: dowFromString(json['dow'] as String),
    sessionId: json['session_id'] as String,
    status: statusFromString(json['status'] as String?),
    changedAt: _nullableDateFromJson(json['changed_at'] as String?),
    changedReason: (json['changed_reason'] as String?) ?? '',
  );

  Map<String, dynamic> toJson() => {
    'dow': dowToString(dow),
    'session_id': sessionId,
    'status': statusToString(status),
    'changed_at': _nullableDateToJson(changedAt),
    'changed_reason': changedReason,
  };
}

DateTime? _nullableDateFromJson(String? value) => value == null ? null : DateTime.parse(value);
String? _nullableDateToJson(DateTime? value) => value?.toIso8601String();