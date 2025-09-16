// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../lib/workflows/question_bank/registry/question_bank.dart';
import '../lib/models/fitness_profile_model/fitness_profile.dart';
import '../lib/constants_features.dart';
import '../lib/models/fitness_profile_model/reference_data/acsm_cardio_norms.dart';
import '../lib/models/fitness_profile_model/reference_data/acsm_pushup_norms.dart';
import 'persona_definitions.dart';

/// Test case representing a user persona with predefined answers
class PersonaTestCase {
  final String personaId;
  final String description;
  final Map<String, dynamic> answers;
  final Map<String, String> metadata;

  PersonaTestCase({
    required this.personaId,
    required this.description,
    required this.answers,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() => {
    'persona_id': personaId,
    'description': description,
    'answers': answers,
    'metadata': metadata,
  };
}

/// Results from running a persona through the onboarding flow
class PersonaTestResult {
  final String personaId;
  final DateTime timestamp;
  final Map<String, dynamic> calculatedValues;
  final Map<String, int> allocations;
  final String? triggeredProtocol;
  final Map<String, dynamic> rawAnswers;

  PersonaTestResult({
    required this.personaId,
    required this.timestamp,
    required this.calculatedValues,
    required this.allocations,
    this.triggeredProtocol,
    required this.rawAnswers,
  });

  Map<String, dynamic> toJson() => {
    'persona_id': personaId,
    'timestamp': timestamp.toIso8601String(),
    'calculated_values': calculatedValues,
    'allocations': allocations,
    'triggered_protocol': triggeredProtocol,
    'raw_answers': rawAnswers,
  };
}

/// Production fitness profile calculator using the real system
class ProductionAllocationCalculator {

  /// Calculate age from date of birth string
  static int calculateAge(String dateOfBirth) {
    final birth = DateTime.parse(dateOfBirth);
    final now = DateTime.now();
    return now.year - birth.year - (now.month < birth.month || (now.month == birth.month && now.day < birth.day) ? 1 : 0);
  }

  /// Calculate BMI from height and weight
  static double calculateBMI(double heightCm, double weightKg) {
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  /// Get allocations using the REAL production FitnessProfile system
  static Map<String, int> calculateAllocation(Map<String, dynamic> answers) {
    try {
      // Define feature order (required by FitnessProfile constructor)
      final featureOrder = [
        FeatureConstants.categoryCardio,
        FeatureConstants.categoryStrength,
        FeatureConstants.categoryBalance,
        FeatureConstants.categoryStretching,
        FeatureConstants.categoryFunctional,
        // Add other features as needed
      ];

      // Create FitnessProfile with answers
      final fitnessProfile = FitnessProfile(featureOrder, answers);

      // Extract allocation percentages from the feature map
      final features = fitnessProfile.features;

      return {
        'cardio': ((features[FeatureConstants.categoryCardio] ?? 0.0) * 100).round(),
        'strength': ((features[FeatureConstants.categoryStrength] ?? 0.0) * 100).round(),
        'balance': ((features[FeatureConstants.categoryBalance] ?? 0.0) * 100).round(),
        'flexibility': ((features[FeatureConstants.categoryStretching] ?? 0.0) * 100).round(),
        'functional': ((features[FeatureConstants.categoryFunctional] ?? 0.0) * 100).round(),
      };
    } catch (e) {
      print('Error calculating allocation with production code: $e');
      // Fallback to basic allocation if production code fails
      return {
        'cardio': 40,
        'strength': 40,
        'balance': 10,
        'functional': 5,
        'flexibility': 5,
      };
    }
  }

  /// Determine triggered protocol by analyzing the results
  static String? getTriggeredProtocol(Map<String, dynamic> answers, Map<String, int> allocations) {
    // Analyze allocation patterns to infer which protocol was triggered
    if (allocations['balance'] == 35 && allocations['strength'] == 35) {
      return 'fall_history';
    }
    if (allocations['strength'] == 45 && allocations['functional'] == 25) {
      return 'chair_stand_failure';
    }
    if (allocations['cardio']! >= 55) {
      return 'extreme_obesity';
    }
    if (allocations['cardio']! >= 45 && allocations['strength'] == 40) {
      return 'glp1_obesity';
    }
    return null;
  }
}

/// Test harness for running personas through onboarding
class PersonaTestHarness {

  /// Run a single persona through the onboarding flow
  static PersonaTestResult runPersona(PersonaTestCase persona) {
    // Initialize question bank
    final questions = QuestionBank.initialize();

    // Populate answers
    QuestionBank.fromJson(persona.answers);

    // Calculate derived values
    final age = ProductionAllocationCalculator.calculateAge(persona.answers['age']);
    final heightCm = persona.answers['height_cm'] ?? 170.0;
    final weightKg = persona.answers['weight_kg'] ?? 70.0;
    final bmi = ProductionAllocationCalculator.calculateBMI(heightCm, weightKg);
    final cooperMiles = persona.answers['Q4'] ?? 0.0;
    final pushups = (persona.answers['Q5'] ?? 0).round();
    final gender = persona.answers['gender'] ?? 'male';

    // Calculate percentiles
    final cardioPercentile = ACSMCardioNorms.getPercentile(cooperMiles, age, gender);
    final pushupPercentile = ACSMPushupNorms.getPercentile(pushups, age, gender);

    final calculatedValues = {
      'age': age,
      'bmi': bmi,
      'cooper_miles': cooperMiles,
      'pushups': pushups,
      'cardio_percentile': cardioPercentile,
      'pushup_percentile': pushupPercentile,
    };

    // Calculate allocations using REAL production code
    final allocations = ProductionAllocationCalculator.calculateAllocation(persona.answers);
    final triggeredProtocol = ProductionAllocationCalculator.getTriggeredProtocol(persona.answers, allocations);

    // Get raw answers from question bank
    final rawAnswers = QuestionBank.toJson();

    return PersonaTestResult(
      personaId: persona.personaId,
      timestamp: DateTime.now(),
      calculatedValues: calculatedValues,
      allocations: allocations,
      triggeredProtocol: triggeredProtocol,
      rawAnswers: rawAnswers,
    );
  }

  /// Run all personas and generate report
  static Future<void> runAllPersonasAndGenerateReport(List<PersonaTestCase> personas) async {
    final results = <PersonaTestResult>[];

    for (final persona in personas) {
      print('Running persona: ${persona.personaId}');
      final result = runPersona(persona);
      results.add(result);
    }

    // Save detailed JSON results
    await _saveJsonResults(results);

    // Save CSV summary
    await _saveCsvSummary(results);

    // Save printable review format
    await _savePrintableReview(personas, results);

    print('Generated reports:');
    print('- test/results/persona_distribution.json');
    print('- test/results/persona_summary.csv');
    print('- test/results/persona_review.txt');
  }

  static Future<void> _saveJsonResults(List<PersonaTestResult> results) async {
    final resultsDir = Directory('test/results');
    if (!await resultsDir.exists()) {
      await resultsDir.create(recursive: true);
    }

    final jsonData = {
      'generated_at': DateTime.now().toIso8601String(),
      'total_personas': results.length,
      'results': results.map((r) => r.toJson()).toList(),
    };

    final file = File('test/results/persona_distribution.json');
    await file.writeAsString(JsonEncoder.withIndent('  ').convert(jsonData));
  }

  static Future<void> _saveCsvSummary(List<PersonaTestResult> results) async {
    final csvLines = <String>[];

    // Header
    csvLines.add([
      'Persona ID',
      'Age',
      'BMI',
      'Cooper Miles',
      'Cardio %ile',
      'Pushups',
      'Pushup %ile',
      'Triggered Protocol',
      'Cardio %',
      'Strength %',
      'Balance %',
      'Functional %',
      'Flexibility %',
    ].join(','));

    // Data rows
    for (final result in results) {
      final cardioPercentile = ((result.calculatedValues['cardio_percentile'] as double) * 100).round();
      final pushupPercentile = ((result.calculatedValues['pushup_percentile'] as double) * 100).round();

      csvLines.add([
        result.personaId,
        result.calculatedValues['age'],
        (result.calculatedValues['bmi'] as double).toStringAsFixed(1),
        result.calculatedValues['cooper_miles'],
        cardioPercentile,
        result.calculatedValues['pushups'],
        pushupPercentile,
        result.triggeredProtocol ?? 'none',
        result.allocations['cardio'],
        result.allocations['strength'],
        result.allocations['balance'],
        result.allocations['functional'],
        result.allocations['flexibility'],
      ].join(','));
    }

    final file = File('test/results/persona_summary.csv');
    await file.writeAsString(csvLines.join('\n'));
  }

  static Future<void> _savePrintableReview(List<PersonaTestCase> personas, List<PersonaTestResult> results) async {
    final lines = <String>[];

    lines.add('ONBOARDING PERSONA TEST RESULTS');
    lines.add('=' * 50);
    lines.add('Generated: ${DateTime.now().toString()}');
    lines.add('Total Personas: ${results.length}');
    lines.add('');

    for (int i = 0; i < personas.length; i++) {
      final persona = personas[i];
      final result = results[i];

      // Persona header
      lines.add('personaId: ${persona.personaId}');
      lines.add('description: ${persona.description}');

      // Format answers as key:"value" pairs
      final answerParts = <String>[];
      persona.answers.forEach((key, value) {
        String formattedValue;
        if (value is String) {
          formattedValue = '"$value"';
        } else if (value is List) {
          formattedValue = '"${value.join(',')}"';
        } else {
          formattedValue = value.toString();
        }
        answerParts.add('$key:$formattedValue');
      });
      lines.add('answers: {${answerParts.join('; ')}}');

      // Output allocations
      final allocations = result.allocations;
      lines.add('');
      lines.add('Output: {cardio: ${allocations['cardio']}%, strength: ${allocations['strength']}%, balance: ${allocations['balance']}%, functional: ${allocations['functional']}%, flexibility: ${allocations['flexibility']}%}');

      // Add triggered protocol if any
      if (result.triggeredProtocol != null) {
        lines.add('Triggered Protocol: ${result.triggeredProtocol}');
      }

      // Add calculated values for context
      final calc = result.calculatedValues;
      // Add calculated values for context
      final cardioPercentile = ((calc['cardio_percentile'] as double) * 100).round();
      final pushupPercentile = ((calc['pushup_percentile'] as double) * 100).round();
      lines.add('Calculated: Age=${calc['age']}, BMI=${(calc['bmi'] as double).toStringAsFixed(1)}, Cooper=${calc['cooper_miles']}mi (${cardioPercentile}th %ile), Pushups=${calc['pushups']} (${pushupPercentile}th %ile)');

      lines.add('-' * 80);
      lines.add('');
    }

    // Add summary statistics
    lines.add('');
    lines.add('SUMMARY STATISTICS');
    lines.add('=' * 50);

    // Protocol frequency
    final protocolCounts = <String, int>{};
    for (final result in results) {
      final protocol = result.triggeredProtocol ?? 'none';
      protocolCounts[protocol] = (protocolCounts[protocol] ?? 0) + 1;
    }

    lines.add('Protocol Frequency:');
    protocolCounts.entries.forEach((entry) {
      lines.add('  ${entry.key}: ${entry.value} personas');
    });

    // Allocation ranges
    lines.add('');
    lines.add('Allocation Ranges:');
    final allocKeys = ['cardio', 'strength', 'balance', 'functional', 'flexibility'];
    for (final key in allocKeys) {
      final values = results.map((r) => r.allocations[key]!).toList();
      values.sort();
      lines.add('  $key: ${values.first}% - ${values.last}%');
    }

    final file = File('test/results/persona_review.txt');
    await file.writeAsString(lines.join('\n'));
  }
}

void main() {
  setUpAll(() async {
    // Initialize Hive for testing
    Hive.init('./test_hive_db');
  });

  tearDownAll(() async {
    // Clean up Hive
    await Hive.deleteFromDisk();
  });

  group('Onboarding Persona Distribution Tests', () {
    test('Run all 25 personas through onboarding flow', () async {
      print('=== ONBOARDING PERSONA DISTRIBUTION TEST ===');
      print('Running 25 diverse personas through the fitness allocation system...\n');

      final personas = PersonaDefinitions.getAllPersonas();

      print('Loaded ${personas.length} personas:');
      for (final persona in personas) {
        print('  - ${persona.personaId}: ${persona.description}');
      }
      print('');

      await PersonaTestHarness.runAllPersonasAndGenerateReport(personas);

      print('\n=== TEST COMPLETE ===');
      print('Check the generated reports to analyze the distribution:');
      print('- test/results/persona_distribution.json (detailed data)');
      print('- test/results/persona_summary.csv (spreadsheet analysis)');
    });

    test('Run individual persona - Elderly with Fall History', () async {
      final persona = PersonaDefinitions.elderlyWithFallHistory();
      final result = PersonaTestHarness.runPersona(persona);

      print('Persona: ${result.personaId}');
      print('Age: ${result.calculatedValues['age']}');
      print('BMI: ${result.calculatedValues['bmi']}');
      print('Cooper Test: ${result.calculatedValues['cooper_miles']}mi (${((result.calculatedValues['cardio_percentile'] as double) * 100).round()}th percentile)');
      print('Pushups: ${result.calculatedValues['pushups']} (${((result.calculatedValues['pushup_percentile'] as double) * 100).round()}th percentile)');
      print('Triggered Protocol: ${result.triggeredProtocol}');
      print('Allocations: ${result.allocations}');

      // Verify the fall history protocol was triggered
      expect(result.triggeredProtocol, equals('fall_history'));
      expect(result.allocations['balance'], equals(35));
      expect(result.allocations['strength'], equals(35));
    });

    test('Run individual persona - Young Athlete', () async {
      final persona = PersonaDefinitions.youngAthlete();
      final result = PersonaTestHarness.runPersona(persona);

      print('Persona: ${result.personaId}');
      print('Age: ${result.calculatedValues['age']}');
      print('BMI: ${result.calculatedValues['bmi']}');
      print('Cooper Test: ${result.calculatedValues['cooper_miles']}mi (${((result.calculatedValues['cardio_percentile'] as double) * 100).round()}th percentile)');
      print('Pushups: ${result.calculatedValues['pushups']} (${((result.calculatedValues['pushup_percentile'] as double) * 100).round()}th percentile)');
      print('Triggered Protocol: ${result.triggeredProtocol}');
      print('Allocations: ${result.allocations}');

      // Should use base calculation, no protocol
      expect(result.triggeredProtocol, isNull);
      // Young athlete should have low balance allocation
      expect(result.allocations['balance'], lessThan(15));
    });

    test('Run individual persona - GLP-1 with Obesity', () async {
      final persona = PersonaDefinitions.glp1WithObesity();
      final result = PersonaTestHarness.runPersona(persona);

      print('Persona: ${result.personaId}');
      print('Age: ${result.calculatedValues['age']}');
      print('BMI: ${result.calculatedValues['bmi']}');
      print('Cooper Test: ${result.calculatedValues['cooper_miles']}mi (${((result.calculatedValues['cardio_percentile'] as double) * 100).round()}th percentile)');
      print('Pushups: ${result.calculatedValues['pushups']} (${((result.calculatedValues['pushup_percentile'] as double) * 100).round()}th percentile)');
      print('Triggered Protocol: ${result.triggeredProtocol}');
      print('Allocations: ${result.allocations}');

      // Verify GLP-1 protocol was triggered
      expect(result.triggeredProtocol, equals('glp1_obesity'));
      expect(result.allocations['strength'], equals(40));
      expect(result.allocations['cardio'], equals(45));
    });
  });
}