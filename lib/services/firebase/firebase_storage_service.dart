import 'package:cloud_firestore/cloud_firestore.dart';
import '../local_storage/local_storage_service.dart';
import '../../onboarding_workflow/models/questions/question_list.dart';
import '../../onboarding_workflow/models/answers/onboarding_answers.dart';
import '../../constants.dart';
import 'firebase_auth_service.dart';

/// Service for managing Firebase storage of onboarding data
class FirebaseStorageService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Load questions from Firebase
  static Future<QuestionList> loadQuestions(QuestionList localQuestionList, double firebaseQuestionVersion) async {
      final DocumentSnapshot questionsDoc = await _firestore
          .collection(AppConstants.onboardingCollectionName)
          .doc(AppConstants.questionsDocumentName)
          .get();
      
      if (!questionsDoc.exists || questionsDoc.data() == null) {
        return localQuestionList;
      }

      final Map<String, dynamic> questionsData = questionsDoc.data() as Map<String, dynamic>;
      final QuestionList newQuestions = QuestionList.fromJson(questionsData);
      await LocalStorageService.saveQuestions(questionsData); // Save the JSON directly to local storage to save parsing steps
      await LocalStorageService.saveQuestionVersion(firebaseQuestionVersion);    
      return newQuestions;
    
  }
  /// Get question version from Firebase
  static Future<double> getQuestionVersion() async {
    final DocumentSnapshot questionsDoc = await _firestore
        .collection(AppConstants.onboardingCollectionName)
        .doc(AppConstants.questionsDocumentName)
        .get();
    
    if (!questionsDoc.exists || questionsDoc.data() == null) {
      return 0.0;
    }
    
    final Map<String, dynamic> questionsData = questionsDoc.data() as Map<String, dynamic>;
    final String versionStr = questionsData['version'] as String;
    return double.tryParse(versionStr) ?? 0.0;
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