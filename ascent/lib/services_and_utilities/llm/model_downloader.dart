import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'model_descriptor.dart';

typedef DownloadProgress = void Function(int received, int? total);

/// Responsible for ensuring the model artifact exists locally.
class ModelDownloader {
  Future<File> ensureModel(
    ModelDescriptor descriptor, {
    DownloadProgress? onProgress,
  }) async {
    final dir = await getApplicationSupportDirectory();
    final file = File('${dir.path}/${descriptor.fileName}');
    if (await _isValid(file, descriptor.sha256Hex)) {
      return file;
    }

    await _download(descriptor, file, onProgress: onProgress);

    if (!await _isValid(file, descriptor.sha256Hex)) {
      if (await file.exists()) {
        await file.delete();
      }
      throw Exception('Model checksum failed (${descriptor.fileName})');
    }

    return file;
  }

  Future<void> deleteCached(ModelDescriptor descriptor) async {
    final dir = await getApplicationSupportDirectory();
    final file = File('${dir.path}/${descriptor.fileName}');
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<bool> _isValid(File file, String sha256Hex) async {
    if (!await file.exists()) {
      return false;
    }

    final digest = await sha256.bind(file.openRead()).first;
    if (sha256Hex.isEmpty || sha256Hex == '<DEV_SHA256_OPTIONAL>') {
      // Development builds can skip strict checksum validation.
      return true;
    }
    return digest.toString() == sha256Hex.toLowerCase();
  }

  Future<void> _download(
    ModelDescriptor descriptor,
    File target, {
    DownloadProgress? onProgress,
  }) async {
    target.createSync(recursive: true);

    if (descriptor.uri.isScheme('http') || descriptor.uri.isScheme('https')) {
      final client = http.Client();
      try {
        final request = http.Request('GET', descriptor.uri);
        final response = await client.send(request);
        if (response.statusCode != 200) {
          throw HttpException('Failed to download model: ${response.statusCode}');
        }

        final total = int.tryParse(response.headers['content-length'] ?? '') ??
            descriptor.sizeBytes;
        var received = 0;
        final sink = target.openWrite();
        await for (final chunk in response.stream) {
          received += chunk.length;
          sink.add(chunk);
          onProgress?.call(received, total);
        }
        await sink.close();
      } finally {
        client.close();
      }
      return;
    }

    if (descriptor.uri.isScheme('file')) {
      final source = File.fromUri(descriptor.uri);
      if (!await source.exists()) {
        throw FileSystemException('Debug model not found', source.path);
      }
      final total = await source.length();
      var received = 0;
      final sink = target.openWrite();
      await for (final chunk in source.openRead()) {
        received += chunk.length;
        sink.add(chunk);
        onProgress?.call(received, total);
      }
      await sink.close();
      return;
    }

    throw UnsupportedError('Unsupported model URI: ${descriptor.uri}');
  }
}
