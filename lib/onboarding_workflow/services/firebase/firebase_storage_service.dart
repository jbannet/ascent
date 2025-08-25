import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/questions/question_list.dart';
import '../../models/answers/onboarding_answers.dart';
import '../../../constants.dart';
import 'firebase_auth_service.dart';

/// Service for managing Firebase storage of onboarding data
class FirebaseStorageService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Load questions from Firebase
  static Future<QuestionList> loadQuestions() async {
    final DocumentSnapshot questionsDoc = await _firestore
        .collection(AppConstants.onboardingCollectionName)
        .doc(AppConstants.questionsDocumentName)
        .get();
    
    if (!questionsDoc.exists || questionsDoc.data() == null) {
      return QuestionList.empty();
    }
    
    final Map<String, dynamic> questionsData = questionsDoc.data() as Map<String, dynamic>;
    return QuestionList.fromJson(questionsData);
  }
  
  /// Save questions to Firebase
  static Future<void> saveQuestions(QuestionList pQuestionList) async {
    await _firestore
        .collection(AppConstants.onboardingCollectionName)
        .doc(AppConstants.questionsDocumentName)
        .set(pQuestionList.toJson());
  }

  /// Get question version from Firebase
  static Future<int> getQuestionVersion() async {
    final DocumentSnapshot questionsDoc = await _firestore
        .collection(AppConstants.onboardingCollectionName)
        .doc(AppConstants.questionsDocumentName)
        .get();
    
    if (!questionsDoc.exists || questionsDoc.data() == null) {
      return 0;
    }
    
    final Map<String, dynamic> questionsData = questionsDoc.data() as Map<String, dynamic>;
    return questionsData['version'] as int? ?? 0;
  }
  
  /// Load answers from Firebase for current user
  static Future<OnboardingAnswers> loadAnswers() async {
    final String currentUserId = await FirebaseAuthService.getCurrentUserId();
    final DocumentSnapshot answersDoc = await _firestore
        .collection(AppConstants.usersCollectionName)
        .doc(currentUserId)
        .collection(AppConstants.onboardingCollectionName)
        .doc(AppConstants.answersDocumentName)
        .get();
    
    if (!answersDoc.exists || answersDoc.data() == null) {
      return OnboardingAnswers.empty();
    }
    
    final Map<String, dynamic> answersData = answersDoc.data() as Map<String, dynamic>;
    return OnboardingAnswers.fromJson(answersData);
  }
  
  /// Save answers to Firebase for current user
  static Future<void> saveAnswers(OnboardingAnswers pAnswers) async {
    final String currentUserId = await FirebaseAuthService.getCurrentUserId();
    await _firestore
        .collection(AppConstants.usersCollectionName)
        .doc(currentUserId)
        .collection(AppConstants.onboardingCollectionName)
        .doc(AppConstants.answersDocumentName)
        .set(pAnswers.toJson());
  }
}