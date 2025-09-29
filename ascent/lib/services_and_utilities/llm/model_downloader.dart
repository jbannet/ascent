import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'model_descriptor.dart';

typedef DownloadProgress = void Function(int received, int? total);

const _metadataFileName = '.mlc_descriptor.json';

/// Responsible for ensuring the model bundle exists locally.
class ModelDownloader {
  Future<Directory> ensureModel(
    ModelDescriptor descriptor, {
    DownloadProgress? onProgress,
  }) async {
    final targetDir = await _targetDirectory(descriptor.bundleId);

    if (await _isValidBundle(targetDir, descriptor)) {
      return targetDir;
    }

    if (await targetDir.exists()) {
      await targetDir.delete(recursive: true);
    }
    await targetDir.create(recursive: true);

    switch (descriptor.compression) {
      case ModelCompression.none:
        await _materializeDirectoryBundle(
          descriptor,
          targetDir,
          onProgress: onProgress,
        );
        break;
      case ModelCompression.zip:
        await _downloadAndExtractArchive(
          descriptor,
          targetDir,
          onProgress: onProgress,
        );
        break;
    }

    await _writeMetadata(targetDir, descriptor);
    return targetDir;
  }

  Future<void> deleteCached(ModelDescriptor descriptor) async {
    final targetDir = await _targetDirectory(descriptor.bundleId);
    if (await targetDir.exists()) {
      await targetDir.delete(recursive: true);
    }
  }

  Future<Directory> _targetDirectory(String bundleId) async {
    final supportDir = await getApplicationSupportDirectory();
    final modelsRoot = Directory('${supportDir.path}/mlc_models');
    if (!await modelsRoot.exists()) {
      await modelsRoot.create(recursive: true);
    }
    return Directory('${modelsRoot.path}/$bundleId');
  }

  Future<bool> _isValidBundle(
    Directory directory,
    ModelDescriptor descriptor,
  ) async {
    if (!await directory.exists()) {
      return false;
    }

    final metadataFile = File('${directory.path}/$_metadataFileName');
    if (!await metadataFile.exists()) {
      return false;
    }

    try {
      final data =
          jsonDecode(await metadataFile.readAsString()) as Map<String, dynamic>;
      if (data['version'] != descriptor.version) {
        return false;
      }
      final recordedSha = data['sha256'] as String?;
      final expectedSha = descriptor.sha256Hex;
      if (expectedSha != null &&
          expectedSha.isNotEmpty &&
          expectedSha != '<DEV_SHA256_OPTIONAL>' &&
          recordedSha != expectedSha) {
        return false;
      }
    } catch (_) {
      return false;
    }

    final configFile = File('${directory.path}/mlc-app-config.json');
    return await configFile.exists();
  }

  Future<void> _materializeDirectoryBundle(
    ModelDescriptor descriptor,
    Directory targetDir, {
    DownloadProgress? onProgress,
  }) async {
    if (!descriptor.uri.isScheme('file')) {
      throw UnsupportedError(
        'Only local directory bundles are supported for now.',
      );
    }

    final source = Directory.fromUri(descriptor.uri);
    if (!await source.exists()) {
      throw FileSystemException('Model bundle not found', source.path);
    }

    final totalBytes = await _directorySize(source);
    var copiedBytes = 0;

    // Ensure we create directories before copying files.
    await for (final entity in source.list(
      recursive: true,
      followLinks: false,
    )) {
      final relativePath = _relativePath(source.uri, entity.uri);
      if (entity is Directory) {
        await Directory.fromUri(
          targetDir.uri.resolve('$relativePath/'),
        ).create(recursive: true);
      }
    }

    await for (final entity in source.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is! File) continue;
      final relativePath = _relativePath(source.uri, entity.uri);
      final destination = File.fromUri(targetDir.uri.resolve(relativePath));
      await destination.parent.create(recursive: true);
      await entity.copy(destination.path);
      copiedBytes += await destination.length();
      onProgress?.call(copiedBytes, totalBytes);
    }

    if (totalBytes == 0) {
      onProgress?.call(0, 0);
    } else {
      onProgress?.call(totalBytes, totalBytes);
    }
  }

  Future<void> _downloadAndExtractArchive(
    ModelDescriptor descriptor,
    Directory targetDir, {
    DownloadProgress? onProgress,
  }) async {
    throw UnsupportedError('Remote archive downloads are not yet implemented.');
  }

  Future<int> _directorySize(Directory directory) async {
    var total = 0;
    await for (final entity in directory.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is File) {
        total += await entity.length();
      }
    }
    return total;
  }

  String _relativePath(Uri base, Uri entity) {
    final basePath = base.path.endsWith('/') ? base.path : '${base.path}/';
    final entityPath = entity.path;
    if (!entityPath.startsWith(basePath)) {
      return entityPath;
    }
    var relative = entityPath.substring(basePath.length);
    if (relative.endsWith('/')) {
      relative = relative.substring(0, relative.length - 1);
    }
    if (relative.startsWith('/')) {
      relative = relative.substring(1);
    }
    return Uri.decodeComponent(relative);
  }

  Future<void> _writeMetadata(
    Directory directory,
    ModelDescriptor descriptor,
  ) async {
    final metadataFile = File('${directory.path}/$_metadataFileName');
    final payload = <String, dynamic>{
      'bundleId': descriptor.bundleId,
      'version': descriptor.version,
      'sha256': descriptor.sha256Hex,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    await metadataFile.writeAsString(jsonEncode(payload));
  }
}
