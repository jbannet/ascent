/// Utility function to get the Sunday of the current week
DateTime getThisSunday() {
  final now = DateTime.now();
  // DateTime.weekday: Monday = 1, Sunday = 7
  int daysSinceLastSunday = now.weekday % 7;
  return now.subtract(Duration(days: daysSinceLastSunday));
}
