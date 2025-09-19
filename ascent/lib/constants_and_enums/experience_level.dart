enum ExperienceLevel { novice, intermediate, advanced }

ExperienceLevel expFromString(String? s) {
  switch (s) {
    case 'intermediate': return ExperienceLevel.intermediate;
    case 'advanced': return ExperienceLevel.advanced;
    default: return ExperienceLevel.novice;
  }
}

String expToString(ExperienceLevel e) {
  switch (e) {
    case ExperienceLevel.novice: return 'novice';
    case ExperienceLevel.intermediate: return 'intermediate';
    case ExperienceLevel.advanced: return 'advanced';
  }
}