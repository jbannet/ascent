import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'onboarding_workflow/providers/onboarding_provider.dart';
import 'onboarding_workflow/views/onboarding_survey_container.dart';
import 'onboarding_workflow/services/local_storage/local_storage_service.dart';
import 'onboarding_workflow/services/firebase/firebase_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await FirebaseClient.initialize();
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
      // Load JSON directly from assets and save to Hive
      final String jsonString = await rootBundle.loadString(
        'lib/onboarding_workflow/config/initial_questions.json'
      );
      
      final dynamic decoded = json.decode(jsonString);
      final Map<String, dynamic> jsonData = Map<String, dynamic>.from(decoded as Map);
      
      await LocalStorageService.saveQuestions(jsonData);
    }
  } catch (e) {
    // Re-throw to see the actual error during development
    rethrow;
  }
}

