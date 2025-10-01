import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'models/fitness_profile_model/fitness_profile.dart';
import 'routing/route_names.dart';
import 'services_and_utilities/app_state/app_state.dart';
import 'services_and_utilities/local_storage/local_storage_service.dart';
import 'temporary_mapping_tool.dart';
import 'workflow_views/onboarding_workflow/question_bank/registry/question_bank.dart';

/// Temporary development navigation screen to access all views during development
class TemporaryNavigatorView extends StatelessWidget {
  const TemporaryNavigatorView({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final featureOrder = appState.featureOrder;

    final summaryProfile = appState.profile;
    final planForNavigation = appState.plan;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Development Navigator'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Choose a view to test:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          _buildNavigationTile(
            context,
            title: 'Onboarding Survey',
            subtitle: 'Test the onboarding survey flow',
            icon: Icons.assignment,
            onTap: () => context.push('/onboarding'),
          ),

          _buildNavigationTile(
            context,
            title: 'Launch Real App',
            subtitle: 'Navigate using current saved state',
            icon: Icons.play_circle,
            onTap: () => context.go('/real'),
          ),

          _buildNavigationTile(
            context,
            title: 'Onboarding Summary',
            subtitle: 'View fitness profile summary after onboarding',
            icon: Icons.analytics,
            onTap: summaryProfile != null
                ? () => context.go('/onboarding-summary')
                : () => _showMissingStateSnack(
                      context,
                      'Complete onboarding to view your summary.',
                    ),
          ),

          _buildNavigationTile(
            context,
            title: 'Plan View',
            subtitle: 'View the fitness plan overview',
            icon: Icons.fitness_center,
            onTap: planForNavigation != null
                ? () => context.go(RouteNames.planPath())
                : () => _showMissingStateSnack(
                      context,
                      'Generate a plan from the summary before opening the plan view.',
                    ),
          ),
          _buildNavigationTile(
            context,
            title: 'LLM Rewrite Test',
            subtitle: 'Stream rewritten recommendations in different tones',
            icon: Icons.auto_awesome,
            onTap: () => context.push('/llm-test'),
          ),

          const Divider(),
         const Text(
            'Development Tools:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          _buildNavigationTile(
            context,
            title: 'Body Map Coordinate Mapper',
            subtitle: 'Map body part coordinates on gender-specific images',
            icon: Icons.touch_app,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const TemporaryMappingTool(),
              ),
            ),
          ),

         const Divider(),
          const Text(
            'App State Scenarios:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildScenarioCard(context, featureOrder),
        ],
      ),
    );
  }

  Widget _buildNavigationTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: Icon(icon, size: 32, color: Colors.blue),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildScenarioCard(BuildContext context, List<String> featureOrder) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick-load scenarios',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final appState = context.read<AppState>();
                    _resetQuestionBank();
                    await LocalStorageService.saveAnswers({});
                    await appState.clearAll();
                  },
                  child: const Text('No onboarding data'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final appState = context.read<AppState>();
                    final answers = _generateCompleteAnswers();
                    QuestionBank.fromJson(answers);
                    await LocalStorageService.saveAnswers(answers);

                    final profile = FitnessProfile.createFitnessProfileFromSurvey(
                      featureOrder,
                      answers,
                    );

                    await appState.setProfile(
                      profile,
                      regeneratePlan: false,
                    );
                    await appState.clearPlan();
                  },
                  child: const Text('Profile only (no plan)'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final appState = context.read<AppState>();
                    final answers = _generateCompleteAnswers();
                    QuestionBank.fromJson(answers);
                    await LocalStorageService.saveAnswers(answers);

                    final profile = FitnessProfile.createFitnessProfileFromSurvey(
                      featureOrder,
                      answers,
                    );

                    await appState.setProfile(profile);
                  },
                  child: const Text('Profile + plan'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Map<String, dynamic> _generateCompleteAnswers() {
    final answers = <String, dynamic>{
      'age': '1985-06-15',
      'gender': 'female',
      'height': 65.0, // inches
      'weight': 150.0, // pounds
      'primary_motivation': 'better_health',
      'progress_tracking': 'weekly_check_ins',
      'fitness_goals': ['better_health', 'build_muscle'],
      'Q4': {
        'distanceMiles': 1.25,
        'timeMinutes': 12,
        'selectedUnit': 'miles',
      },
      'Q4A': 'no',
      'Q4B': [],
      'Q5': 20.0, // pushups - updated to 20
      'Q6': 20.0, // squats - added with value 20
      'Q6A': 'yes',
      'Q6B': 'pass', // balance test result
      'glp1_medications': 'no',
      'sleep_hours': 7.0,
      'current_exercise_days': 2,
      'stretching_days': 3,
      'sedentary_job': 'yes',
      'sugary_treats': 2.0, // treats per day (0-15)
      'sodas': 1.0, // drinks per day (0-15)
      'grains': 6.0, // servings per day (0-15)
      'alcohol': 3.0, // drinks per week (0-20)
      'session_commitment': {
        'full_sessions': 3,
        'micro_sessions': 2,
      },
      'Q1': 'none',
      'Q2': 'none',
      'Q10': 'resistance_bands',
      'Q11': 'home',
    };

    QuestionBank.fromJson(answers);
    return QuestionBank.toJson();
  }

  void _resetQuestionBank() {
    final questions = QuestionBank.getAllQuestions();
    for (final question in questions) {
      question.fromJson({'id': question.id, 'answer': null});
    }
  }

  void _showMissingStateSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

}
