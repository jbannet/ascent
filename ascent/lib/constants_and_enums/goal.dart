enum Goal {
  getStronger,
  loseFat,
  generalStrengthFitness,
  buildMuscle,
  endurance,
  mobilityHealth,
}

Goal goalFromString(String s) {
  switch (s) {
    case 'get_stronger': return Goal.getStronger;
    case 'lose_fat': return Goal.loseFat;
    case 'general_strength_fitness': return Goal.generalStrengthFitness;
    case 'build_muscle': return Goal.buildMuscle;
    case 'endurance': return Goal.endurance;
    case 'mobility_health': return Goal.mobilityHealth;
    default: return Goal.generalStrengthFitness;
  }
}

String goalToString(Goal g) {
  switch (g) {
    case Goal.getStronger: return 'get_stronger';
    case Goal.loseFat: return 'lose_fat';
    case Goal.generalStrengthFitness: return 'general_strength_fitness';
    case Goal.buildMuscle: return 'build_muscle';
    case Goal.endurance: return 'endurance';
    case Goal.mobilityHealth: return 'mobility_health';
  }
}