package com.andromedax.ascent

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {

  private var mlcBridgePlugin: MlcBridgePlugin? = null

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    mlcBridgePlugin = MlcBridgePlugin.register(
      applicationContext,
      flutterEngine.dartExecutor.binaryMessenger,
    )
  }

  override fun onDestroy() {
    mlcBridgePlugin?.dispose()
    mlcBridgePlugin = null
    super.onDestroy()
  }
}
