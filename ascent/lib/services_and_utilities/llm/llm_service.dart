import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'mlc_bridge.dart';
import 'model_descriptor.dart';
import 'model_downloader.dart';

enum LlmState { disabled, initializing, ready }

class LlmService {
  LlmService({
    required this.getModelService,
    required this.downloader,
    MlcBridge? bridge,
  }) : bridge = bridge ?? MlcBridge.instance;

  final GetModelService getModelService;
  final ModelDownloader downloader;
  final MlcBridge bridge;

  LlmState state = LlmState.disabled;
  ModelDescriptor? _activeDescriptor;
  Directory? _bundleDirectory;
  Future<void>? _initializing;

  Future<void> ensureEngine({
    void Function(int, int?)? onProgress,
    String? overrideModelDirectory,
  }) async {
    _initializing ??= _initialize(
      onProgress: onProgress,
      overrideModelDirectory: overrideModelDirectory,
    );
    try {
      await _initializing;
    } finally {
      _initializing = null;
    }
  }

  Future<void> _initialize({
    void Function(int, int?)? onProgress,
    String? overrideModelDirectory,
  }) async {
    if (getModelService is DefaultGetModelService) {
      (getModelService as DefaultGetModelService).setManualBundleDirectory(
        overrideModelDirectory,
      );
    }

    final descriptor = await getModelService.current();

    if (state == LlmState.ready &&
        _isSameDescriptor(descriptor, _activeDescriptor)) {
      return;
    }

    state = LlmState.initializing;
    try {
      final bundleDir = await downloader.ensureModel(
        descriptor,
        onProgress: onProgress,
        overrideDirectory: overrideModelDirectory,
      );

      if (!_isSameDescriptor(descriptor, _activeDescriptor)) {
        await bridge.shutdown();
      }

      await bridge.initialize(bundleDir.path);
      _bundleDirectory = bundleDir;
      _activeDescriptor = descriptor;
      state = LlmState.ready;
    } catch (error) {
      state = LlmState.disabled;
      rethrow;
    }
  }

  Stream<String> answer(String prompt, {double? temperature, double? topP}) {
    if (state != LlmState.ready) {
      throw StateError('Engine not ready. Call ensureEngine() first.');
    }
    return bridge.generate(prompt, temperature: temperature, topP: topP);
  }

  Future<void> dispose() async {
    await bridge.shutdown();
    state = LlmState.disabled;
    _bundleDirectory = null;
  }

  Future<void> clearCache() async {
    await dispose();
    final descriptor = _activeDescriptor ?? await getModelService.current();
    await downloader.deleteCached(descriptor);
    _activeDescriptor = null;
  }

  bool _isSameDescriptor(ModelDescriptor a, ModelDescriptor? b) {
    if (b == null) {
      return false;
    }
    return a.bundleId == b.bundleId && a.version == b.version;
  }
}

const _rawModelBaseUrl = String.fromEnvironment(
  'MODEL_BASE_URL',
  defaultValue: '',
);
final Uri? _baseUri =
    _rawModelBaseUrl.isEmpty ? null : Uri.parse(_rawModelBaseUrl);

const _debugBundlePath =
    '/Users/jonathanbannet/MyProjects/fitness_app/mlc-llm/ios/MLCChat/dist/bundle';

final GetModelService getModelService = DefaultGetModelService(
  _baseUri,
  kDebugMode ? _debugBundlePath : null,
);

final ModelDownloader modelDownloader = ModelDownloader();

final LlmService llmService = LlmService(
  getModelService: getModelService,
  downloader: modelDownloader,
);
