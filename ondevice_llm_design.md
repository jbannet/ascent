# On-Device LLM Integration Plan for Flutter App

## 🎯 Objective

Enable **offline sentence rephrasing/paraphrasing** in a Flutter app using a **tiny on-device LLM**. The goal is to keep the base app size small while allowing users to optionally download a lightweight model for privacy-preserving, local text rewriting.

---

## 🗂️ Directory Structure

```
your_app/
├─ lib/
│  ├─ main.dart
│  ├─ services_and_utilities/llm/
│  │  ├─ model_descriptor.dart   # Resolves dev/CDN GGUF targets
│  │  ├─ model_downloader.dart   # Streams + verifies model files
│  │  ├─ llm_service.dart        # Singleton around llama_cpp
│  │  ├─ prompts.dart            # Persona definitions
│  │  └─ llm_bridge.dart         # Flutter-facing rewrite helper
│  └─ workflow_views/testing/llm_rewrite_test_view.dart  # QA harness UI
│
├─ tools/
│  ├─ models.json                # URLs + SHA-256 checksums + sizes
│  └─ make_checksums.sh          # Helper script for integrity checks
└─ ggruf_models/                 # Local dev GGUFs (ignored in release)
```

> The `llama_cpp` package bundles its own native binaries, so iOS and Android no longer require custom `LlmEngine` shims—linking the plugin is enough.

---

## ⚙️ Runtime Stack

We standardize on the [`llama_cpp`](https://pub.dev/packages/llama_cpp) Dart package for on-device inference on both iOS and Android. The package ships prebuilt native libraries, exposes a streaming token API, and natively consumes our GGUF checkpoints—no custom platform channels or engine forks required.

All environments (debug, emulator, physical device, production) exercise the same fetch path:

1. `GetModelService` resolves the active `ModelDescriptor` (filename, SHA-256, source URI).
2. `ModelDownloader.ensureModel(descriptor)` streams the file into app support storage, whether the URI is `https://` (CDN) or `file://` / `http://localhost` (developer builds).
3. `LlmService.ensureEngine()` hands the resulting file path to `LlamaCpp.load(...)`.

### Integration principles

- Initialize a single `LlamaCpp` instance per app session and reuse it for all rewrite requests.
- Keep the Flutter-facing contract identical (`rewrite(text, style, temperature, ...)`) so the UI state machine remains unchanged.
- Resolve the model before the first `LlamaCpp.load(...)` call; the fetch is cheap in debug when the descriptor points at a local source, but we still run it to validate checksums and placement.
- Surface the download status via the existing progress callbacks so the UI behaves consistently between debug and production.
- Default the paraphrasing temperature to `0.7` for test runs so personas feel distinct while remaining grounded.

### Dev-mode fetch targets

For debug/profile builds we store the checkpoint at `/Users/jonathanbannet/MyProjects/fitness_app/ggruf_models/Llama-3.2-1B-Instruct-Q4_K_M.gguf` and expose it through environment-aware URIs:

| Platform | Emulator/Simulator | Physical device (USB/Wi-Fi) |
| -------- | ----------------- | --------------------------- |
| Android  | `http://10.0.2.2:5600/models/Llama-3.2-1B-Instruct-Q4_K_M.gguf` | `http://{LAN_IP}:5600/...` (served via `python -m http.server` or similar) |
| iOS      | `http://127.0.0.1:5600/models/Llama-3.2-1B-Instruct-Q4_K_M.gguf` | `http://{LAN_IP}:5600/...` |
| macOS / desktop tests | `file:///Users/jonathanbannet/.../ggruf_models/Llama-3.2-1B-Instruct-Q4_K_M.gguf` | same |

> Run `tools/model_dev_server.dart` (to be created) or `python -m http.server --directory ggruf_models 5600` before launching the app in debug. Pass the base URL through a `--dart-define MODEL_BASE_URL=...` flag so `GetModelService` can stitch the full URI.

> Emulator tip: `10.0.2.2` maps the host loopback for the Android emulator, while the iOS simulator can reach `127.0.0.1` directly. For physical devices, share the model over the LAN (e.g. `http://192.168.1.44:5600/`) or fall back to the staging CDN.

Release builds continue to rely on the CDN-backed descriptor defined in `tools/models.json`.

---

## 🔄 Run-time Flow

1. User taps **“Rewrite”** or enables **“Offline rewriting”**.
2. `GetModelService` resolves the active descriptor, `ModelDownloader` fetches it if app storage lacks a valid copy (same progress UI in debug and prod).
   - Prompt: *“Download model (\~350 MB)?”* (in debug this may read *“Fetch local model…”* but the UX path is identical).
   - Stream/copy to temp file, verify **SHA-256 checksum**, then move to final path.
3. **Engine** initializes once with `modelPath`, `useGPU=true`, small KV cache.
4. Flutter calls `rewrite()` **only when the engine is `ready`.**
5. `llmService.answer()` yields a `Stream<String>` from the `llama_cpp` engine; Flutter listens via `StreamBuilder`/`Bloc` and updates the text field incrementally.
6. UI appends tokens in real time.

---

## 🔑 Flutter API Design

### Example Method (Dart)

```dart
Stream<String> rewrite(
  String text, {
  String stylePrompt = Prompts.direct,
  double temperature = 0.7,
  double topP = 0.9,
}) async* {
  final prompt = _prompt(text, stylePrompt);
  await llmService.ensureEngine();
  yield* llmService.answer(
    prompt,
    temperature: temperature,
    topP: topP,
  );
}
```

### llama_cpp usage snippet

```dart
import 'package:llama_cpp/llama_cpp.dart';

final path = '/path/to/your/LLM.gguf';
final llama = await LlamaCpp.load(path, verbose: true);

await for (final text in llama.answer(prompt)) {
  stdout.write(text);
}
stdout.writeln();

await llama.dispose();
```

### Prompt Template

```
System: {STYLE_PROMPT}
User: Rewrite: "<TEXT>"
Assistant:
```

Where we provide a small set of vetted prompts:

```dart
abstract class Prompts {
  static const friendly =
      'You are a friendly assistant. Preserve meaning but make the text warmer, encouraging, and supportive. US English.';
  static const direct =
      'You are a direct assistant. Deliver recommendations with clear, no-fluff instructions while staying respectful. US English.';
  static const motivational =
      'You are an energetic coach. Motivate the user with upbeat language and actionable encouragement. US English.';
  static const educational =
      'You are an educational assistant. Explain the benefit behind each recommendation in clear, instructional language. US English.';

  static String byKey(String key) => const {
        'friendly': friendly,
        'direct': direct,
        'motivational': motivational,
        'educational': educational,
      }[key] ?? direct;
}

### Engine state model

Track a simple tri-state enum so the UI can react appropriately:

```dart
enum LlmState {
  disabled, // feature off or model not downloaded
  initializing, // model download complete; engine booting
  ready, // engine warmed up and can accept rewrite requests
}
```

- `disabled`: show a call-to-action to download the model.
- `initializing`: show a blocking spinner/progress indicator while `llmService.ensureEngine()` downloads/boots the model.
- `ready`: enable the rewrite input and stream results.

---

## 🧪 Initial Recommendations Test Harness

- Add a `Try LLM Rewrite` button to the internal testing screen; this reveals the persona selector and the `Clear cached model` control.
- Provide a `Clear cached model` button that awaits `llmService.clearCache()` so QA can re-run the download/initialization path on demand (the button should also reset any rendered output/state).
- Render a 2×2 grid of tones: **Friendly**, **Direct**, **Motivational**, **Educational**. When a tone is tapped, check `llmService.state`; if not `ready`, call `llmService.ensureEngine(onProgress: ...)` and show a **Loading model…** indicator. Once the engine resolves, start the `rewrite()` stream, flip the status copy to **Thinking…**, and append tokens to the UI as they arrive so the text renders character-by-character.
- Pull the existing recommendations list (array of sentences) and rewrite each entry sequentially:

```dart
Future<List<String>> rewriteRecommendations({
  required String personaKey,
  void Function(int index, String partial)? onPartial,
}) async {
  await llmService.ensureEngine();
  final outputs = <String>[];
  for (var i = 0; i < recommendations.length; i++) {
    final buffer = StringBuffer();
    await for (final token in LlmBridge.rewrite(
      recommendations[i],
      style: personaKey,
      temperature: 0.7,
    )) {
      buffer.write(token);
      onPartial?.call(i, buffer.toString());
    }
    final completed = buffer.toString().trim();
    outputs.add(completed);
    onPartial?.call(i, completed);
  }
  return outputs;
}
```

- `recommendations` refers to the current in-app recommendation sentences; fetch them from existing state before invoking this helper.
- Display the rewritten sentences directly beneath the tone grid in a scrollable column so testers can compare tone differences quickly (clear and repopulate as each sentence finishes).
- Reset the output when a new tone is selected so the list always reflects the currently active persona.

---

## 📱 Storage Locations

- **iOS:** `NSApplicationSupportDirectory`
- **Android:** `Context.getFilesDir()` or `getNoBackupFilesDir()`

> Do **not** bundle in `/assets`. Always download on first use to keep the app lightweight.

---

## 🛡️ Privacy & Compliance

- Generation stays **on-device** (no server calls).
- **No logging** of user text.
- Optional at-rest encryption:
  - iOS: Data Protection classes.
  - Android: EncryptedFile + KeyStore.
- Provide toggle to **remove model** and reclaim space.

---

## ✅ Summary

- Keep base app small (<150 MB).
- Offer optional download of **0.5B–1.5B LLMs** (\~120–450 MB).
- Use **llama_cpp** end-to-end (Dart package + bundled native runtime).
- Expose one Flutter API (`rewrite`) with streamed tokens.
- Provide a Settings toggle so users can remove the downloaded model.
- Add a QA-only **Clear cached model** control that calls `llmService.clearCache()` to rerun the download/init flow.
- Fine to make user wait a short time for the rewrites.
- Can incorporate blocking UI into select workflows as needed.


---

# 🧩 Implementation Code (Flutter + iOS + Android)

Below are copy‑pasteable implementations for each file we discussed. Everything funnels through the `llama_cpp` Dart package, so the platform layers mostly orchestrate downloads and lifecycle—no custom native token streaming is required.

## 0) Dependencies

### `pubspec.yaml`

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.2
  crypto: ^3.0.3
  path_provider: ^2.1.4
```

> If you use Hive/SQLite to cache outputs, add those packages as desired.

---

## 1) Flutter integration (streaming tokens)

```dart
import 'dart:async';
import 'llm_service.dart';

class LlmBridge {
  static Stream<String> rewrite(
    String text, {
    String style = 'direct',
    double temperature = 0.7,
    double topP = 0.9,
  }) async* {
    final persona = _stylePrompts[style] ?? Prompts.direct;
    final prompt = _prompt(text, persona);
    await llmService.ensureEngine();
    yield* llmService.answer(
      prompt,
      temperature: temperature,
      topP: topP,
    );
  }

  static const Map<String, String> _stylePrompts = {
    'friendly': Prompts.friendly,
    'direct': Prompts.direct,
    'motivational': Prompts.motivational,
    'educational': Prompts.educational,
  };

  static String _prompt(String text, String persona) {
    final sanitized = text.replaceAll('"', r'\"');
    return 'System: ${persona}\n\nUser: Rewrite: "${sanitized}"\nAssistant:';
  }
}
```

---

## 2) Model fetch (descriptor + downloader)

```dart
import 'package:flutter/foundation.dart';

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

abstract class GetModelService {
  Future<ModelDescriptor> current();
}

class DefaultGetModelService implements GetModelService {
  DefaultGetModelService(this.baseUrl, this.debugModelPath);

  final Uri? baseUrl; // sourced from env/dart-define, e.g. http://10.0.2.2:5600
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
    if (kDebugMode && debugModelPath != null) {
      return ModelDescriptor(
        fileName: 'Llama-3.2-1B-Instruct-Q4_K_M.gguf',
        sha256Hex: '<DEV_SHA256_OPTIONAL>',
        uri: Uri.file(debugModelPath!),
      );
    }
    // Production descriptor
    return ModelDescriptor(
      fileName: 'qwen2.5-1.5b-instruct-q4.gguf',
      sha256Hex: '<PROD_SHA256>',
      uri: Uri.https('cdn.example.com', '/models/qwen2.5-1.5b-instruct-q4.gguf'),
      sizeBytes: 342 * 1024 * 1024,
    );
  }
}
```

> Use `device_info_plus` (Android: `isPhysicalDevice`, iOS: `isPhysicalDevice`) or platform checks to decide which `MODEL_BASE_URL` to supply when wiring up debug runs. A simple `EnvConfig` can read dart-defines and fall back to the LAN URL when connected to a physical handset.
> `Uri.file` is only viable for macOS/unit tests where the host filesystem is visible. Prefer an HTTP base URL for emulators and real devices.

```dart
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

typedef Progress = void Function(int received, int? total);

class ModelDownloader {
  Future<File> ensureModel(
    ModelDescriptor descriptor, {
    Progress? onProgress,
  }) async {
    final dir = await getApplicationSupportDirectory();
    final file = File('${dir.path}/${descriptor.fileName}');
    if (await _isValid(file, descriptor.sha256Hex)) return file;
    await _download(descriptor, file, onProgress: onProgress);
    if (!await _isValid(file, descriptor.sha256Hex)) {
      if (await file.exists()) await file.delete();
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

  Future<bool> _isValid(File f, String sha256Hex) async {
    if (!await f.exists()) return false;
    final stream = f.openRead();
    final digest = await sha256.bind(stream).first;
    return digest.toString() == sha256Hex.toLowerCase();
  }

  Future<void> _download(
    ModelDescriptor descriptor,
    File target, {
    Progress? onProgress,
  }) async {
    target.createSync(recursive: true);
    if (descriptor.uri.isScheme('http') || descriptor.uri.isScheme('https')) {
      final client = http.Client();
      try {
        final req = http.Request('GET', descriptor.uri);
        final resp = await client.send(req);
        if (resp.statusCode != 200) {
          throw HttpException('Failed to download model: ${resp.statusCode}');
        }
        final total = int.tryParse(resp.headers['content-length'] ?? '') ?? descriptor.sizeBytes;
        var received = 0;
        final sink = target.openWrite();
        await for (final chunk in resp.stream) {
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
```

**Usage example (before first generation):**

```dart
final descriptor = await getModelService.current();
final modelFile = await modelDownloader.ensureModel(
  descriptor,
  onProgress: (received, total) {
    // update a progress bar: (received / (total ?? descriptor.sizeBytes ?? 1))
  },
);
```

---

## 3) A tiny service that ties it together

``

```dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:llama_cpp/llama_cpp.dart';
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
    if (_llama != null) return _llama!;
    state = LlmState.initializing;
    try {
      final descriptor = await getModelService.current();
      _activeDescriptor = descriptor;
      final modelFile = await downloader.ensureModel(
        descriptor,
        onProgress: onProgress,
      );
      _llama = await LlamaCpp.load(
        modelFile.path,
        verbose: kDebugMode || kProfileMode,
      );
      state = LlmState.ready;
      return _llama!;
    } catch (e) {
      state = LlmState.disabled;
      rethrow;
    }
  }

  Stream<String> answer(String prompt) {
    final llama = _llama;
    if (state != LlmState.ready || llama == null) {
      throw StateError('Engine not ready. Call ensureEngine() first.');
    }
    return llama.answer(prompt);
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

const rawModelBaseUrl = String.fromEnvironment('MODEL_BASE_URL', defaultValue: '');
final baseUri = rawModelBaseUrl.isEmpty ? null : Uri.parse(rawModelBaseUrl);

final getModelService = DefaultGetModelService(
  baseUri,
  kDebugMode
      ? '/Users/jonathanbannet/MyProjects/fitness_app/ggruf_models/Llama-3.2-1B-Instruct-Q4_K_M.gguf'
      : null,
);

final modelDownloader = ModelDownloader();

final llmService = LlmService(
  getModelService: getModelService,
  downloader: modelDownloader,
);
```

> Call `await llmService.ensureEngine()` during feature enablement (or lazily before first rewrite) and remember to invoke `await llmService.dispose()` on shutdown/tests. The QA **Clear cached model** button should call `await llmService.clearCache()` to remove the cached GGUF before re-running the flow.
