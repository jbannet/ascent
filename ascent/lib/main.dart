import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'theme/app_theme.dart';
import 'routing/app_router.dart';
//import 'services/firebase/firebase_client.dart';

//TODO: needs to handle both meters and feet depending on region
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  //await FirebaseClient.initialize();
  await Hive.initFlutter();
  debugPrint("✅ Hive initialized");
  
  runApp(const MyApp());
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


