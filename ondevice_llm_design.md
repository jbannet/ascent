# On-Device LLM Integration Plan for Flutter App

## 🎯 Objective

Enable **offline sentence rephrasing/paraphrasing** in a Flutter app using a **tiny on-device LLM**. The goal is to keep the base app size small while allowing users to optionally download a lightweight model (\~120–450 MB) for privacy-preserving, local text rewriting.

---

## 📦 Model Options & Tradeoffs

| Model                     | Size (Q4 quant) | Pros                                                  | Cons                                              |
| ------------------------- | --------------- | ----------------------------------------------------- | ------------------------------------------------- |
| **Qwen2.5-0.5B-Instruct** | \~120–200 MB    | Smallest; fastest; works well for very short rewrites | May lose nuance or fluency vs larger models       |
| **Llama-3.2-1B-Instruct** | \~250–350 MB    | Balanced size vs quality; good general option         | Slightly larger download; slower on older devices |
| **Qwen2.5-1.5B-Instruct** | \~300–450 MB    | Noticeable quality bump; stronger style fidelity      | Larger footprint; slower than 0.5B/1B             |

👉 **Production choice:** ship only **Qwen2.5-1.5B**. That model delivers the quality we want; the smaller checkpoints remain useful for development/testing but are not selectable in the release UI.

---

## 🗂️ Directory Structure

```
your_app/
├─ lib/
│  ├─ main.dart
│  ├─ llm/
│  │  ├─ llm_bridge.dart        # Flutter-facing API (rewrite method)
│  │  └─ model_downloader.dart  # Handles first-use model download + checksum
│
├─ ios/Runner/
│  ├─ AppDelegate.swift
│  ├─ LlmEngine.swift           # Wrapper around MLC/llama.cpp runtime
│  └─ (MLC or llama.cpp sources/xcframework)
│
├─ android/app/src/main/
│  ├─ java/com/yourco/app/LlmEngine.kt  # Wrapper with token streaming
│  ├─ jniLibs/ (llama.cpp only)          # .so files if using NDK
│  └─ (MLC or llama.cpp runtime configs)
│
├─ tools/
│  ├─ models.json                # URLs + SHA-256 checksums + sizes
│  └─ make_checksums.sh          # Helper script for integrity checks
└─ README-llm.md                 # Dev notes and QA checklist
```

---

## ⚙️ Runtime Options

### Option A — **MLC LLM** (recommended)

- Prebuilt runtimes for iOS (Metal) and Android (Vulkan).
- Easy model packaging, GPU acceleration out of the box.

### Option B — **llama.cpp**

- GGUF model format, huge ecosystem.
- iOS: add via Swift Package / static lib.
- Android: build via NDK/CMake (.so per ABI).
- More flexible, but more setup work.

Both expose the same surface API to Flutter: `rewrite(text, style, maxTokens)` streaming tokens back.

---

## 🔄 Run-time Flow

1. User taps **“Rewrite”** or enables **“Offline rewriting”**.
2. **Downloader** checks for model file in app-private storage. If missing or invalid:
   - Prompt: *“Download model (\~350 MB)?”*
   - Stream to temp file, verify **SHA-256 checksum**, then move to final path.
3. **Engine** initializes once with `modelPath`, `useGPU=true`, small KV cache.
4. Flutter calls `rewrite()` **only when the engine is `ready`.**
5. Native runtime streams tokens → Flutter UI via `EventChannel`.
6. UI appends tokens in real time.

---

## 🔑 Flutter API Design

### Example Method (Dart)

```dart
Stream<String> rewrite(
  String text, {
  String stylePrompt = Prompts.concise,
  int maxTokens = 96,
  double temperature = 0.3,
  double topP = 0.9,
});
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
  static const concise =
      'You are a concise rewriting assistant. Preserve meaning. US English. ≤2 sentences.';
  static const friendly =
      'You are a friendly assistant. Preserve meaning but make the text warmer and encouraging. US English.';
  static const formal =
      'You are a formal rewriting assistant. Maintain a professional tone while keeping the original intent. US English.';
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
- `initializing`: show a blocking spinner/progress indicator while `llmService.init()` runs.
- `ready`: enable the rewrite input and stream results.

```

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
- Use **MLC LLM** or **llama.cpp** for native runtime.
- Expose one Flutter API (`rewrite`) with streamed tokens.
- Provide a Settings toggle so users can remove the downloaded model.
- Fine to make user wait a short time for the rewrites.
- Can incorporate blocking UI into select workflows as needed.


---

# 🧩 Implementation Code (Flutter + iOS + Android)

Below are copy‑pasteable implementations for each file we discussed. The native "engine" shows a clean hook point for **MLC LLM** (recommended). If you choose **llama.cpp** instead, replace the marked sections with llama.cpp calls; the Flutter API remains the same.

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

## 1) Flutter bridge (streaming tokens)

``

```dart
import 'dart:async';
import 'package:flutter/services.dart';

class LlmBridge {
  static const _method = MethodChannel('llm');
  static const _events = EventChannel('llm_stream');

  static Stream<String> rewrite(
    String text, {
    String style = 'concise',
    int maxTokens = 96,
    double temperature = 0.3,
    double topP = 0.9,
  }) async* {
    // Start listening BEFORE invoking, so early tokens aren’t missed
    final controller = StreamController<String>();
    final sub = _events
        .receiveBroadcastStream()
        .listen(controller.add, onError: controller.addError, onDone: controller.close);

    await _method.invokeMethod('startGeneration', {
      'prompt': _prompt(text, style),
      'max_tokens': maxTokens,
      'temperature': temperature,
      'top_p': topP,
    });

    yield* controller.stream;
    await sub.cancel();
  }

  static String _prompt(String text, String style) =>
      'System: You are a concise rewriting assistant. Preserve meaning. US English. \u22642 sentences. Style: '
      '$style.

User: Rewrite: "${text.replaceAll('"', '\"')}"
Assistant:';
}
```

---

## 2) Model downloader (first‑use download + checksum + progress)

``

```dart
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

typedef Progress = void Function(int received, int? total);

class ModelDownloader {
  final String fileName;
  final String sha256Hex; // lowercase hex
  final Uri url;

  ModelDownloader({required this.fileName, required this.sha256Hex, required this.url});

  Future<File> ensureModel({Progress? onProgress}) async {
    final dir = await getApplicationSupportDirectory();
    final file = File('${dir.path}/$fileName');
    if (await _isValid(file)) return file;
    await _download(file, onProgress: onProgress);
    if (!await _isValid(file)) {
      if (await file.exists()) await file.delete();
      throw Exception('Model checksum failed');
    }
    return file;
  }

  Future<bool> _isValid(File f) async {
    if (!await f.exists()) return false;
    final stream = f.openRead();
    final digest = await sha256.bind(stream).first;
    return digest.toString() == sha256Hex.toLowerCase();
  }

  Future<void> _download(File target, {Progress? onProgress}) async {
    target.createSync(recursive: true);
    final req = http.Request('GET', url);
    final resp = await http.Client().send(req);
    if (resp.statusCode != 200) {
      throw HttpException('Failed to download model: ${resp.statusCode}');
    }
    final total = int.tryParse(resp.headers['content-length'] ?? '');
    var received = 0;
    final sink = target.openWrite();
    await for (final chunk in resp.stream) {
      received += chunk.length;
      sink.add(chunk);
      onProgress?.call(received, total);
    }
    await sink.close();
  }
}
```

**Usage example (before first generation):**

```dart
final downloader = ModelDownloader(
  fileName: 'qwen2.5-0.5b-instruct-q4.bin',
  sha256Hex: '<PUT_SHA256_HERE>',
  url: Uri.parse('https://your-cdn.example/models/qwen2.5-0.5b-instruct-q4.bin'),
);
final modelFile = await downloader.ensureModel(onProgress: (r, t) {
  // update a progress bar: (r / (t ?? 1))
});
```

---

## 3) A tiny service that ties it together

``

```dart
import 'dart:async';
import 'package:flutter/services.dart';
import 'model_downloader.dart';

enum LlmState { disabled, initializing, ready }

class LlmService {
  static const _method = MethodChannel('llm');
  final ModelDownloader downloader;
  LlmState state = LlmState.disabled;

  LlmService(this.downloader);

  Future<void> init({void Function(int,int?)? onProgress}) async {
    if (state == LlmState.ready || state == LlmState.initializing) return;
    state = LlmState.initializing;
    try {
      final modelFile = await downloader.ensureModel(onProgress: onProgress);
      await _method.invokeMethod('initEngine', {
        'model_path': modelFile.path,
        'use_gpu': true,
        'n_ctx': 2048,
      });
      state = LlmState.ready;
    } catch (e) {
      state = LlmState.disabled;
      rethrow;
    }
  }
}
```

> Call `await service.init()` during feature enablement (or lazily before first rewrite).

---

## 4) iOS native bridge (Swift, with hook points for **MLC LLM**)

`` (simplified skeleton)

```swift
import Foundation
import Flutter
import os
// import MLC runtime here, e.g. import MLC

final class LlmEngine: NSObject, FlutterStreamHandler {
  private var sink: FlutterEventSink?
  private var initialized = false
  // private var model: MLCModel? // your MLC model handle

  func initialize(modelPath: String, useGPU: Bool, nCtx: Int) throws {
    guard !initialized else { return }
    // model = try MLCModel(path: modelPath, useMetal: useGPU, context: nCtx)
    initialized = true
  }

  func generate(prompt: String, maxTokens: Int, temperature: Double, topP: Double) {
    guard initialized else { sink?(FlutterError(code: "LLM", message: "Not initialized", details: nil)); return }
    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
      guard let self = self else { return }
      // Pseudocode for MLC token streaming:
      // model!.generate(prompt: prompt, maxTokens: maxTokens, temperature: temperature, topP: topP) { token in
      //   self.sink?(token)
      // }
      // On completion:
      self.sink?(FlutterEndOfEventStream)
    }
  }

  // MARK: FlutterStreamHandler
  func onListen(withArguments args: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? { sink = events; return nil }
  func onCancel(withArguments args: Any?) -> FlutterError? { sink = nil; return nil }
}
```

`` (channel wiring)

```swift
import UIKit
import Flutter

@UIApplicationMain
class AppDelegate: FlutterAppDelegate {
  let engine = LlmEngine()

  override func application(_ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    let controller = window?.rootViewController as! Flutt
```
