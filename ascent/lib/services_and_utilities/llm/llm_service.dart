import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:llama_cpp/llama_cpp.dart';

import 'model_descriptor.dart';
import 'model_downloader.dart';

enum LlmState { disabled, initializing, ready }

class LlmService {
  LlmService({
    required this.getModelService,
    required this.downloader,
  });

  final GetModelService getModelService;
  final ModelDownloader downloader;

  LlmState state = LlmState.disabled;
  LlamaCpp? _llama;
  ModelDescriptor? _activeDescriptor;

  Future<LlamaCpp> ensureEngine({void Function(int, int?)? onProgress}) async {
    if (_llama != null) {
      return _llama!;
    }

    state = LlmState.initializing;
    try {
      final descriptor = await getModelService.current();
      _activeDescriptor = descriptor;
      final file = await downloader.ensureModel(
        descriptor,
        onProgress: onProgress,
      );
      _llama = await LlamaCpp.load(
        file.path,
        verbose: kDebugMode || kProfileMode,
      );
      state = LlmState.ready;
      return _llama!;
    } catch (error) {
      state = LlmState.disabled;
      rethrow;
    }
  }

  Stream<String> answer(
    String prompt, {
    double? temperature,
    double? topP,
    int? topK,
  }) {
    if (state != LlmState.ready || _llama == null) {
      throw StateError('Engine not ready. Call ensureEngine() first.');
    }
    return _llama!.answer(
      prompt,
      temperature: temperature,
      topP: topP,
      topK: topK,
    );
  }

  Future<void> dispose() async {
    await _llama?.dispose();
    _llama = null;
    state = LlmState.disabled;
  }

  Future<void> clearCache() async {
    await dispose();
    final descriptor = _activeDescriptor ?? await getModelService.current();
    await downloader.deleteCached(descriptor);
    _activeDescriptor = null;
  }
}

const _rawModelBaseUrl = String.fromEnvironment('MODEL_BASE_URL', defaultValue: '');
final Uri? _baseUri = _rawModelBaseUrl.isEmpty ? null : Uri.parse(_rawModelBaseUrl);

final GetModelService getModelService = DefaultGetModelService(
  _baseUri,
  kDebugMode
      ? '/Users/jonathanbannet/MyProjects/fitness_app/ggruf_models/Llama-3.2-1B-Instruct-Q4_K_M.gguf'
      : null,
);

final ModelDownloader modelDownloader = ModelDownloader();

final LlmService llmService = LlmService(
  getModelService: getModelService,
  downloader: modelDownloader,
);
