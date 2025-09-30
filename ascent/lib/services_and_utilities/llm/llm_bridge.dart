import 'dart:async';

import 'bundled_model_loader.dart';
import 'llm_service.dart';
import 'prompts.dart';

class LlmBridge {
  LlmBridge._();

  static Stream<String> rewriteRecommendation(
    String text, {
    String style = 'direct',
    double temperature = 0.1,
    double topP = 0.8,
  }) async* {
    final persona = Prompts.byKey(style);
    final prompt = _promptRewriteRecommendation(text, persona);
    final modelDir = await ensureBundledModelAvailable();
    await llmService.ensureEngine(overrideModelDirectory: modelDir.path);
    yield* llmService.answer(prompt, temperature: temperature, topP: topP);
  }

  static String _promptRewriteRecommendation(String text, String persona) {
    // ignore: unnecessary_string_escapes
    final sanitized = text.replaceAll('"', r'\"');
    return 'System: $persona\n\nUser: Summarize this fitness data point in one sentence for the user: "$sanitized"\nAssistant: You ';
  }


  static Stream<String> introduction(
    {
    String style = 'direct',
    double temperature = 0.1,
    double topP = 0.8,
  }) async* {
    final persona = Prompts.byKey(style);
    final prompt = _promptIntroduction(persona);
    final modelDir = await ensureBundledModelAvailable();
    await llmService.ensureEngine(overrideModelDirectory: modelDir.path);
    yield* llmService.answer(prompt, temperature: temperature, topP: topP);
  }

  static String _promptIntroduction(String persona) {
    // ignore: unnecessary_string_escapes    
    return 'System: $persona\n\nUser: Write 1-2 sentences welcoming the new user to the fitness app. \nAssistant: Welcome to Ascent! You ';
  }
}
