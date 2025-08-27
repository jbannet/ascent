enum SessionStatus { planned, completed, skipped }

SessionStatus statusFromString(String? s) {
  switch (s) {
    case 'completed': return SessionStatus.completed;
    case 'skipped': return SessionStatus.skipped;
    default: return SessionStatus.planned;
  }
}

String statusToString(SessionStatus s) {
  switch (s) {
    case SessionStatus.planned: return 'planned';
    case SessionStatus.completed: return 'completed';
    case SessionStatus.skipped: return 'skipped';
  }
}