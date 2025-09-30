enum ExerciseCategory {
  cardio,
  strength,
  flexibility,
  balance,
  functional;

  String get displayName {
    switch (this) {
      case ExerciseCategory.cardio:
        return 'Cardio';
      case ExerciseCategory.strength:
        return 'Strength';
      case ExerciseCategory.flexibility:
        return 'Flexibility';
      case ExerciseCategory.balance:
        return 'Balance';
      case ExerciseCategory.functional:
        return 'Functional';
    }
  }

  String get icon {
    switch (this) {
      case ExerciseCategory.cardio:
        return '❤️';
      case ExerciseCategory.strength:
        return '💪';
      case ExerciseCategory.flexibility:
        return '🧘';
      case ExerciseCategory.balance:
        return '🤸';
      case ExerciseCategory.functional:
        return '🔧';
    }
  }
}

ExerciseCategory exerciseStyleFromString(String value) {
  switch (value.toLowerCase()) {
    case 'cardio':
      return ExerciseCategory.cardio;
    case 'strength':
      return ExerciseCategory.strength;
    case 'flexibility':
      return ExerciseCategory.flexibility;
    case 'balance':
      return ExerciseCategory.balance;
    case 'functional':
      return ExerciseCategory.functional;
    default:
      throw ArgumentError('Invalid exercise style: $value');
  }
}

String exerciseStyleToString(ExerciseCategory style) {
  return style.name;
}