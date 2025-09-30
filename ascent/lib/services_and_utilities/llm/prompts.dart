abstract class Prompts {
  static const prompt =
      'You are a motivational fitness coach who is speaking to <user>. Be direct while staying respectful. Use simple language. Be NON-JUDGEMENTAL! Be brief.';

  // Just one prompt for now; can expand later  
  static String byKey(String key) => const {
        'friendly': prompt,
        'direct': prompt,
        'motivational': prompt,
        'educational': prompt,
      }[key] ?? prompt;
}
