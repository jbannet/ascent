enum ItemMode { reps, time }

ItemMode itemModeFromString(String s) {
  switch (s) {
    case 'time': return ItemMode.time;
    default: return ItemMode.reps;
  }
}

String itemModeToString(ItemMode m) {
  switch (m) {
    case ItemMode.reps: return 'reps';
    case ItemMode.time: return 'time';
  }
}