# On-Device LLM Integration Plan for Flutter App (MLC-LLM)

## 🎯 Objective

Enable **offline sentence rephrasing/paraphrasing** in the Flutter app using the **MLC-LLM runtime**. We bundle (or download on demand) a compact Llama-family checkpoint compiled via MLC so rewrites remain private, low-latency, and GPU-accelerated on iOS and Android.

---

## 🗂️ Directory Structure

```
your_app/
├─ lib/
│  ├─ main.dart
│  ├─ services_and_utilities/llm/
│  │  ├─ bundled_model_constants.dart # Shared IDs/paths for the packaged bundle
│  │  ├─ bundled_model_loader.dart    # Copies bundled assets into Application Support
│  │  ├─ model_descriptor.dart        # Resolves packaged vs. CDN model bundles (.mlc artifacts)
│  │  ├─ model_downloader.dart        # Copies local bundles or future OTA archives
│  │  ├─ llm_service.dart             # Singleton around the MethodChannel bridge
│  │  ├─ mlc_bridge.dart              # Dart helper wrapping MethodChannel/EventChannel
│  │  ├─ prompts.dart                 # Persona definitions
│  │  └─ llm_bridge.dart              # Flutter-facing rewrite helper
│  └─ workflow_views/testing/llm_rewrite_test_view.dart
│
├─ ios/Runner/MLC/                    # Native bridge wrapper
│  └─ MLCBridge.swift                 # Flutter MethodChannel/EventChannel hook
│
├─ mlc/                               # Scripts for regenerating bundles
│  ├─ models/                         # Compiled model bundles (params, tokenizer, config)
│  ├─ build_ios.sh                    # Helper wrapper for packaging iOS outputs
│  ├─ build_android.sh                # Helper wrapper for Android ABIs
│  └─ README.md                       # Notes on rebuild steps & prerequisites
│
├─ assets/
│  └─ mlc_models/
│     └─ Llama-3.2-1B-Instruct-q4f16_1-MLC/  # Bundle copied from mlc-llm/ios/MLCChat/dist/bundle
│
├─ tools/
│  ├─ models.json                     # CDN descriptors + SHA-256 for OTA downloads
│  └─ serve_models.dart               # Local dev HTTP server for simulator/emulator testing
└─ ggruf_models/                      # Legacy GGUFs kept for reference (no longer used)
```

---

## ⚙️ Runtime Stack

We standardize on **MLC-LLM** because it provides:
- Pre-optimized runtimes for iOS (Metal) and Android (Vulkan/CUDA) with Flutter-friendly latency.
- Python/TVM tooling (`mlc_llm`) to compile Llama/Mistral-style models into device-specific “model lib” bundles (JSON + params + precompiled kernels).
- Reference native code for streaming generation that we can lift into Flutter via platform channels.

### Tooling prerequisites

1. **Install MLC tooling**: run `pip install mlc-llm` (or the prebuilt wheel) and ensure the platform toolchains are in place (Python ≥3.10, Xcode for iOS, Android NDK r26). Validate the environment by invoking `mlc_llm --help`; if it succeeds without missing-tool errors you’re ready to use the packaged models.
2. **Use pre-built quantized models**: MLC publishes ready-to-serve bundles such as `Llama-3.2-1B-Instruct-q4f16_1-MLC`. These can be loaded directly without custom conversion.
3. **iOS runtime integration**:
   - Clone the repo locally: `git clone https://github.com/mlc-ai/mlc-llm.git`
   - Generate runtime libraries with `mlc_llm package` inside `ios/MLCChat`.
   - Produce both device and simulator slices via `ios/prepare_libs.sh` and merge them into fat archives in `ios/MLCChat/dist/lib` (see “Universal archives” below).
   - The local Swift package (`ios/MLCSwift`) links everything from `dist/lib`, so Runner only needs the custom bridge file under `Runner/MLC/MLCBridge.swift`.
   - Register `MLCBridgePlugin` from `AppDelegate` and keep the deployment target at iOS 14 or newer.
4. **Android runtime integration** (future step): after running `mlc_llm package` in `android/MLCChat`, include the generated modules or JNI libs in Gradle (`mlc4j`, `jniLibs`, etc.).
5. **Flutter platform-channel setup**: create `MethodChannel`/`EventChannel` pairs (`mlc_bridge` / `mlc_bridge/events`) for initialization, streaming tokens, cancellation, and shutdown.

### Integration principles

- **Native bridges**: `MLCBridge.swift` wraps `JSONFFIEngine`/`MLCEngine`, managing `initialize`, streaming `generate`, cancellation, and shutdown, while forwarding tokens over the event channel.
- **Dart façade**: `mlc_bridge.dart` centralises the method/event channel logic and exposes a `Stream<String>` for token streaming.
- **Model resolution**: `DefaultGetModelService` accepts an override directory from the bundled loader so `ModelDownloader` can validate/write metadata without touching the network.
- **Caching**: Once the bundle is copied/validated it stays in App Support; `clearCache()` deletes the directory so QA can replay the first-run flow.


## 📦 Package Integration (iOS SwiftPM)

- **Swift tools 5.9**: `ios/MLCSwift/Package.swift` now targets Swift 5.9 so we can rely on the modern linker APIs when Xcode resolves the package. Keep the tools version at 5.9 or newer when upgrading Xcode.
- **Absolute library paths**: the package imports `Foundation` and uses `#filePath` to build an absolute path to `mlc-llm/ios/MLCChat/dist/lib`. Without this, the Flutter workspace tried to resolve `../MLCChat/dist/lib` relative to `ascent/`, which is why Xcode previously complained that the static archives were missing.
- **Single linker block**: instead of calling `.linkedLibrary(.path(...))` for each archive, we pass one `.unsafeFlags` array with `-L <absolute dist/lib>` followed by the `-force_load` flags for every archive (`libmlc_llm.a`, `libmodel_iphone.a`, `libtvm_runtime.a`, `libtvm_ffi_static.a`, `libsentencepiece.a`, `libtokenizers_cpp.a`, `libtokenizers_c.a`). Runner no longer needs to link anything manually; the Swift package handles it.
- **Project wiring**: in `Runner.xcodeproj` the package is referenced as an `XCLocalSwiftPackageReference` pointing at `../../mlc-llm/ios/MLCSwift`. Let Xcode regenerate `ascent/ios/Runner.xcworkspace/xcshareddata/swiftpm/Package.resolved` (delete it before resolving if you ever hand-edit it).
- **AppDelegate tweak**: because Swift 5.9 made `registrar(forPlugin:)` optional, `AppDelegate.swift` now unwraps the registrar before registering `MLCBridgePlugin`. Older code compiled, but the new toolchain rejected it.
- **Simulator reminder**: device builds work with the current archives. To support simulators, rerun `ios/prepare_libs.sh --simulator` (add `--arch arm64` or `--arch x86_64` as needed) and lipo the results into `mlc-llm/ios/MLCChat/dist/lib` so each static library is universal.
- **Repeatable build steps**:
  1. `rm ascent/ios/Runner.xcworkspace/xcshareddata/swiftpm/Package.resolved`
  2. `xcodebuild -resolvePackageDependencies -workspace ascent/ios/Runner.xcworkspace -scheme Runner`
  3. Fix Flutter cache permissions if prompted (`sudo chown -R $(whoami) /Users/jonathanbannet/flutter/bin/cache`), then run `flutter clean && flutter pub get && flutter run`.

---

## 🔄 Run-time Flow

1. User enables **Offline rewriting** or taps **Rewrite**.
2. UI/front-end code calls `ensureBundledModelAvailable()` to hydrate the assets into Application Support.
3. The returned path is passed into `llmService.ensureEngine(overrideModelDirectory: ...)`.
4. `DefaultGetModelService` records the manual path and emits a `ModelDescriptor` that matches the bundled bundle ID/version.
5. `ModelDownloader.ensureModel()` validates the directory, writes `.mlc_descriptor.json`, and returns the same location.
6. `LlmService` calls `bridge.initialize(modelDir)`; `MLCBridge` loads the compiled module and starts streaming tokens.
7. `llmService.answer()` delegates to `bridge.generate`; UI listeners append tokens in real time. `clearCache()` disposes the engine and triggers a recopy on next use.

---

## 🔑 Flutter API Design

### `mlc_bridge.dart`

```dart
class MlcBridgeError implements Exception {
  MlcBridgeError(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'MlcBridgeError(\$code, \$message)';
}

class MlcBridge {
  MlcBridge._internal()
      : _methodChannel = const MethodChannel('mlc_bridge'),
        _eventChannel = const EventChannel('mlc_bridge/events') {
    _events = _eventChannel
        .receiveBroadcastStream()
        .map((raw) => Map<String, dynamic>.from(raw as Map));
  }

  static final MlcBridge instance = MlcBridge._internal();

  final MethodChannel _methodChannel;
  final EventChannel _eventChannel;
  late final Stream<Map<String, dynamic>> _events;

  String? _loadedDirectory;
  String? _activeRequestId;
  StreamSubscription<Map<String, dynamic>>? _subscription;

  Future<void> initialize(String modelDir) async {
    if (_loadedDirectory == modelDir) return;
    if (_loadedDirectory != null && _loadedDirectory != modelDir) {
      await shutdown();
    }
    await _methodChannel.invokeMethod('initialize', {'modelDir': modelDir});
    _loadedDirectory = modelDir;
  }

  Future<void> shutdown() async {
    await _subscription?.cancel();
    _subscription = null;
    _activeRequestId = null;
    _loadedDirectory = null;
    await _methodChannel.invokeMethod('shutdown');
  }

  Stream<String> generate(String prompt, {double? temperature, double? topP}) {
    final requestId = DateTime.now().microsecondsSinceEpoch.toString();
    _subscription?.cancel();
    _activeRequestId = requestId;

    final controller = StreamController<String>(onCancel: () async {
      if (_activeRequestId == requestId) {
        await _methodChannel.invokeMethod('cancel', {'requestId': requestId});
      }
    });

    _subscription = _events.listen((event) {
      final type = event['type'] as String?;
      final eventRequestId = event['requestId'] as String?;
      if (eventRequestId != null && eventRequestId != requestId) return;

      switch (type) {
        case 'token':
          final token = event['value'] as String?;
          if (token != null && token.isNotEmpty) {
            controller.add(token);
          }
          break;
        case 'completed':
        case 'cancelled':
          controller.close();
          _subscription?.cancel();
          _subscription = null;
          _activeRequestId = null;
          break;
        case 'error':
          final code = event['code'] as String? ?? 'error';
          final message = event['message'] as String? ?? 'Unknown error';
          controller.addError(MlcBridgeError(code, message));
          controller.close();
          _subscription?.cancel();
          _subscription = null;
          _activeRequestId = null;
          break;
      }
    });

    _methodChannel.invokeMethod('generate', {
      'prompt': prompt,
      'requestId': requestId,
      if (temperature != null) 'temperature': temperature,
      if (topP != null) 'topP': topP,
    });

    return controller.stream;
  }
}
```

### Native bridge outline (Swift)

```swift
@available(iOS 14.0, *)
final class MLCBridgePlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    private struct AppConfig: Decodable {
        struct Entry: Decodable {
            let model_id: String
            let model_lib: String
        }
        let model_list: [Entry]
    }

    private var engine: MLCEngine?
    private var eventSink: FlutterEventSink?
    private var currentTask: Task<Void, Never>?
    private var currentRequestId: String?

    static func register(with registrar: FlutterPluginRegistrar) {
        let instance = MLCBridgePlugin()
        let channel = FlutterMethodChannel(name: "mlc_bridge", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: channel)
        let eventChannel = FlutterEventChannel(name: "mlc_bridge/events", binaryMessenger: registrar.messenger())
        eventChannel.setStreamHandler(instance)
    }

    // initialize, generate, cancel, shutdown handlers …
    // see source for full implementation
}
```

---

## 🧪 Test Harness & QA Hooks

- Reuse the **Try LLM Rewrite** view. The only change is swapping to the new streaming service.
- Display the download progress while the bundle copies into app support.
- Surface bridge/runtime errors via snackbar/logging so QA can triage failures.
- `Clear cached model` now shuts down the engine and deletes the cached bundle directory.

---

## 🔄 Bundled Model Runtime Flow

### 1. Ship the artifacts with the Flutter app

- Copy the compiled bundle from `mlc-llm/ios/MLCChat/dist/bundle` into
  `ascent/assets/mlc_models/Llama-3.2-1B-Instruct-q4f16_1-MLC/` (already done).
- Register the folder in `pubspec.yaml` so Flutter exports the entire tree:

  ```yaml
  flutter:
    assets:
      - assets/mlc_models/Llama-3.2-1B-Instruct-q4f16_1-MLC/
  ```

### 2. Materialize the assets into Application Support

- `ensureBundledModelAvailable()` (in `bundled_model_loader.dart`) reads
  `AssetManifest.json`, streams each file to disk, and writes a
  `.bundled_model_version` marker to detect stale assets.
- The helper returns `<ApplicationSupport>/mlc_models/llama-3.2-1b-instruct`.
- Calling the helper is cheap after the first launch; it short-circuits when the
  version marker and `mlc-app-config.json` are present.

### 3. Initialize the engine with the copied bundle

- `LlmService.ensureEngine` now accepts `overrideModelDirectory` and forwards it
  into `ModelDownloader.ensureModel`, bypassing network calls.
- `DefaultGetModelService.setManualBundleDirectory` injects the same path so the
  returned `ModelDescriptor` aligns with the cached metadata.
- `LlmBridge.rewrite` wires it all together:

  ```dart
  final modelDir = await ensureBundledModelAvailable();
  await llmService.ensureEngine(overrideModelDirectory: modelDir.path);
  ```

### 4. Future OTA / CDN path

- When we restore downloads, clear the manual override and provide
  `MODEL_BASE_URL`; `ModelDownloader` already writes bundle metadata so the code
  path is the same.
- Implement `ModelCompression.zip` + CDN hosting later without disturbing the
  bundled-first flow.

---

## 📦 Model & Asset Handling

- **Bundled-first**: the Flutter asset copy guarantees both device and simulator
  builds have the bundle on day one. The loader writes a marker file so new
  versions (bump `kBundledModelVersion`) automatically refresh the runtime copy.
- **Fallback debug override**: the legacy `kDebugMode` path (`_debugBundlePath`)
  remains for developers pointing at `/mlc-llm/.../dist/bundle` directly.
- **Future CDN**: once hosting is available, expose `MODEL_BASE_URL` and drop the
  manual override. The downloader already persists metadata + SHA checks, so the
  startup sequence stays identical.
- **Cache management**: `llmService.clearCache()` still deletes the cached folder
  in Application Support, forcing the loader to recopy the bundled assets on the
  next invocation.

## 🤖 Android Integration Checklist

**Artifacts & Build Setup**
- [ ] Run `mlc_llm package` for the target model with Android outputs (arm64-v8a,
      x86_64 as needed) and land the resulting `android/MLCChat/dist` artifacts.
- [ ] Vendor the compiled `.so` libraries or AARs into
      `android/app/src/main/jniLibs/` (or a dedicated Gradle module) and document
      the directory layout here.
- [ ] Pin the Android NDK/SDK versions in `android/build.gradle` and update
      `local.properties` guidance so reproducible builds pull the correct
      toolchains.

**Flutter ↔ Android Bridge**
- [ ] Implement `MlcBridgePlugin` in Kotlin/Java mirroring the Swift API
      (`initialize`, `generate`, `cancel`, `shutdown`) using the
      `mlc_bridge`/`mlc_bridge/events` channels. *(Echo fallback wired; swap in
      real runtime once JNI libraries are available.)*
- [ ] Wire the plugin to the MLC Android runtime (`JSONFFIEngine`) and manage
      background execution plus cancellation callbacks safely.
- [ ] Register the plugin from `MainActivity` (or the generated registrant) and
      verify coexistence with other Flutter plugins.

**Model Materialization**
- [ ] Reuse `ensureBundledModelAvailable()`; confirm the copied bundle is readable
      via `context.getApplicationSupportDirectory()` equivalents and add
      platform-specific path helpers if needed.
- [ ] Extend `ModelDownloader`/`LlmService` tests to cover Android sandbox paths.

**Testing & QA**
- [ ] Add an integration smoke test that calls `llmService.ensureEngine` and
      generates a short reply on an emulator (arm64 + x86_64).
- [ ] Manually validate first-run copy time, warm-start latency, cancellation,
      and memory footprint on physical Android hardware.
- [ ] Capture logcat diagnostics (GC pressure, JNI errors) and surface troubleshooting steps in this doc.

## 📊 Recommendation Data Format for LLM Consumption

**Recommendations are now optimized for LLM processing with pure data points:**

- **Format**: `[Data Point]. [Risk/Status]. [Quantified Impact].`
- **No guidance**: Only factual information, no action items
- **Compact**: Minimal tokens for efficient processing
- **Structured**: Consistent pattern across all recommendations

**Examples:**
- `Cardio: <20th percentile. Below healthy threshold. Mortality risk +25%.`
- `GLP-1 medication active. Muscle mass loss risk 30-40%. Protein synthesis impaired.`
- `Age: 45. Sarcopenia risk. Muscle loss 1-2%/year after 40.`

This format enables LLMs to generate personalized summaries, explanations, and action plans without redundant guidance in the source data.

---

## 🚀 Next Steps

1. Validate the bundled flow on iOS simulator + device (cold boot, repeated sessions, cache clearing).
2. Execute the Android integration checklist (artifacts, plugin, runtime tests) to reach feature parity.
3. Define the CDN hosting contract (bucket layout, checksum tracking, zips) and implement `ModelCompression.zip` when ready.
4. Capture metrics: copy time on first run, steady-state initialization latency, and peak memory usage.
5. Automate regression checks (UI smoke test invoking `LlmBridge.rewrite`, asset checksum verification in CI).
