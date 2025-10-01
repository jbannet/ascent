import 'package:flutter_test/flutter_test.dart';
import 'package:ascent/models/workout/workout.dart';
import 'package:ascent/constants_and_enums/session_type.dart';
import 'package:ascent/constants_and_enums/workout_enums/workout_style_enum.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Workout Generation Tests', () {
    test('Generate Full Body workout - micro session', () async {
      final workout = Workout(
        type: SessionType.micro,
        style: WorkoutStyle.fullBody,
      );

      final blocks = await workout.generateBlocks();

      // Should have warmup, main blocks, and cooldown
      expect(blocks.length, greaterThan(2));

      // First block should be warmup
      expect(blocks.first.label, 'Warmup');

      // Last block should be cooldown
      expect(blocks.last.label, 'Cooldown');

      // Check that duration is reasonable (within 10% of 12 minutes = 720 seconds)
      final totalDuration = blocks.fold<int>(
        0,
        (sum, block) => sum + block.estimateDurationSec(),
      );
      expect(totalDuration, lessThan(720 * 1.1));
      expect(totalDuration, greaterThan(720 * 0.5)); // At least 50% of target

      print('Full Body Micro Workout Duration: ${totalDuration}s (${(totalDuration / 60).toStringAsFixed(1)}min)');
    });

    test('Generate Full Body workout - full session', () async {
      final workout = Workout(
        type: SessionType.full,
        style: WorkoutStyle.fullBody,
      );

      final blocks = await workout.generateBlocks();

      // Should have warmup, main blocks, and cooldown
      expect(blocks.length, greaterThan(2));

      // Check that duration is reasonable (within 10% of 60 minutes = 3600 seconds)
      final totalDuration = blocks.fold<int>(
        0,
        (sum, block) => sum + block.estimateDurationSec(),
      );
      expect(totalDuration, lessThan(3600 * 1.1));
      expect(totalDuration, greaterThan(3600 * 0.5));

      print('Full Body Full Workout Duration: ${totalDuration}s (${(totalDuration / 60).toStringAsFixed(1)}min)');
    });

    test('Generate Circuit Metabolic workout', () async {
      final workout = Workout(
        type: SessionType.full,
        style: WorkoutStyle.circuitMetabolic,
      );

      final blocks = await workout.generateBlocks();

      expect(blocks.length, greaterThan(2));

      final totalDuration = blocks.fold<int>(
        0,
        (sum, block) => sum + block.estimateDurationSec(),
      );

      print('Circuit Metabolic Workout Duration: ${totalDuration}s (${(totalDuration / 60).toStringAsFixed(1)}min)');
    });

    test('Generate Yoga Focused workout', () async {
      final workout = Workout(
        type: SessionType.micro,
        style: WorkoutStyle.yogaFocused,
      );

      final blocks = await workout.generateBlocks();

      expect(blocks.length, greaterThan(2));

      final totalDuration = blocks.fold<int>(
        0,
        (sum, block) => sum + block.estimateDurationSec(),
      );

      print('Yoga Focused Workout Duration: ${totalDuration}s (${(totalDuration / 60).toStringAsFixed(1)}min)');
    });

    test('Test all 13 workout styles generate successfully', () async {
      for (final style in WorkoutStyle.values) {
        final workout = Workout(
          type: SessionType.micro,
          style: style,
        );

        final blocks = await workout.generateBlocks();

        // Should generate at least warmup and cooldown
        expect(blocks.length, greaterThanOrEqualTo(2),
            reason: 'Style ${style.displayName} failed to generate blocks');

        print('${style.displayName}: ${blocks.length} blocks generated');
      }
    });

    test('Workout serialization includes blocks', () async {
      final workout = Workout(
        type: SessionType.micro,
        style: WorkoutStyle.fullBody,
      );

      final blocks = await workout.generateBlocks();
      workout.blocks = blocks;

      // Serialize to JSON
      final json = workout.toJson();

      // Should have blocks field
      expect(json['blocks'], isNotNull);
      expect(json['blocks'], isA<List>());

      // Deserialize back
      final deserializedWorkout = Workout.fromJson(json);
      expect(deserializedWorkout.blocks, isNotNull);
      expect(deserializedWorkout.blocks!.length, blocks.length);
    });
  });
}
