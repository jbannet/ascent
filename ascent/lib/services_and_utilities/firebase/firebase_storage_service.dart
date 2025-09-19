import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants_and_enums/constants.dart';
import 'firebase_auth_service.dart';
import 'firebase_retry_service.dart';

/// Service for managing Firebase storage of onboarding answers
/// Questions are now managed locally via QuestionBank
class FirebaseStorageService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Load answers from Firebase for current user
  static Future<Map<String, dynamic>> loadAnswers() async {
    return await FirebaseRetryService.executeWithRetry(() async {
      final String currentUserId = await FirebaseAuthService.getCurrentUserId();
      final DocumentSnapshot answersDoc = await _firestore
          .collection(AppConstants.usersCollectionName)
          .doc(currentUserId)
          .collection(AppConstants.onboardingCollectionName)
          .doc(AppConstants.answersDocumentName)
          .get();
      
      if (!answersDoc.exists || answersDoc.data() == null) {
        return <String, dynamic>{};
      }
      
      final Map<String, dynamic> answersData = answersDoc.data() as Map<String, dynamic>;
      return answersData;
    });
  }
  
  /// Save answers to Firebase for current user
  static Future<void> saveAnswers(Map<String, dynamic> answers) async {
    return await FirebaseRetryService.executeWithRetry(() async {
      final String currentUserId = await FirebaseAuthService.getCurrentUserId();
      await _firestore
          .collection(AppConstants.usersCollectionName)
          .doc(currentUserId)
          .collection(AppConstants.onboardingCollectionName)
          .doc(AppConstants.answersDocumentName)
          .set(answers);
    });
  }
}