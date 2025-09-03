import 'package:flutter/material.dart';
import '../../models/blocks/block_step.dart';
import '../../models/blocks/exercise_prescription_step.dart';
import '../../models/blocks/rest_step.dart';
import '../../models/blocks/warmup_step.dart';
import '../../models/blocks/cooldown_step.dart';
import '../../enums/block_step_kind.dart';
import 'exercise_step_card.dart';
import 'rest_step_card.dart';
import 'warmup_step_card.dart';
import 'cooldown_step_card.dart';

class BlockStepCardFactory {
  static Widget createCard({
    required BlockStep step,
    VoidCallback? onExerciseTap,
    VoidCallback? onRestComplete,
  }) {
    switch (step.kind) {
      case BlockStepKind.exercise:
        final exerciseStep = step as ExercisePrescriptionStep;
        return ExerciseStepCard(
          step: exerciseStep,
          onTapDetails: onExerciseTap,
        );

      case BlockStepKind.rest:
        final restStep = step as RestStep;
        return RestStepCard(
          step: restStep,
          onComplete: onRestComplete,
        );

      case BlockStepKind.warmup:
        final warmupStep = step as WarmupStep;
        return WarmupStepCard(step: warmupStep);

      case BlockStepKind.cooldown:
        final cooldownStep = step as CooldownStep;
        return CooldownStepCard(step: cooldownStep);
    }
  }
}