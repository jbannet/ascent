import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
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
      // Note: iOS simulators work better with 127.0.0.1 and can't do 'localhost', Android emulators need '10.0.2.2'
      final String host = Platform.isAndroid ? '10.0.2.2' : '127.0.0.1';

      // 1. Configure all emulators using the recommended `use...Emulator` methods.
      // This correctly sets up the underlying gRPC channels for local, non-SSL traffic.
      FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
      debugPrint('✅ Firestore emulator configured: $host:8080');

      // Disable persistence for a clean state in emulator tests.
      FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: false);
      
      await FirebaseAuth.instance.useAuthEmulator(host, 9099);
      debugPrint('✅ Auth emulator configured: $host:9099');
      
      // 2. Now that emulators are configured, test the connections.
      debugPrint('--- Testing Emulator Connections ---');
      try {
        final userCredential = await FirebaseAuth.instance.signInAnonymously();
        debugPrint('✅ Auth connectivity test successful (signed in as ${userCredential.user?.uid})');
      } catch (e) {
        debugPrint('❌ Auth connectivity test failed: $e');
      }

      try {
        await FirebaseFirestore.instance
            .collection('onboarding')
            .doc('questions')
            .get();
        debugPrint('✅ Firestore connectivity test successful');
      } catch (e) {
        debugPrint('❌ Firestore emulator connectivity test failed: $e');
      }
      
      debugPrint('🎯 Firebase emulator setup complete - using LOCAL emulator');
    } catch (e) {
      debugPrint('❌ Failed to configure Firebase emulator: $e');
      if (Platform.isIOS && e.toString().contains('unavailable')) {
        debugPrint('💡 HINT: For iOS simulators, you may need to add `NSAllowsLocalNetworking` to your Info.plist file to connect to a local emulator.');
      }
      debugPrint('⚠️  Will fall back to production Firebase');
    }
  }
}