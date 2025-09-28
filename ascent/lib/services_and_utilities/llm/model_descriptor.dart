import 'package:flutter/foundation.dart';

/// Describes the model artifact that should be loaded by the on-device LLM.
class ModelDescriptor {
  ModelDescriptor({
    required this.fileName,
    required this.sha256Hex,
    required this.uri,
    this.sizeBytes,
  });

  final String fileName;
  final String sha256Hex;
  final Uri uri;
  final int? sizeBytes;
}

/// Abstraction that resolves the active model descriptor.
abstract class GetModelService {
  Future<ModelDescriptor> current();
}

/// Default resolver that uses dart-defines in debug/dev builds and CDN URLs
/// in release builds.
class DefaultGetModelService implements GetModelService {
  DefaultGetModelService(this.baseUrl, this.debugModelPath);

  final Uri? baseUrl; // e.g. http://10.0.2.2:5600 provided via MODEL_BASE_URL
  final String? debugModelPath;

  @override
  Future<ModelDescriptor> current() async {
    if (kDebugMode && baseUrl != null) {
      return ModelDescriptor(
        fileName: 'Llama-3.2-1B-Instruct-Q4_K_M.gguf',
        sha256Hex: '<DEV_SHA256_OPTIONAL>',
        uri: baseUrl!.resolve('models/Llama-3.2-1B-Instruct-Q4_K_M.gguf'),
      );
    }

    if (kDebugMode && debugModelPath != null && debugModelPath!.isNotEmpty) {
      return ModelDescriptor(
        fileName: 'Llama-3.2-1B-Instruct-Q4_K_M.gguf',
        sha256Hex: '<DEV_SHA256_OPTIONAL>',
        uri: Uri.file(debugModelPath!),
      );
    }

    return ModelDescriptor(
      fileName: 'qwen2.5-1.5b-instruct-q4.gguf',
      sha256Hex: '<PROD_SHA256>',
      uri: Uri.https('cdn.example.com', '/models/qwen2.5-1.5b-instruct-q4.gguf'),
      sizeBytes: 342 * 1024 * 1024,
    );
  }
}
