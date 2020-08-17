package com.namit.presentation_displays

import android.annotation.SuppressLint
import android.app.Presentation
import android.hardware.display.DisplayManager
import android.hardware.display.DisplayManager.DISPLAY_CATEGORY_PRESENTATION
import android.util.Log
import android.util.SparseArray
import android.view.Display
import android.view.View
import com.google.gson.Gson
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.platform.PlatformView
import java.lang.Exception

class PresentationDisplaysView internal
constructor(
        private val registrar: PluginRegistry.Registrar,
        private val methodChannel: MethodChannel,
        private val viewId: Int,
        private val displayManager: DisplayManager) :
        PlatformView, MethodChannel.MethodCallHandler {

    private val TAG = "${PresentationDisplaysPlugin.viewTypeId}_$viewId"

    private var mActivePresentations = SparseArray<Presentation>()
    private var flutterEngineChannel: MethodChannel

    init {
        methodChannel.setMethodCallHandler(this)

        val flutterEngine = FlutterEngine(registrar.context())
        flutterEngine.navigationChannel.setInitialRoute(TAG)
        flutterEngine.dartExecutor.executeDartEntrypoint(
                DartExecutor.DartEntrypoint.createDefault()
        )
        flutterEngine.lifecycleChannel.appIsResumed()
        // Cache the FlutterEngine to be used by FlutterActivity.
        FlutterEngineCache.getInstance().put(TAG, flutterEngine)

        flutterEngineChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "${TAG}_engine")
    }

    override fun getView(): View {
        return View(registrar.context())
    }

    override fun dispose() {
    }

    @SuppressLint("NewApi")
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        Log.i(TAG, "Channel: method: ${call.method} | arguments: ${call.arguments}")
        when (call.method) {
            "connect" -> {
                if (displayManager.displays.size > 1) {
                    val display = displayManager.displays[1]
                    val presentation = PresentationDisplay(registrar.activity(), viewId, display)
                    presentation.show()
                    mActivePresentations.put(display.displayId, presentation)
                    result.success("Connected")
                } else {
                    result.error("4", "Error", "4")
                }
            }
            "listDisplay" -> {
                val gson = Gson()
                val displays = displayManager.displays

                val listJson= ArrayList<DisplayJson>();
                for (display: Display in displays) {
                    val d = DisplayJson(display.displayId, display.flags, display.rotation, display.name)
                    listJson.add(d)
                }
                result.success(gson.toJson(listJson))
            }
            "displayName" -> {
                try {
                    val display = displayManager.displays[call.arguments as Int]
                    result.success(display.name)
                } catch (e: Exception) {
                    result.error(call.method, e.message, null);
                }
            }
        }
    }
}