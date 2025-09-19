enum SessionType {
  micro('Micro', '🏃‍♂️'),
  full('Full', '💪');

  const SessionType(this.displayName, this.icon);

  final String displayName;
  final String icon;

  String toJson() => name;

  static SessionType fromJson(String value) {
    final normalized = value.toLowerCase();
    switch (normalized) {
      case 'micro':
        return SessionType.micro;
      case 'full':
      case 'macro':
        return SessionType.full;
      default:
        throw ArgumentError('Invalid session type: $value');
    }
  }
}

SessionType sessionTypeFromString(String value) => SessionType.fromJson(value);

String sessionTypeToString(SessionType type) => type.toJson();
