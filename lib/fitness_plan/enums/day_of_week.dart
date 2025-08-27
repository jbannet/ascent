enum DayOfWeek { mon, tue, wed, thu, fri, sat, sun }

DayOfWeek dowFromString(String s) => DayOfWeek.values.firstWhere((d)=> d.toString().split('.').last == s);

String dowToString(DayOfWeek d) => d.toString().split('.').last;