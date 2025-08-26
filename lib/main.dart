import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'onboarding_workflow/providers/onboarding_provider.dart';
import 'onboarding_workflow/views/onboarding_survey_container.dart';
import 'services/firebase/firebase_client.dart';
import 'services/load_configuration/question_configuration_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await FirebaseClient.initialize();
  await Hive.initFlutter();
  await QuestionConfigurationService.initializeQuestionsIfNeeded();
  
  // Initialize the provider before creating the widget tree
  final onboardingProvider = OnboardingProvider();
  await onboardingProvider.initialize();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: onboardingProvider),
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


