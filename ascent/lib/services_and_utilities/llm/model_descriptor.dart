import 'dart:io';

import 'package:flutter/foundation.dart';

import 'bundled_model_constants.dart';

enum ModelCompression { none, zip }

/// Describes the model artifact bundle used by the on-device MLC runtime.
class ModelDescriptor {
  ModelDescriptor({
    required this.bundleId,
    required this.version,
    required this.uri,
    this.sha256Hex,
    this.sizeBytes,
    this.compression = ModelCompression.none,
  });

  /// Stable identifier used for local caching under Application Support.
  final String bundleId;

  /// Semantic version of the bundle. When this changes we refresh the cache.
  final String version;

  /// Location of the bundle or archive.
  final Uri uri;

  /// Optional checksum for the bundle/archive contents.
  final String? sha256Hex;

  /// Optional size hint in bytes to surface progress indicators.
  final int? sizeBytes;

  /// Compression type for the artifact. `none` means the URI resolves to a directory.
  final ModelCompression compression;
}

/// Abstraction that resolves the active model descriptor.
abstract class GetModelService {
  Future<ModelDescriptor> current();
}

/// Default resolver that uses dart-defines in debug/dev builds and CDN URLs
/// in release builds.
class DefaultGetModelService implements GetModelService {
  DefaultGetModelService(this.baseUrl, this.debugBundlePath);

  final Uri? baseUrl; // e.g. http://10.0.2.2:5600 provided via MODEL_BASE_URL
  final String? debugBundlePath;
  String? _manualBundleDirectory;

  void setManualBundleDirectory(String? path) {
    if (path == null || path.isEmpty) {
      _manualBundleDirectory = null;
    } else {
      _manualBundleDirectory = path;
    }
  }

  @override
  Future<ModelDescriptor> current() async {
    final manualDirectory = _manualBundleDirectory;
    if (manualDirectory != null) {
      return ModelDescriptor(
        bundleId: kBundledModelBundleId,
        version: kBundledModelVersion,
        uri: Uri.directory(manualDirectory, windows: Platform.isWindows),
        compression: ModelCompression.none,
      );
    }

    if (kDebugMode && debugBundlePath != null && debugBundlePath!.isNotEmpty) {
      return ModelDescriptor(
        bundleId: 'llama-3.2-1b-dev',
        version: 'local-dev',
        uri: Uri.directory(debugBundlePath!, windows: Platform.isWindows),
        compression: ModelCompression.none,
      );
    }

    if (kDebugMode && baseUrl != null) {
      return ModelDescriptor(
        bundleId: 'llama-3.2-1b-dev',
        version: 'remote-dev',
        uri: baseUrl!.resolve('models/Llama-3.2-1B-Instruct-q4f16_1-MLC.zip'),
        sha256Hex: '<DEV_SHA256_OPTIONAL>',
        sizeBytes: 0,
        compression: ModelCompression.zip,
      );
    }

    return ModelDescriptor(
      bundleId: 'qwen2.5-1.5b',
      version: '1.0.0',
      uri: Uri.https(
        'cdn.example.com',
        '/models/qwen2.5-1.5b-instruct-mlc.zip',
      ),
      sha256Hex: '<PROD_SHA256>',
      sizeBytes: 342 * 1024 * 1024,
      compression: ModelCompression.zip,
    );
  }
}
