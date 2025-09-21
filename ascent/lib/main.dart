import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'routing/app_router.dart';
import 'services_and_utilities/app_state/app_state.dart';
import 'services_and_utilities/exercises/exercise_service.dart';
import 'theme/app_theme.dart';
//import 'services/firebase/firebase_client.dart';

//TODO: needs to handle both meters and feet depending on region
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  //await FirebaseClient.initialize();
  await Hive.initFlutter();
  debugPrint("✅ Hive initialized");

  final appState = AppState();
  appState.setFeatureOrder(await ExerciseService.loadFeatureOrder());
  await appState.initialize();

  runApp(
    ChangeNotifierProvider.value(
      value: appState,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Ascent Fitness',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
    );
  }
}

