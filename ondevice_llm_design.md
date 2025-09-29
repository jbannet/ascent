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
│  │  ├─ model_descriptor.dart        # Resolves packaged vs. CDN model bundles (.mlc artifacts)
│  │  ├─ model_downloader.dart        # Streams + verifies OTA bundles
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
│  └─ mlc_models/                     # Optional packaged model bundles copied into the app
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
- **Model resolution**: `ModelDescriptor` now describes MLC bundles (directory-based) and `ModelDownloader` copies the directory into `ApplicationSupport`.
- **Caching**: A successful download is cached in app support. `clearCache()` deletes the directory so QA can replay the first-run flow.


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
2. `GetModelService.current()` chooses a descriptor (local bundle in debug, CDN in release).
3. `ModelDownloader.ensureModel()` ensures the bundle directory exists inside app support, copying or downloading as needed.
4. `LlmService.ensureEngine()` calls `bridge.initialize(modelDir)` with sampling defaults/persona config.
5. `MLCBridge` spins up the background JSON FFI engine, loads the compiled module, and emits `engine_ready` via the event channel.
6. `llmService.answer()` delegates to `bridge.generate`, which streams token chunks back to Dart.
7. UI (`llm_bridge.dart`) appends tokens in real time; `clearCache()` disposes the engine and removes the cached bundle.

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

## 📦 Model & Asset Handling

- **Local dev**: point `ModelDescriptor` at `mlc-llm/ios/MLCChat/dist/bundle` so local runs reuse the compiled artifacts.
- **Production/CDN**: host the bundle (or archive) on your CDN. `ModelDownloader` copies the directory into app support and preserves the structure required by `mlc_llm`.
- **Versioning**: track bundle versions in preferences so the app can prompt users when a newer model is available.

---

## 🚀 Next Steps

1. Compile and package the desired quantization (`mlc_llm package`).
2. Wire up the Swift and Kotlin bridges around `JSONFFIEngine`.
3. Replace the legacy `llama_cpp` integration with the new `MlcBridge` in `llm_service.dart`.
4. Update CI to cache the compiled bundles/static libs to avoid rebuilding every run.
5. Exercise the feature on device (iOS + Android) to validate latency, memory usage, and cancellation flows.



emulator:
The link error is because the static archives in mlc-llm/ios/MLCChat/dist/lib/ were built only for iphoneos. The simulator needs iphonesimulator slices. To fix it:

From the MLC repo run the simulator build:

cd mlc-llm/ios
MLC_LLM_SOURCE_DIR=.. ./prepare_libs.sh --simulator --arch arm64   # (+ --arch x86_64 if you want Intel)
If rustup is missing the aarch64-apple-ios-sim target, install it once (rustup target add aarch64-apple-ios-sim). In my sandbox that step failed because the tool can’t download the component, so you’ll need to run it in an environment with Rust allowed to fetch toolchains.

Copy the resulting simulator archives (they land under ios/MLCChat/build/.../install/lib or dist/lib) into a separate folder, e.g. dist/lib-iphonesimulator/.

Create universal archives by combining device and simulator slices, e.g.:

lipo -create dist/lib-iphoneos/libmlc_llm.a dist/lib-iphonesimulator/libmlc_llm.a \
     -output dist/lib/libmlc_llm.a
# repeat for libmodel_iphone.a, libtvm_runtime.a, libtokenizers_{cpp,c}.a, libsentencepiece.a, libtvm_ffi_static.a
Keep the Swift package reference pointed at mlc-llm/ios/MLCChat/dist/lib, rebuild, and both simulator and device targets will link successfully.

Once the simulator slices are in place we can walk through the rest of the changes (mlc bridge, service updates, etc.) and verify them on both device and emulator.