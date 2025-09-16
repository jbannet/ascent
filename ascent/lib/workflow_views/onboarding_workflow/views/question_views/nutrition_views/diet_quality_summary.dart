import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'diet_quality_chart.dart';
import '../../../question_bank/questions/nutrition/sugary_treats_question.dart';
import '../../../question_bank/questions/nutrition/sodas_question.dart';
import '../../../question_bank/questions/nutrition/grains_question.dart';
import '../../../question_bank/questions/nutrition/alcohol_question.dart';

/// Final diet quality summary shown after completing all nutrition questions.
/// 
/// Provides a complete overview of the user's nutrition profile with:
/// - Full 4-bar chart visualization
/// - Positive reinforcement and insights
/// - Personalized recommendations
/// - Next steps for the user
class DietQualitySummary extends StatelessWidget {
  final Map<String, dynamic> answers;
  final VoidCallback? onContinue;
  
  const DietQualitySummary({
    super.key,
    required this.answers,
    this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nutritionData = _getNutritionData();
    final insights = _generateInsights();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(theme),
          const SizedBox(height: 24),
          
          // Complete chart visualization
          DietQualityChart(
            nutritionData: nutritionData,
            activeMetrics: const ['sugary_treats', 'sodas', 'grains', 'alcohol'],
            showMascot: true,
            encouragementMessage: 'Your nutrition profile is complete! Here\'s what we learned. 🎉',
          ),
          
          const SizedBox(height: 32),
          
          // Insights section
          _buildInsightsSection(theme, insights),
          
          const SizedBox(height: 24),
          
          // Recommendations
          _buildRecommendations(theme),
          
          const SizedBox(height: 32),
          
          // Continue button
          if (onContinue != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Haptic feedback for completion
                  HapticFeedback.lightImpact();
                  onContinue!();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Continue to Fitness Planning',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Nutrition Profile',
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'We\'ve created a personalized nutrition overview to guide your fitness journey.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            height: 1.4,
          ),
        ),
      ],
    );
  }
  
  Widget _buildInsightsSection(ThemeData theme, List<NutritionInsight> insights) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Nutrition Insights',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        ...insights.map((insight) => _buildInsightCard(theme, insight)),
      ],
    );
  }
  
  Widget _buildInsightCard(ThemeData theme, NutritionInsight insight) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: insight.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: insight.color.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: insight.color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                insight.icon,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: insight.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRecommendations(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What This Means for Your Fitness',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.1),
                theme.colorScheme.primary.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.fitness_center,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Personalized for You',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Based on your nutrition profile, we\'ll customize your workout intensity, '
                'recovery periods, and hydration reminders. Your fitness plan will account '
                'for your energy sources and help you achieve optimal performance.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.security,
                      size: 16,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your nutrition data is private and only used to personalize your experience',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Map<String, int?> _getNutritionData() {
    return {
      'sugary_treats': SugaryTreatsQuestion.instance.getSugaryTreatsCount(answers),
      'sodas': SodasQuestion.instance.getSodasCount(answers),
      'grains': GrainsQuestion.instance.getGrainsCount(answers),
      'alcohol': AlcoholQuestion.instance.getAlcoholCount(answers),
    };
  }
  
  List<NutritionInsight> _generateInsights() {
    final insights = <NutritionInsight>[];
    final nutritionData = _getNutritionData();
    
    // Analyze sweet treats
    final treats = nutritionData['sugary_treats'] ?? 0;
    if (treats <= 2) {
      insights.add(NutritionInsight(
        icon: '🌟',
        title: 'Great Sweet Balance',
        description: 'You maintain a healthy relationship with sweet treats, which supports stable energy levels for workouts.',
        color: const Color(0xFF29AD8F), // continueGreen
      ));
    } else if (treats <= 4) {
      insights.add(NutritionInsight(
        icon: '⚖️',
        title: 'Moderate Sweet Intake',
        description: 'Your sweet treat intake is moderate. Consider timing them around workouts for energy without affecting recovery.',
        color: const Color(0xFFE9C46A), // congratulationsYellow
      ));
    }
    
    // Analyze hydration (sodas as proxy)
    final sodas = nutritionData['sodas'] ?? 0;
    if (sodas == 0) {
      insights.add(NutritionInsight(
        icon: '💧',
        title: 'Excellent Hydration Habits',
        description: 'You avoid sugary drinks, which is fantastic for hydration and performance. Keep it up!',
        color: const Color(0xFF2A9D8F), // doneTeal
      ));
    } else if (sodas >= 3) {
      insights.add(NutritionInsight(
        icon: '🥤',
        title: 'Hydration Opportunity',
        description: 'Consider replacing some sodas with water or electrolyte drinks to optimize your workout performance.',
        color: const Color(0xFFFF6F61), // restGoalCoral
      ));
    }
    
    // Analyze energy sources (grains)
    final grains = nutritionData['grains'] ?? 0;
    if (grains >= 3 && grains <= 8) {
      insights.add(NutritionInsight(
        icon: '⚡',
        title: 'Good Energy Foundation',
        description: 'Your grain intake provides steady energy for workouts. Perfect for sustained performance!',
        color: const Color(0xFF29AD8F), // continueGreen
      ));
    } else if (grains < 3) {
      insights.add(NutritionInsight(
        icon: '🌾',
        title: 'Energy Boost Opportunity',
        description: 'Adding more healthy grains could provide better workout fuel and recovery support.',
        color: const Color(0xFFE9C46A), // congratulationsYellow
      ));
    }
    
    // If no specific insights, add general encouragement
    if (insights.isEmpty) {
      insights.add(NutritionInsight(
        icon: '🎯',
        title: 'Personalized Plan Ready',
        description: 'We\'ve analyzed your nutrition profile and are ready to create a fitness plan that works with your lifestyle.',
        color: const Color(0xFF8A4FD3), // basePurple
      ));
    }
    
    return insights;
  }
}

/// Data class for nutrition insights
class NutritionInsight {
  final String icon;
  final String title;
  final String description;
  final Color color;
  
  const NutritionInsight({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}