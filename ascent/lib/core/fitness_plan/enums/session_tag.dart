enum SessionTag { fullBody, upper, lower, push, pull }

SessionTag sessionTagFromString(String s) {
  switch (s) {
    case 'upper': return SessionTag.upper;
    case 'lower': return SessionTag.lower;
    case 'push': return SessionTag.push;
    case 'pull': return SessionTag.pull;
    default: return SessionTag.fullBody;
  }
}

String sessionTagToString(SessionTag t) {
  switch (t) {
    case SessionTag.fullBody: return 'fullBody';
    case SessionTag.upper: return 'upper';
    case SessionTag.lower: return 'lower';
    case SessionTag.push: return 'push';
    case SessionTag.pull: return 'pull';
  }
}