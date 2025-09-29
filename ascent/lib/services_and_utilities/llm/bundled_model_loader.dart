import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

import 'bundled_model_constants.dart';

const _versionFileName = '.bundled_model_version';

Future<Directory> ensureBundledModelAvailable() async {
  final supportDir = await getApplicationSupportDirectory();
  final targetDir = Directory(
    '${supportDir.path}/mlc_models/$kBundledModelBundleId',
  );

  if (await _hasModelContents(targetDir)) {
    return targetDir;
  }

  if (await targetDir.exists()) {
    await targetDir.delete(recursive: true);
  }
  await targetDir.create(recursive: true);

  await _copyAssetDirectory(kBundledModelAssetDirectory, targetDir);
  final versionFile = File('${targetDir.path}/$_versionFileName');
  await versionFile.writeAsString(kBundledModelVersion);
  return targetDir;
}

Future<bool> _hasModelContents(Directory directory) async {
  final configFile = File('${directory.path}/mlc-app-config.json');
  if (!await configFile.exists()) {
    return false;
  }

  final versionFile = File('${directory.path}/$_versionFileName');
  if (!await versionFile.exists()) {
    return false;
  }

  try {
    final version = (await versionFile.readAsString()).trim();
    return version == kBundledModelVersion;
  } catch (_) {
    return false;
  }
}

Future<void> _copyAssetDirectory(String assetDir, Directory target) async {
  final manifest = await rootBundle.loadString('AssetManifest.json');
  final files = jsonDecode(manifest) as Map<String, dynamic>;
  final entries = files.keys
      .where((path) => path.startsWith(assetDir))
      .toList(growable: false);

  if (entries.isEmpty) {
    throw StateError('Bundled model assets missing for $assetDir.');
  }

  for (final assetPath in entries) {
    final relativePath = assetPath.substring(assetDir.length + 1);
    if (relativePath.isEmpty) {
      continue;
    }
    final outFile = File('${target.path}/$relativePath');
    await outFile.parent.create(recursive: true);
    final data = await rootBundle.load(assetPath);
    await outFile.writeAsBytes(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
    );
  }
}
