import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../firebase_options.dart';

/// Service for initializing and configuring Firebase
class FirebaseClient {
  
  /// Initialize Firebase with proper configuration
  static Future<void> initialize() async {
    debugPrint('=== FIREBASE INITIALIZATION STARTED ===');
    
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized with DefaultFirebaseOptions');
    
    // Configure Firebase emulator for debug builds
    if (kDebugMode) {
      debugPrint('Debug mode detected - configuring Firebase emulator...');
      await _configureFirebaseEmulator();
    } else {
      debugPrint('Release mode - using production Firebase');
    }
  }
  
  /// Configure Firebase emulator for local development
  static Future<void> _configureFirebaseEmulator() async {
    try {
      // Configure Firestore emulator
      FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
      debugPrint('✅ Firestore emulator configured: localhost:8080');
      
      // Configure Auth emulator  
      await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
      debugPrint('✅ Auth emulator configured: localhost:9099');
      
      debugPrint('🎯 Firebase emulator setup complete - using LOCAL emulator');
    } catch (e) {
      debugPrint('❌ Failed to configure Firebase emulator: $e');
      debugPrint('⚠️  Will fall back to production Firebase');
    }
  }
}