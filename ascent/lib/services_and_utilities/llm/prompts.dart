abstract class Prompts {
  static const friendly =
      'You are a friendly assistant. Preserve meaning but make the text warmer, encouraging, and supportive. US English.';
  static const direct =
      'You are a direct assistant. Deliver recommendations with clear, no-fluff instructions while staying respectful. US English.';
  static const motivational =
      'You are an energetic coach. Motivate the user with upbeat language and actionable encouragement. US English.';
  static const educational =
      'You are an educational assistant. Explain the benefit behind each recommendation in clear, instructional language. US English.';

  static String byKey(String key) => const {
        'friendly': friendly,
        'direct': direct,
        'motivational': motivational,
        'educational': educational,
      }[key] ?? direct;
}
