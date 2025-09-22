import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../../services_and_utilities/app_state/app_state.dart';
import '../../../../../theme/general_widgets/buttons/universal_elevated_button.dart';
import '../../../../../theme/general_widgets/buttons/universal_outlined_button.dart';

class SummaryActionButtons extends StatelessWidget {
  const SummaryActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: UniversalOutlinedButton(
              onPressed: () {
                // Navigate back to onboarding
                context.go('/onboarding');
              },
              child: const Text('Edit'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: UniversalElevatedButton(
              onPressed: () async {
                final appState = context.read<AppState>();
                await appState.generatePlan();
                if (!context.mounted) return;
                context.go('/plan');
              },
              child: const Text('Generate my plan'),
            ),
          ),
        ],
      ),
    );
  }
}