import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/plan.dart';
import '../enums/session_status.dart';
import '../../../routing/route_names.dart';

class WeekView extends StatelessWidget {
  final Plan plan;
  final int weekIndex;
  const WeekView({super.key, required this.plan, required this.weekIndex});

  @override
  Widget build(BuildContext context) {
    final week = plan.weeks.firstWhere((w) => w.weekIndex == weekIndex);
    return Scaffold(
      appBar: AppBar(title: Text('Week $weekIndex')),
      body: ListView.separated(
        itemCount: week.days.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final d = week.days[i];
          final sess = plan.sessions.firstWhere((s) => s.id == d.sessionId);
          return ListTile(
            leading: Text(_weekdayLabel(d.dow)),
            title: Text(sess.title),
            subtitle: Text(_statusText(d.status)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(
              RouteNames.dayPath(plan.planId, weekIndex, d.dow.name),
              extra: plan,
            ),
          );
        },
      ),
    );
  }

  String _weekdayLabel(d) => {
    'mon': 'Mon', 'tue': 'Tue', 'wed': 'Wed', 'thu': 'Thu',
    'fri': 'Fri', 'sat': 'Sat', 'sun': 'Sun'
  }[d.toString().split('.').last] ?? 'Unknown';
  
  String _statusText(SessionStatus s) => s.name;
}