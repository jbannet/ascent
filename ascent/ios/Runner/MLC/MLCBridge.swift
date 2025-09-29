import Flutter
import Foundation
import MLCSwift

@available(iOS 14.0, *)
final class MLCBridgePlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private struct AppConfig: Decodable {
    struct Entry: Decodable {
      let model_id: String
      let model_lib: String
    }

    let model_list: [Entry]

    var primary: Entry? { model_list.first }
  }

  private var engine: MLCEngine?
  private var eventSink: FlutterEventSink?
  private var reloadTask: Task<Void, Never>?
  private var generationTask: Task<Void, Never>?
  private var currentRequestId: String?

  static func register(with registrar: FlutterPluginRegistrar) {
    let instance = MLCBridgePlugin()
    let channel = FlutterMethodChannel(name: "mlc_bridge", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(instance, channel: channel)

    let eventChannel = FlutterEventChannel(name: "mlc_bridge/events", binaryMessenger: registrar.messenger())
    eventChannel.setStreamHandler(instance)
  }

  // MARK: - FlutterStreamHandler

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    eventSink = events
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    return nil
  }

  // MARK: - FlutterPlugin

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "initialize":
      guard let args = call.arguments as? [String: Any], let modelDir = args["modelDir"] as? String else {
        result(FlutterError(code: "invalid_args", message: "Missing modelDir", details: nil))
        return
      }
      initializeEngine(modelDir: modelDir, result: result)
    case "generate":
      guard let args = call.arguments as? [String: Any],
            let prompt = args["prompt"] as? String,
            let requestId = args["requestId"] as? String
      else {
        result(FlutterError(code: "invalid_args", message: "Missing generate arguments", details: nil))
        return
      }
      let temperature = (args["temperature"] as? Double).map(Float.init)
      let topP = (args["topP"] as? Double).map(Float.init)
      generate(prompt: prompt, requestId: requestId, temperature: temperature, topP: topP)
      result(nil)
    case "cancel":
      guard let args = call.arguments as? [String: Any], let requestId = args["requestId"] as? String else {
        result(FlutterError(code: "invalid_args", message: "Missing requestId", details: nil))
        return
      }
      cancel(requestId: requestId)
      result(nil)
    case "shutdown":
      shutdown()
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // MARK: - Engine control

  private func initializeEngine(modelDir: String, result: @escaping FlutterResult) {
    shutdown()

    let entry: AppConfig.Entry
    do {
      let config = try loadConfig(modelDir: modelDir)
      guard let primary = config.primary else {
        result(FlutterError(code: "config_error", message: "mlc-app-config.json missing model", details: nil))
        return
      }
      entry = primary
    } catch {
      result(FlutterError(code: "config_error", message: error.localizedDescription, details: nil))
      return
    }

    let engine = MLCEngine()
    self.engine = engine

    reloadTask?.cancel()
    reloadTask = Task { [weak self] in
      do {
        try Task.checkCancellation()
        await engine.reload(modelPath: modelDir, modelLib: entry.model_lib)
        self?.emit(["type": "engine_ready"])
        DispatchQueue.main.async {
          result(nil)
        }
      } catch {
        self?.engine = nil
        self?.emitError(code: "initialize_failed", message: error.localizedDescription)
        DispatchQueue.main.async {
          result(FlutterError(code: "initialize_failed", message: error.localizedDescription, details: nil))
        }
      }
      self?.reloadTask = nil
    }
  }

  private func generate(
    prompt: String,
    requestId: String,
    temperature: Float?,
    topP: Float?
  ) {
    guard let engine = engine else {
      emitError(code: "engine_not_ready", message: "Call initialize first.", requestId: requestId)
      return
    }

    if reloadTask != nil {
      emitError(code: "engine_initializing", message: "Engine is still loading.", requestId: requestId)
      return
    }

    generationTask?.cancel()

    currentRequestId = requestId
    generationTask = Task { [weak self] in
      do {
        let messages = [ChatCompletionMessage(role: .user, content: prompt)]
        let stream = await engine.chat.completions.create(
          messages: messages,
          temperature: temperature,
          top_p: topP
        )

        for await response in stream {
          try Task.checkCancellation()
          guard let self, requestId == self.currentRequestId else { continue }

          if let choice = response.choices.first,
             let delta = choice.delta.content?.asText(),
             !delta.isEmpty {
            self.emit(["type": "token", "requestId": requestId, "value": delta])
          }

          if response.usage != nil || response.choices.first?.finish_reason != nil {
            self.emit(["type": "completed", "requestId": requestId])
            break
          }
        }
      } catch is CancellationError {
        self?.emit(["type": "cancelled", "requestId": requestId])
      } catch {
        self?.emitError(code: "generation_failed", message: error.localizedDescription, requestId: requestId)
      }

      if self?.currentRequestId == requestId {
        self?.currentRequestId = nil
      }
      self?.generationTask = nil
    }
  }

  private func cancel(requestId: String) {
    guard requestId == currentRequestId else { return }
    generationTask?.cancel()
    generationTask = nil
    currentRequestId = nil
  }

  private func shutdown() {
    generationTask?.cancel()
    generationTask = nil
    currentRequestId = nil

    reloadTask?.cancel()
    reloadTask = nil

    guard let engine else { return }
    self.engine = nil
    Task {
      await engine.unload()
    }
  }

  // MARK: - Helpers

  private func loadConfig(modelDir: String) throws -> AppConfig {
    let url = URL(fileURLWithPath: modelDir).appendingPathComponent("mlc-app-config.json")
    let data = try Data(contentsOf: url)
    return try JSONDecoder().decode(AppConfig.self, from: data)
  }

  private func emit(_ payload: [String: Any]) {
    guard let eventSink else { return }
    if Thread.isMainThread {
      eventSink(payload)
    } else {
      DispatchQueue.main.async {
        eventSink(payload)
      }
    }
  }

  private func emitError(code: String, message: String, requestId: String? = nil) {
    var payload: [String: Any] = [
      "type": "error",
      "code": code,
      "message": message,
    ]
    if let requestId {
      payload["requestId"] = requestId
    }
    emit(payload)
  }
}
