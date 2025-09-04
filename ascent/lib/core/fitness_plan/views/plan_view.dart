import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/plan.dart';
import '../../../routing/route_names.dart';

class PlanView extends StatelessWidget {
  final Plan plan;
  const PlanView({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Plan')),
      body: ListView.builder(
        itemCount: plan.weeks.length,
        itemBuilder: (_, i) {
          final w = plan.weeks[i];
          final plannedDays = w.days.length;
          return ListTile(
            title: Text('Week ${w.weekIndex}'),
            subtitle: Text('$plannedDays sessions'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(
              RouteNames.weekPath(plan.planId, w.weekIndex),
              extra: plan,
            ),
          );
        },
      ),
    );
  }
}