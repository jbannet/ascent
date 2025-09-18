/// Utility function to get the Sunday date for a specific week index
/// given a start date (usually the start of a plan).
DateTime getSundayDateForWeekFromStart(DateTime startDate, int weekIndex) {
  // Calculate days since start for this week (weeks are 1-indexed)
  final daysSinceStart = (weekIndex - 1) * 7;
  final weekStartDate = startDate.add(Duration(days: daysSinceStart));

  // Find the Sunday of that week
  // DateTime.weekday: Monday = 1, Sunday = 7
  // We want Sunday = 0, so: (weekday % 7)
  int daysSinceLastSunday = weekStartDate.weekday % 7;
  return weekStartDate.subtract(Duration(days: daysSinceLastSunday));
}
