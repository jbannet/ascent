package com.andromedax.ascent

import android.content.Context
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.EventChannel.StreamHandler
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File
import java.io.IOException
import java.util.concurrent.atomic.AtomicReference
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.currentCoroutineContext
import kotlinx.coroutines.delay
import kotlinx.coroutines.ensureActive
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject

private const val METHOD_CHANNEL_NAME = "mlc_bridge"
private const val EVENT_CHANNEL_NAME = "mlc_bridge/events"

class MlcBridgePlugin private constructor(
    context: Context,
    private val mainHandler: Handler = Handler(Looper.getMainLooper()),
    private val scope: CoroutineScope = CoroutineScope(SupervisorJob() + Dispatchers.IO)
) : MethodCallHandler, StreamHandler {
    private val methodChannelRef = AtomicReference<MethodChannel?>()
    private val eventChannelRef = AtomicReference<EventChannel?>()
    private val eventSinkRef = AtomicReference<EventSink?>()

    private var engine: EngineController? = null
    private var generationJob: Job? = null
    private var currentRequestId: String? = null

    companion object {
        fun register(context: Context, messenger: BinaryMessenger): MlcBridgePlugin {
            return MlcBridgePlugin(context).apply { attach(messenger) }
        }
    }

    fun attach(messenger: BinaryMessenger) {
        val methodChannel = MethodChannel(messenger, METHOD_CHANNEL_NAME).also {
            it.setMethodCallHandler(this)
        }
        val eventChannel = EventChannel(messenger, EVENT_CHANNEL_NAME).also {
            it.setStreamHandler(this)
        }
        methodChannelRef.set(methodChannel)
        eventChannelRef.set(eventChannel)
    }

    fun dispose() {
        methodChannelRef.getAndSet(null)?.setMethodCallHandler(null)
        eventChannelRef.getAndSet(null)?.setStreamHandler(null)
        eventSinkRef.set(null)

        generationJob?.cancel()
        generationJob = null
        currentRequestId = null

        val controller = engine
        engine = null
        if (controller != null) {
            CoroutineScope(Dispatchers.IO).launch {
                controller.shutdown()
            }
        }
        scope.cancel()
    }

    override fun onListen(arguments: Any?, events: EventSink?) {
        eventSinkRef.set(events)
    }

    override fun onCancel(arguments: Any?) {
        eventSinkRef.set(null)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "initialize" -> handleInitialize(call, result)
            "generate" -> handleGenerate(call, result)
            "cancel" -> handleCancel(call, result)
            "shutdown" -> handleShutdown(result)
            else -> result.notImplemented()
        }
    }

    private fun handleInitialize(call: MethodCall, result: Result) {
        val modelDirPath = call.argument<String>("modelDir")
        if (modelDirPath.isNullOrEmpty()) {
            result.error("invalid_args", "Missing modelDir", null)
            return
        }

        scope.launch {
            try {
                val (modelDir, modelLib) = parseModelConfig(modelDirPath)
                val controller = createEngineController()
                controller.initialize(modelDir, modelLib)
                engine = controller
                withContext(Dispatchers.Main) {
                    result.success(null)
                }
                emit(mapOf("type" to "engine_ready"))
            } catch (error: Throwable) {
                emitError("initialize_failed", error.message ?: "Initialization failed", null)
                withContext(Dispatchers.Main) {
                    result.error("initialize_failed", error.message, null)
                }
            }
        }
    }

    private fun handleGenerate(call: MethodCall, result: Result) {
        val prompt = call.argument<String>("prompt")
        val requestId = call.argument<String>("requestId")
        if (prompt.isNullOrEmpty() || requestId.isNullOrEmpty()) {
            result.error("invalid_args", "Missing prompt or requestId", null)
            return
        }

        val temperature = call.argument<Double>("temperature")
        val topP = call.argument<Double>("topP")

        val controller = engine
        if (controller == null) {
            result.error("engine_not_ready", "Call initialize() before generate().", null)
            return
        }

        generationJob?.cancel()
        val job = scope.launch {
            try {
                controller.generate(prompt, requestId, temperature, topP) { token ->
                    emit(mapOf("type" to "token", "requestId" to requestId, "value" to token))
                }
                emit(mapOf("type" to "completed", "requestId" to requestId))
            } catch (error: CancellationException) {
                emit(mapOf("type" to "cancelled", "requestId" to requestId))
            } catch (error: Throwable) {
                emitError("generation_failed", error.message ?: "Generation failed", requestId)
            } finally {
                if (currentRequestId == requestId) {
                    currentRequestId = null
                }
            }
        }

        currentRequestId = requestId
        generationJob = job
        result.success(null)
    }

    private fun handleCancel(call: MethodCall, result: Result) {
        val requestId = call.argument<String>("requestId")
        if (requestId.isNullOrEmpty()) {
            result.error("invalid_args", "Missing requestId", null)
            return
        }

        if (currentRequestId == requestId) {
            engine?.cancel(requestId)
            generationJob?.cancel()
            generationJob = null
            currentRequestId = null
        }
        result.success(null)
    }

    private fun handleShutdown(result: Result) {
        generationJob?.cancel()
        generationJob = null
        currentRequestId = null

        scope.launch {
            try {
                engine?.shutdown()
            } finally {
                engine = null
            }
        }
        result.success(null)
    }

    private fun parseModelConfig(modelDirPath: String): Pair<File, String?> {
        val modelDir = File(modelDirPath)
        if (!modelDir.exists()) {
            throw IOException("Model directory does not exist: $modelDirPath")
        }

        val configFile = File(modelDir, "mlc-app-config.json")
        if (!configFile.exists()) {
            throw IOException("mlc-app-config.json is missing in $modelDirPath")
        }

        val content = configFile.readText()
        val modelLib = try {
            val json = JSONObject(content)
            val list: JSONArray = json.optJSONArray("model_list") ?: JSONArray()
            if (list.length() == 0) {
                null
            } else {
                val entry = list.optJSONObject(0)
                entry?.optString("model_lib")
            }
        } catch (error: JSONException) {
            throw IOException("Failed to parse mlc-app-config.json", error)
        }

        return modelDir to modelLib
    }

    private fun emit(payload: Map<String, Any?>) {
        val sink = eventSinkRef.get() ?: return
        mainHandler.post { sink.success(payload) }
    }

    private fun emitError(code: String, message: String, requestId: String?) {
        val sink = eventSinkRef.get() ?: return
        val payload = mutableMapOf<String, Any?>("type" to "error", "code" to code, "message" to message)
        if (requestId != null) {
            payload["requestId"] = requestId
        }
        mainHandler.post { sink.success(payload) }
    }

    private fun createEngineController(): EngineController {
        // TODO: Replace fallback echo engine with real MLC integration once native libraries are bundled.
        return EchoEngineController()
    }
}

private interface EngineController {
    suspend fun initialize(modelDir: File, modelLib: String?)
    suspend fun generate(
        prompt: String,
        requestId: String,
        temperature: Double?,
        topP: Double?,
        emitToken: suspend (String) -> Unit
    )

    fun cancel(requestId: String)
    suspend fun shutdown()
}

private class EchoEngineController(
    private val delayMillis: Long = 20L
) : EngineController {

    override suspend fun initialize(modelDir: File, modelLib: String?) {
        // No-op for the echo engine; real implementation will warm up MLC runtime here.
    }

    override suspend fun generate(
        prompt: String,
        requestId: String,
        temperature: Double?,
        topP: Double?,
        emitToken: suspend (String) -> Unit
    ) {
        val tokens = prompt.split(Regex("\\s+")).filter { it.isNotBlank() }
        if (tokens.isEmpty()) {
            emitToken("")
            return
        }

        val context = currentCoroutineContext()
        for (token in tokens) {
            context.ensureActive()
            emitToken("$token ")
            delay(delayMillis)
        }
    }

    override fun cancel(requestId: String) {
        // Nothing to cancel in the echo engine.
    }

    override suspend fun shutdown() {}
}
