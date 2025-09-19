import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum Category {
  cardio('Cardio', Colors.red),
  strength('Strength', AppColors.basePurple),
  balance('Balance', Colors.blue),
  flexibility('Flexibility', AppColors.continueGreen),
  functional('Functional', Colors.brown);

  const Category(this.displayName, this.color);

  final String displayName;
  final Color color;

  String toJson() => name;

  static Category fromJson(String name) {
    return Category.values.firstWhere((category) => category.name == name);
  }
}