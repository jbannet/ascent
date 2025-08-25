import 'package:firebase_auth/firebase_auth.dart';

/// Service for managing Firebase authentication
class FirebaseAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  /// Get current authenticated user ID
  /// Signs in anonymously if no user is authenticated
  static Future<String> getCurrentUserId() async {
    final User? currentUser = _auth.currentUser;
    
    if (currentUser == null) {
      final UserCredential userCredential = await _auth.signInAnonymously();
      return userCredential.user!.uid;
    }
    
    return currentUser.uid;
  }
  
  /// Get current user without creating new anonymous user
  static User? getCurrentUser() {
    return _auth.currentUser;
  }
  
  /// Sign out current user
  static Future<void> signOut() async {
    await _auth.signOut();
  }
}