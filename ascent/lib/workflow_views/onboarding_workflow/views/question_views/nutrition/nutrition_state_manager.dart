import '../../../question_bank/questions/nutrition/sugary_treats_question.dart';
import '../../../question_bank/questions/nutrition/sodas_question.dart';
import '../../../question_bank/questions/nutrition/grains_question.dart';
import '../../../question_bank/questions/nutrition/alcohol_question.dart';

/// Manages state across all nutrition questions for the persistent bucket
class NutritionStateManager {
  static NutritionStateManager? _instance;
  static NutritionStateManager get instance => _instance ??= NutritionStateManager._();
  NutritionStateManager._();

  /// Get all current nutrition values from the question bank
  Map<String, int> getAllNutritionValues() {
    return {
      'treats': SugaryTreatsQuestion.instance.sugaryTreatsCount?.toInt() ?? 0,
      'sodas': SodasQuestion.instance.sodasCount?.toInt() ?? 0,
      'grains': GrainsQuestion.instance.grainsCount?.toInt() ?? 0,
      'alcohol': AlcoholQuestion.instance.alcoholCount?.toInt() ?? 0,
    };
  }

  /// Update a specific nutrition value
  void updateNutritionValue(String type, int value) {
    switch (type) {
      case 'treats':
        SugaryTreatsQuestion.instance.setSugaryTreatsCount(value.toDouble());
        break;
      case 'sodas':
        SodasQuestion.instance.setSodasCount(value.toDouble());
        break;
      case 'grains':
        GrainsQuestion.instance.setGrainsCount(value.toDouble());
        break;
      case 'alcohol':
        AlcoholQuestion.instance.setAlcoholCount(value.toDouble());
        break;
    }
  }

  /// Get the total count across all nutrition types
  int getTotalCount() {
    final values = getAllNutritionValues();
    return values.values.fold(0, (sum, value) => sum + value);
  }

  /// Check if any nutrition questions have been answered
  bool hasAnyAnswers() {
    return getAllNutritionValues().values.any((value) => value > 0);
  }
}