package com.namit.presentation_displays

import android.hardware.display.DisplayManager
import android.util.Log
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
import org.json.JSONObject

class PresentationDisplaysView internal
constructor(
        private val registrar: PluginRegistry.Registrar,
        private val methodChannel: MethodChannel,
        private val viewId: Int,
        private val displayManager: DisplayManager) :
        PlatformView, MethodChannel.MethodCallHandler {

    private val TAG = "${PresentationDisplaysPlugin.viewTypeId}_$viewId"
    private var flutterEngineChannel: MethodChannel? = null

    init {
        methodChannel.setMethodCallHandler(this)
    }

    /**
     * @hide
     */
    override fun getView(): View {
        return View(registrar.context())
    }

    /**
     * @hide
     */
    override fun dispose() {
    }

    /**
     * @hide
     */
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        Log.i(TAG, "Channel: method: ${call.method} | arguments: ${call.arguments}")
        when (call.method) {
            "showPresentation" -> {
                try {
                    val obj = JSONObject(call.arguments as String)
                    Log.i(TAG, "Channel: method: ${call.method} | displayId: ${obj.getInt("displayId")} | routerName: ${obj.getString("routerName")}")

                    val displayId: Int = obj.getInt("displayId")
                    val tag: String = obj.getString("routerName")
                    val display = displayManager.getDisplay(displayId)
                    val flutterEngine = createFlutterEngine(tag)

                    if (display != null) {
                        flutterEngine?.let {
                            flutterEngineChannel = MethodChannel(it.dartExecutor.binaryMessenger, "${TAG}_engine")
                            val presentation = PresentationDisplay(registrar.activity(), tag, display)
                            presentation.show()
                            result.success(true)
                        } ?: result.error("404", "Can't find FlutterEngine", null)

                    } else {
                        result.error("404", "Can't find display with displayId is $displayId", null)
                    }

                } catch (e: Exception) {
                    result.error(call.method, e.message, null)
                }
            }
            "listDisplay" -> {
                val gson = Gson()
                val category = call.arguments
                val displays = displayManager.getDisplays(category as String?)
                val listJson = ArrayList<DisplayJson>();
                for (display: Display in displays) {
                    val d = DisplayJson(display.displayId, display.flags, display.rotation, display.name)
                    listJson.add(d)
                }
                result.success(gson.toJson(listJson))
            }
            "transferDataToPresentation" -> {
                try {
                    flutterEngineChannel?.invokeMethod("DataTransfer", call.arguments)
                    result.success(true)
                } catch (e: Exception) {
                    result.success(false)
                }
            }
        }
    }

    private fun createFlutterEngine(tag: String): FlutterEngine? {
        if (FlutterEngineCache.getInstance().get(tag) == null) {
            val flutterEngine = FlutterEngine(registrar.context())
            flutterEngine.navigationChannel.setInitialRoute(tag)
            flutterEngine.dartExecutor.executeDartEntrypoint(
                    DartExecutor.DartEntrypoint.createDefault()
            )
            flutterEngine.lifecycleChannel.appIsResumed()
            // Cache the FlutterEngine to be used by FlutterActivity.
            FlutterEngineCache.getInstance().put(tag, flutterEngine)
        }
        return FlutterEngineCache.getInstance().get(tag)
    }
}