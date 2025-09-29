MLC vs llama_cpp_dart vs llama-stack

LLAMA_CPP_DART VERSION
# On-Device LLM Integration Plan for Flutter App (llama_cpp_dart)

## 🎯 Objective

Enable **offline sentence rephrasing/paraphrasing** in the Flutter app using the **`llama_cpp_dart` package**. We ship a compact GGUF checkpoint and the corresponding `libllama` shared libraries for each platform so rewrites stay private while leaving the UI layer untouched.

---

## 🗂️ Directory Structure

```
your_app/
├─ lib/
│  ├─ main.dart
│  ├─ services_and_utilities/llm/
│  │  ├─ model_descriptor.dart        # Resolves packaged vs. CDN GGUF bundles
│  │  ├─ model_downloader.dart        # Streams + verifies GGUF downloads
│  │  ├─ llm_service.dart             # Wraps llama_cpp_dart isolate API
│  │  ├─ llama_cpp_bridge.dart        # Bridges to LlamaParent & event streams
│  │  ├─ llama_library_loader.dart    # Copies platform libllama into app storage
│  │  ├─ prompts.dart
│  │  └─ llm_bridge.dart
│  └─ workflow_views/testing/llm_rewrite_test_view.dart
│
├─ assets/
│  ├─ gguf_models/                    # Optional packaged GGUFs (dev only)
│  └─ native_llama/
│     ├─ ios/device/libllama.dylib    # Output copied from llama_cpp_dart/bin/OS64
│     ├─ ios/simulator/libllama.dylib # Output copied from llama_cpp_dart/bin/SIMULATORARM64 or SIMULATOR64
│     ├─ android/arm64-v8a/libllama.so
│     ├─ android/armeabi-v7a/libllama.so
│     └─ android/x86_64/libllama.so
│
├─ tools/
│  ├─ models.json                     # CDN descriptors + SHA-256 for GGUFs
│  └─ serve_models.dart               # Optional dev server for GGUFs
└─ ggruf_models/                      # Local dev models outside the app bundle
```

> We treat the native `libllama` builds as binary assets: Flutter bundles them under `assets/native_llama/`, and `llama_library_loader.dart` copies the correct file into `ApplicationSupportDirectory` so `DynamicLibrary.open()` works on both iOS and Android.

---

## ⚙️ Runtime Stack

We standardize on **`llama_cpp_dart` (0.1.x)** because it lets us:
- Stay in Dart/Flutter—high-level APIs (`LlamaLoad`, `LlamaParent`, `LlamaResponse`) manage isolates and token streaming.
- Keep using GGUF checkpoints; no model conversion is required.
- Control sampling parameters per request without authoring MethodChannels.

Key responsibilities we own:
- Compile `libllama` for each platform/ABI (Metal/CUDA support optional).
- Copy the bundled shared library to a writable path before invoking the API.
- Ensure iOS code-signs the dylib by shipping it as an app asset and copying at runtime (iOS disallows executing from the bundle directly).

### Tooling prerequisites

1. **Install required build tools**:
   - CMake ≥ 3.24
   - Ninja build system
   - Xcode with Command Line Tools (for iOS/macOS)
   - Valid Apple Developer Team ID (for code signing)
   - Android NDK r26 (for Android builds)

2. **Clone and prepare the llama_cpp_dart repository**:
   ```bash
   git clone https://github.com/netdur/llama_cpp_dart.git
   cd llama_cpp_dart
   git submodule update --remote src/llama.cpp
   git submodule update --init --recursive
   ```

3. **Build for iOS/macOS platforms**:
   - Navigate to the darwin directory: `cd darwin`
   - Create `build.sh` script with your configuration:
     - Replace `YOUR_DEVELOPER_TEAM_ID` with your actual Apple Developer Team ID
     - Uncomment the platforms you need (OS64 for iOS device, SIMULATORARM64 for ARM simulators, etc.)
   - Make the script executable: `chmod +x build.sh`
   - Run the build: `./build.sh`
   - Output libraries will be in:
     - `bin/OS64/libllama.dylib` (iOS device)
     - `bin/SIMULATORARM64/libllama.dylib` (iOS ARM simulator)
     - `bin/SIMULATOR64/libllama.dylib` (iOS x64 simulator)
     - `bin/MAC_ARM64/libllama.dylib` (macOS ARM)

4. **Build for Android platforms**:
   ```bash
   cd android
   ./build.sh arm64      # Creates bin/android-arm64-v8a/libllama.so
   ./build.sh arm        # Creates bin/android-armeabi-v7a/libllama.so
   ./build.sh x64        # Creates bin/android-x86_64/libllama.so
   ```

5. **Copy libraries to Flutter project**:
   ```bash
   # iOS libraries
   cp bin/OS64/libllama.dylib assets/native_llama/ios/device/
   cp bin/SIMULATORARM64/libllama.dylib assets/native_llama/ios/simulator/

   # Android libraries
   cp bin/android-arm64-v8a/libllama.so assets/native_llama/android/arm64-v8a/
   cp bin/android-armeabi-v7a/libllama.so assets/native_llama/android/armeabi-v7a/
   cp bin/android-x86_64/libllama.so assets/native_llama/android/x86_64/
   ```

6. **Configure Flutter asset bundling**:
   Add each library file to `pubspec.yaml`:
   ```yaml
   flutter:
     assets:
       - assets/native_llama/ios/device/libllama.dylib
       - assets/native_llama/ios/simulator/libllama.dylib
       - assets/native_llama/android/arm64-v8a/libllama.so
       - assets/native_llama/android/armeabi-v7a/libllama.so
       - assets/native_llama/android/x86_64/libllama.so
   ```

7. **Clean up**: Once libraries are copied, the cloned llama_cpp_dart repository can be removed or kept for future rebuilds.

### Integration principles

- `llama_library_loader.dart` selects the platform asset, writes it to the app support directory, and returns the absolute path.
- Before initializing the engine we set `Llama.libraryPath = libPath;` so the FFI bindings know which shared library to load.
- `llm_service.dart` owns a single `LlamaParent` instance (managed isolate). It calls `LlamaParent.init()` once, streams tokens via `parent.stream`, and disposes the isolate when the feature is disabled.
- The UI continues to use `LlmBridge.rewrite()` and `StreamBuilder`—only the service implementation changes.

---

## 🔄 Run-time Flow

1. User requests a rewrite. `GetModelService.current()` returns the active GGUF descriptor (packaged or CDN).
2. `ModelDownloader.ensureModel()` downloads/validates the GGUF into app support (`…/models/<version>/model.gguf`).
3. `llm_service.ensureEngine()`:
   - Calls `llamaLibraryLoader.ensureLoaded()` → copies the platform `libllama` to `…/native/libllama.(so|dylib)` and returns the path.
   - Sets `Llama.libraryPath = libPath;`
   - Creates a `LlamaLoad` object with `path: modelFile.path`, `modelParams`, `contextParams`, and default `SamplerParams`.
   - Instantiates `LlamaParent(load)` and awaits `parent.init()`; once resolved, updates `state = LlmState.ready`.
4. `answer(prompt, …)` converts persona + text into the final prompt and calls `parent.sendPrompt(prompt, overrides)`.
5. Tokens arrive through `parent.stream` (`LlamaResponse` events). We forward the `token` field to the UI as a `Stream<String>` and handle `stop`, `error`, and `guard` events.
6. `dispose()` calls `parent.dispose()`; `clearCache()` closes the parent and deletes both the GGUF and copied native library.

---

## 🔑 Flutter API Design

### `llama_cpp_bridge.dart`

```dart
class LlamaCppBridge {
  LlamaCppBridge({required this.libraryLoader});

  final LlamaLibraryLoader libraryLoader;
  LlamaParent? _parent;

  Future<void> init(ModelDescriptor descriptor) async {
    if (_parent != null) return;

    final modelFile = await modelDownloader.ensureModel(descriptor);
    final libPath = await libraryLoader.ensureLoaded();

    Llama.libraryPath = libPath;
    final load = LlamaLoad(
      path: modelFile.path,
      modelParams: ModelParams(),
      contextParams: ContextParams(),
      samplingParams: const SamplerParams(temperature: 0.7, topP: 0.9),
    );

    final parent = LlamaParent(load);
    await parent.init();
    _parent = parent;
  }

  Stream<String> generate(String prompt, {SamplerParams? overrides}) {
    final parent = _parent;
    if (parent == null) {
      throw StateError('Parent not initialized');
    }

    final controller = StreamController<String>();
    final sub = parent.stream.listen((event) {
      final token = event.token;
      if (token != null) {
        controller.add(token);
      }
      final error = event.error;
      if (error != null) {
        controller.addError(Exception(error));
      }
      if (event.done == true) {
        controller.close();
      }
    });

    controller.onCancel = () => sub.cancel();
    parent.sendPrompt(prompt, paramsOverride: overrides);
    return controller.stream;
  }

  Future<void> dispose() async {
    await _parent?.dispose();
    _parent = null;
  }
}
```

`llm_service.dart` wraps the bridge with the familiar `ensureEngine()` / `answer()` API used elsewhere in the app.

### Prompt template & personas

Re-use existing prompt scaffolding (`Prompts.byKey`, `LlmState` enum). Only the engine wiring changes.

---

## 🧪 Test Harness & QA Hooks

- Internal **Try LLM Rewrite** screen remains the same—stream tokens to the UI and log latency.
- Add error reporting for missing native library or FFI load failures (attach to QA snackbar / console).
- Keep the **Clear cached model** button: call `llmService.clearCache()` to delete the GGUF and copied `libllama` so testers can reproduce first-run flows.

---

## 📦 Model & Asset Handling

- **GGUF downloads**: identical to previous flow—`models.json` encodes CDN URLs + SHA-256. `ModelDownloader` saves into `ApplicationSupportDirectory`.
- **Native libraries**: treat the `.dylib`/`.so` files as versioned assets. When releasing updates, rerun the relevant build scripts from `llama_cpp_dart/BUILD.md` (e.g., `./darwin/build.sh`, `./android/build.sh <abi>`), copy the refreshed binaries from `bin/<platform>/` into `assets/native_llama/`, bump `llama_library_loader.dart`’s expected version/hash, and redeploy.
- **Simulator vs device**: bundle both `libllama_sim.dylib` and device `libllama.dylib`. The loader picks based on `Platform.environment['SIMULATOR_DEVICE_NAME']` (iOS) or `defaultTargetPlatform`.

---

## 🚀 Next Steps

1. Rebuild `libllama` for all target platforms by rerunning the official scripts in the `llama_cpp_dart` repo (e.g., `./darwin/build.sh`, `./android/build.sh arm64`), then copy the new outputs from `bin/<platform>/` into `assets/native_llama/` (or host them externally and update the loader).
2. Add `llama_cpp_dart: ^0.1.0` to `pubspec.yaml` and run `flutter pub get`.
3. Implement `llama_library_loader.dart`, `llama_cpp_bridge.dart`, and adapt `llm_service.dart` to call into the bridge.
4. Update `ModelDescriptor` to continue returning the GGUF descriptors; no changes required beyond ensuring the files land in `Application Support`.
5. Test on iOS Simulator, iOS device, Android emulator, and Android device—verify the correct native library loads in each environment and that streaming works end-to-end.
6. Document the rebuild process (commands, required targets, any patches) in project notes/CI so future updates to `llama_cpp_dart` or llama.cpp can regenerate the binaries reproducibly.

-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
MLC VERSION
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
│  │  ├─ llm_service.dart             # MethodChannel façade around native MLC runtime
│  │  ├─ mlc_bridge.dart              # Dart helper wrapping MethodChannel/EventChannel
│  │  ├─ prompts.dart                 # Persona definitions
│  │  └─ llm_bridge.dart              # Flutter-facing rewrite helper
│  └─ workflow_views/testing/llm_rewrite_test_view.dart
│
├─ native/
│  ├─ ios/MLCBridge.swift             # Swift bridge to MLC runtime (generated + edited)
│  └─ android/MLCBridge.kt            # Kotlin bridge to MLC runtime
│
├─ mlc/
│  ├─ models/                          # Compiled model bundles (params, tokenizer, config)
│  ├─ build_ios.sh                     # Wrapper invoking `python -m mlc_llm.build` for iOS
│  ├─ build_android.sh                 # Wrapper for Android ABIs
│  └─ README.md                        # Notes on rebuild steps & prerequisites
│
├─ assets/
│  └─ mlc_models/                      # Packaged model bundles copied into the app (optional)
│
├─ tools/
│  ├─ models.json                      # CDN descriptors + SHA-256 for OTA downloads
│  └─ serve_models.dart                # Local dev HTTP server for simulator/emulator testing
└─ ggruf_models/                       # Legacy GGUFs kept for reference
```

> We keep the MLC build scripts under `mlc/` so CI and local dev use the same commands to regenerate artifacts when updating checkpoints or quantization settings.

---

## ⚙️ Runtime Stack

We standardize on **MLC-LLM** because it provides:
- Pre-optimized runtimes for iOS (Metal) and Android (Vulkan/CUDA) with Flutter-friendly latency.
- Python/TVM tooling (`mlc_llm`) to compile Llama/Mistral-style models into device-specific “model lib” bundles (JSON + params + precompiled kernels).
- Reference native code for streaming generation that we can lift into Flutter via platform channels.

### Tooling prerequisites

1. **Install MLC tooling**: Run `pip install mlc-llm` and ensure the platform toolchains are in place (Python ≥3.10, Xcode for iOS, Android NDK r26). Validate the environment by invoking `mlc_llm --help`; if it succeeds without missing-tool errors you're ready to use pre-built models.

2. **Use pre-built quantized models**: MLC-LLM provides ready-to-use models like `Llama-3.2-1B-Instruct-q4f16_1-MLC` for text generation tasks. These can be loaded directly without custom building.

3. **iOS Runtime Integration**:
   - Clone MLC-LLM repo: `git clone https://github.com/mlc-ai/mlc-llm.git`
   - In Xcode, add the MLCSwift package from `mlc-llm/ios/MLCSwift` as a local package dependency
   - Generate runtime libraries by running `mlc_llm package` in the `ios/MLCChat` directory
   - Link the generated static libraries from `dist/lib/`: `libmlc_llm.a`, `libtvm_runtime.a`, `libmodel_iphone.a`, `libtokenizers_cpp.a`, `libsentencepiece.a`
   - Add linker flags: `-Wl,-all_load -lmodel_iphone -lmlc_llm -ltvm_runtime -ltokenizers_cpp -libsentencepiece`
   - Set library search path to point to your `dist/lib` directory

4. **Android Runtime Integration**:
   - After running `mlc_llm package` in `android/MLCChat`, include the generated mlc4j module:
   ```gradle
   include ':mlc4j'
   project(':mlc4j').projectDir = file('path/to/mlc-llm/dist/lib/mlc4j')
   ```
   - Add dependency in your app's `build.gradle`: `implementation project(':mlc4j')`
   - Ensure JNI libraries (`libtvm4j_runtime_packed.so`) and Java bindings (`tvm4j_core.jar`) are included
   - **Note**: Requires physical Android device; emulator not supported

5. **Flutter Platform Channel Setup**:
   - Create platform channels for bridging Dart to native MLC SDKs
   - Use `MethodChannel` for initialization and generation requests
   - Use `EventChannel` for streaming token responses
   - Implement native bridges in Swift/Kotlin that wrap MLCEngine APIs

> With MLC runtime SDKs integrated, you can load and run pre-built models directly in your Flutter app.

### Integration principles

- **Native bridges**: Wrap the generated MLC inference APIs in Swift/Kotlin (`MLCBridge`) that expose `initialize(modelPath, config)`, `generate(prompt, overrides)`, and stream tokens via callbacks.
- **Dart façade**: `mlc_bridge.dart` drives a `MethodChannel` (`mlc_bridge`) plus `EventChannel` (`mlc_bridge/events`) to exchange JSON payloads between Flutter and the native runtime.
- **Model resolution**: `ModelDescriptor` returns the path to the compiled bundle (packaged asset or OTA download). `ModelDownloader` handles CDN downloads/updates.
- **Caching**: On first launch we copy the packaged model into app support storage (both platforms need writable paths). Subsequent runs reuse the cached bundle unless a newer version is detected.

---

## 🔄 Run-time Flow

1. User enables **Offline rewriting** or taps **Rewrite**.
2. `GetModelService.current()` chooses a descriptor:
   - Debug: local bundle from `mlc/models/` or served via `http://…` for emulator/simulator.
   - Release: CDN URL + checksum from `tools/models.json`.
3. `ModelDownloader.ensureModel()` downloads (if needed) and validates the bundle, unpacking into `getApplicationSupportDirectory()/mlc/<version>/`.
4. `LlmService.ensureEngine()` calls `_bridge.initialize(modelDir)` over `MethodChannel` with sampling defaults and persona config.
5. Native bridge boots the MLC runtime in a background thread/isolate, loads the compiled module, and emits `engine_ready` via `EventChannel`.
6. `LlmService.answer()` sends the prompt; the bridge streams `token` events (UTF-8 strings) followed by `completed` or `error`.
7. UI (`llm_bridge.dart`) assembles tokens into the final rewritten sentences, mirroring the previous streaming UX.
8. `dispose()` invokes `_bridge.shutdown()`; `clearCache()` deletes the cached bundle and resets state.

---

## 🔑 Flutter API Design

### `mlc_bridge.dart`

```dart
class MlcBridge {
  MlcBridge(
    MethodChannel methodChannel,
    EventChannel eventChannel,
  )   : _channel = methodChannel,
        _events = eventChannel;

  final MethodChannel _channel;
  final EventChannel _events;

  Stream<Map<String, dynamic>> get events =>
      _events.receiveBroadcastStream().cast<Map<String, dynamic>>();

  Future<void> initialize({required String modelDir}) {
    return _channel.invokeMethod('initialize', {
      'modelDir': modelDir,
    });
  }

  Future<void> generate({
    required String prompt,
    double? temperature,
    double? topP,
    int? topK,
  }) {
    return _channel.invokeMethod('generate', {
      'prompt': prompt,
      if (temperature != null) 'temperature': temperature,
      if (topP != null) 'topP': topP,
      if (topK != null) 'topK': topK,
    });
  }

  Future<void> shutdown() => _channel.invokeMethod('shutdown');
}
```

### `llm_service.dart` integration

```dart
Stream<String> answer(
  String prompt, {
  double? temperature,
  double? topP,
  int? topK,
}) async* {
  if (state != LlmState.ready) {
    throw StateError('Engine not ready');
  }

  final controller = StreamController<String>();
  late final StreamSubscription sub;
  sub = _bridge.events.listen((event) {
    switch (event['type']) {
      case 'token':
        controller.add(event['value'] as String);
        break;
      case 'completed':
        controller.close();
        break;
      case 'error':
        controller.addError(Exception(event['message'] ?? 'MLC error'));
        break;
    }
  });

  await _bridge.generate(
    prompt: prompt,
    temperature: temperature,
    topP: topP,
    topK: topK,
  );

  yield* controller.stream;
  await sub.cancel();
}
```

### Native bridge outline (Swift)

```swift
class MLCBridge: NSObject, FlutterPlugin, FlutterStreamHandler {
    private var engine: MLCChatModule?
    private var eventSink: FlutterEventSink?

    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "mlc_bridge", binaryMessenger: registrar.messenger())
        let events = FlutterEventChannel(name: "mlc_bridge/events", binaryMessenger: registrar.messenger())
        let instance = MLCBridge()
        registrar.addMethodCallDelegate(instance, channel: channel)
        events.setStreamHandler(instance)
    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            guard let args = call.arguments as? [String: Any],
                  let modelDir = args["modelDir"] as? String else {
                return result(FlutterError(code: "invalid_args", message: "Missing modelDir", details: nil))
            }
            engine = MLCChatModule(modelPath: modelDir)
            engine?.setTokenCallback { token in
                self.eventSink?(["type": "token", "value": token])
            }
            engine?.setCompletionCallback {
                self.eventSink?(["type": "completed"])
            }
            result(nil)
        case "generate":
            guard let prompt = (call.arguments as? [String: Any])?["prompt"] as? String else {
                return result(FlutterError(code: "invalid_args", message: "Missing prompt", details: nil))
            }
            engine?.generate(prompt: prompt) { error in
                if let error = error {
                    self.eventSink?(["type": "error", "message": "\(error)"])
                }
            }
            result(nil)
        case "shutdown":
            engine?.close()
            engine = nil
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    func onListen(withArguments args: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = eventSink
        return nil
    }

    func onCancel(withArguments args: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
}
```

> Replace `MLCChatModule` calls with the actual API from the generated MLC iOS sample (usually `MLCChatModule(modelConfig:)` + `generateOneStep`). Android mirrors this using `MLCChatModule` Kotlin bindings and coroutine flows.

### Prompt template & personas

Same as before: system persona + user text, with `Prompts.byKey` mapping to our tone strings. `LlmState` enum stays (`disabled`, `initializing`, `ready`).

---

## 🧪 Test Harness & QA Hooks

- Reuse the **Try LLM Rewrite** view. Swap the underlying `llmService.answer()` implementation; UI remains unchanged.
- Show progress while `mlc_llm` bundles download or unpack (use `DownloadProgress`).
- Surface MLC runtime warnings/errors via snackbars/logs for QA (e.g., GPU unavailable fallback).
- `Clear cached model` triggers `_bridge.shutdown()` and deletes the extracted bundle; ensures QA can replay download/init flows.

---

## 📦 Model & Asset Handling

- **Local dev**: store compiled bundles under `mlc/models/`. For simulator/emulator, serve with `tools/serve_models.dart` and supply `--dart-define MODEL_BASE_URL=http://127.0.0.1:5600/`.
- **Production/CDN**: zip the compiled bundle (`params/`, `tokenizer/`, `config.json`, runtime libs) and host on your CDN. `models.json` records URL, SHA-256, and size. `ModelDownloader` fetches and extracts to app support storage.
- **Versioning**: include a `version.json` in the bundle; `ModelDescriptor` checks it against stored prefs to decide whether to prompt for an update.
- **Size considerations**: quantization level (e.g., `q4f16_1` vs `q3f16`) impacts download size. Document trade-offs in `mlc/README.md`.

---

## 🚀 Next Steps

1. **Compile models** with `mlc_llm.build` for your target quantization and verify outputs in `mlc/models/`.
2. **Integrate native runtimes**: import the generated iOS/Android projects, copy the runtime libraries and headers into your Flutter platform folders, and expose `MLCBridge` via plugin registration.
3. **Implement Dart bridge** (`mlc_bridge.dart`) and update `llm_service.dart`/`llm_bridge.dart` to use it.
4. **Hook up downloads**: configure `ModelDescriptor`/`ModelDownloader` for local dev and CDN bundles; ensure checksums pass.
5. **Test on device**: run on iOS + Android hardware with GPU acceleration enabled, validating latency, memory use, and failure handling.
6. **Document rebuilds**: update `mlc/README.md` with exact commands/flags so future quantization updates or model swaps are reproducible.

With MLC-LLM in place, we control the full on-device inference stack while leaning on battle-tested mobile runtimes and tooling.
