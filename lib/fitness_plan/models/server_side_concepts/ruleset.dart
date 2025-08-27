import 'readiness_adjustment.dart';
import '../../enums/missed_session_policy.dart';

class Ruleset {
  final ReadinessAdjustment readinessAdjustment;
  final int deloadEveryWeeks;
  final MissedSessionPolicy missedSessionPolicy;

  Ruleset({
    ReadinessAdjustment? readinessAdjustment,
    this.deloadEveryWeeks = 4,
    this.missedSessionPolicy = MissedSessionPolicy.autoRescheduleWithinWeek,
  }) : readinessAdjustment = readinessAdjustment ?? ReadinessAdjustment();

  factory Ruleset.fromJson(Map<String, dynamic> json) => Ruleset(
    readinessAdjustment: json['readiness_adjustment'] != null
        ? ReadinessAdjustment.fromJson(Map<String, dynamic>.from(json['readiness_adjustment']))
        : ReadinessAdjustment(),
    deloadEveryWeeks: (json['deload_every_weeks'] as int?) ?? 4,
    missedSessionPolicy: missedPolicyFromString(json['missed_session_policy'] as String?),
  );

  Map<String, dynamic> toJson() => {
    'readiness_adjustment': readinessAdjustment.toJson(),
    'deload_every_weeks': deloadEveryWeeks,
    'missed_session_policy': missedPolicyToString(missedSessionPolicy),
  };
}