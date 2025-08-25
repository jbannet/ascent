import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../firebase_options.dart';

/// Service for initializing and configuring Firebase
class FirebaseClient {
  
  /// Initialize Firebase with proper configuration
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Configure Firebase emulator for debug builds
    if (kDebugMode) {
      await _configureFirebaseEmulator();
    }
  }
  
  /// Configure Firebase emulator for local development
  static Future<void> _configureFirebaseEmulator() async {
    // Configure Firestore emulator
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
    
    // Configure Auth emulator  
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    
    debugPrint('Firebase emulator configured for local development');
  }
}