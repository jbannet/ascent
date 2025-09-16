enum ExerciseStyle {
  cardio,
  strength,
  flexibility,
  balance,
  functional;

  String get displayName {
    switch (this) {
      case ExerciseStyle.cardio:
        return 'Cardio';
      case ExerciseStyle.strength:
        return 'Strength';
      case ExerciseStyle.flexibility:
        return 'Flexibility';
      case ExerciseStyle.balance:
        return 'Balance';
      case ExerciseStyle.functional:
        return 'Functional';
    }
  }

  String get icon {
    switch (this) {
      case ExerciseStyle.cardio:
        return '❤️';
      case ExerciseStyle.strength:
        return '💪';
      case ExerciseStyle.flexibility:
        return '🧘';
      case ExerciseStyle.balance:
        return '🤸';
      case ExerciseStyle.functional:
        return '🔧';
    }
  }
}

ExerciseStyle exerciseStyleFromString(String value) {
  switch (value.toLowerCase()) {
    case 'cardio':
      return ExerciseStyle.cardio;
    case 'strength':
      return ExerciseStyle.strength;
    case 'flexibility':
      return ExerciseStyle.flexibility;
    case 'balance':
      return ExerciseStyle.balance;
    case 'functional':
      return ExerciseStyle.functional;
    default:
      throw ArgumentError('Invalid exercise style: $value');
  }
}

String exerciseStyleToString(ExerciseStyle style) {
  return style.name;
}