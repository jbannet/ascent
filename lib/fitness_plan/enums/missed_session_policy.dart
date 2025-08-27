enum MissedSessionPolicy { autoRescheduleWithinWeek, carryOverNextWeek, drop }

MissedSessionPolicy missedPolicyFromString(String? s) {
  switch (s) {
    case 'carry_over_next_week':
    case 'carryOverNextWeek': return MissedSessionPolicy.carryOverNextWeek;
    case 'drop': return MissedSessionPolicy.drop;
    default: return MissedSessionPolicy.autoRescheduleWithinWeek;
  }
}

String missedPolicyToString(MissedSessionPolicy m) {
  switch (m) {
    case MissedSessionPolicy.autoRescheduleWithinWeek: return 'auto_reschedule_within_week';
    case MissedSessionPolicy.carryOverNextWeek: return 'carry_over_next_week';
    case MissedSessionPolicy.drop: return 'drop';
  }
}