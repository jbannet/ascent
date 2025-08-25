import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'onboarding_workflow/providers/onboarding_provider.dart';
import 'onboarding_workflow/views/onboarding_survey_container.dart';
import 'onboarding_workflow/services/load_configuration/question_configuration_service.dart';
import 'onboarding_workflow/services/local_storage/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Hive.initFlutter();
  await _initializeQuestionsIfNeeded();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) {
          final provider = OnboardingProvider();
          provider.initialize();
          return provider;
        }),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ascent Fitness',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const OnboardingSurveyContainer(),
    );
  }
}

/// Initialize questions from assets if not already stored locally
Future<void> _initializeQuestionsIfNeeded() async {
  try {
    // Check if questions already exist in local storage
    final existingQuestions = await LocalStorageService.loadQuestions();
    
    // If no questions exist locally, load from assets and save
    if (!existingQuestions.isInitialized) {
      final initialQuestions = await QuestionConfigurationService.loadInitialQuestions();
      
      if (initialQuestions.isInitialized) {
        // Save questions to local storage
        // We need to convert back to JSON format for the existing saveQuestions method
        final String jsonString = await rootBundle.loadString(
          'lib/onboarding_workflow/config/initial_questions.json'
        );
        final Map<String, dynamic> jsonData = json.decode(jsonString);
        await LocalStorageService.saveQuestions(jsonData);
      }
    }
  } catch (e) {
    // Log error but don't prevent app from starting
    debugPrint('Failed to initialize questions: $e');
  }
}

