import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'theme/app_theme.dart';
import 'onboarding_workflow/views/onboarding_survey_container.dart';
import 'services/firebase/firebase_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await FirebaseClient.initialize();
  await Hive.initFlutter();
  debugPrint("✅ Hive initialized");
  
  runApp(const MyApp());
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


