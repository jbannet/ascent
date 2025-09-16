enum SessionType {
  micro,
  macro;

  String get displayName {
    switch (this) {
      case SessionType.micro:
        return 'Micro';
      case SessionType.macro:
        return 'Macro';
    }
  }

  String get icon {
    switch (this) {
      case SessionType.micro:
        return '🏃‍♂️';
      case SessionType.macro:
        return '💪';
    }
  }
}

SessionType sessionTypeFromString(String value) {
  switch (value.toLowerCase()) {
    case 'micro':
      return SessionType.micro;
    case 'macro':
      return SessionType.macro;
    default:
      throw ArgumentError('Invalid session type: $value');
  }
}

String sessionTypeToString(SessionType type) {
  return type.name;
}