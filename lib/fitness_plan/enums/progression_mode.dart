enum ProgressionMode { linear, doubleProgression, rirGuided, deload, none }

ProgressionMode progressionFromString(String? s) {
  switch (s) {
    case 'linear': return ProgressionMode.linear;
    case 'double_progression':
    case 'doubleProgression': return ProgressionMode.doubleProgression;
    case 'rir_guided':
    case 'rirGuided': return ProgressionMode.rirGuided;
    case 'deload': return ProgressionMode.deload;
    default: return ProgressionMode.none;
  }
}

String progressionToString(ProgressionMode m) {
  switch (m) {
    case ProgressionMode.linear: return 'linear';
    case ProgressionMode.doubleProgression: return 'doubleProgression';
    case ProgressionMode.rirGuided: return 'rirGuided';
    case ProgressionMode.deload: return 'deload';
    case ProgressionMode.none: return 'none';
  }
}