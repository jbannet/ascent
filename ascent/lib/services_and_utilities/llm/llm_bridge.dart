import 'dart:async';

import 'bundled_model_loader.dart';
import 'llm_service.dart';
import 'prompts.dart';

class LlmBridge {
  LlmBridge._();

  static Stream<String> rewrite(
    String text, {
    String style = 'direct',
    double temperature = 0.7,
    double topP = 0.9,
  }) async* {
    final persona = Prompts.byKey(style);
    final prompt = _prompt(text, persona);
    final modelDir = await ensureBundledModelAvailable();
    await llmService.ensureEngine(overrideModelDirectory: modelDir.path);
    yield* llmService.answer(prompt, temperature: temperature, topP: topP);
  }

  static String _prompt(String text, String persona) {
    // ignore: unnecessary_string_escapes
    final sanitized = text.replaceAll('"', r'\"');
    return 'System: ${persona}\n\nUser: Rewrite: "${sanitized}"\nAssistant:';
  }
}
