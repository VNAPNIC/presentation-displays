package com.namit.presentation_displays

import android.content.ContentValues.TAG
import android.content.Context
import android.hardware.display.DisplayManager
import android.util.Log
import android.view.Display
import androidx.annotation.NonNull
import androidx.core.content.ContextCompat.getSystemService
import com.google.gson.Gson
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import org.json.JSONObject

/** PresentationDisplaysPlugin */
class PresentationDisplaysPlugin : FlutterPlugin, ActivityAware, MethodChannel.MethodCallHandler {

    private lateinit var channel: MethodChannel
    private var flutterEngineChannel: MethodChannel? = null
    private var displayManager: DisplayManager? = null
    private var context: Context? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.flutterEngine.dartExecutor, viewTypeId)
        channel.setMethodCallHandler(this)
    }

    companion object {
        private const val viewTypeId = "presentation_displays_plugin"

        @JvmStatic
        fun registerWith(registrar: PluginRegistry.Registrar) {
            val channel = MethodChannel(registrar.messenger(), viewTypeId)
            channel.setMethodCallHandler(PresentationDisplaysPlugin())
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        Log.i(TAG, "Channel: method: ${call.method} | arguments: ${call.arguments}")
        when (call.method) {
            "showPresentation" -> {
                try {
                    val obj = JSONObject(call.arguments as String)
                    Log.i(
                        TAG,
                        "Channel: method: ${call.method} | displayId: ${obj.getInt("displayId")} | routerName: ${
                            obj.getString("routerName")
                        }"
                    )
                    val displayId: Int = obj.getInt("displayId")
                    val tag: String = obj.getString("routerName")
                    val display = displayManager?.getDisplay(displayId)
                    if (display != null) {
                        val flutterEngine = createFlutterEngine(tag)
                        flutterEngine?.let {
                            flutterEngineChannel = MethodChannel(
                                it.dartExecutor.binaryMessenger,
                                "${viewTypeId}_engine"
                            )
                            val presentation =
                                context?.let { it1 -> PresentationDisplay(it1, tag, display) }
                            Log.i(TAG, "presentation: $presentation")
                            presentation?.show()
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
                val listJson = ArrayList<DisplayJson>()
                val category = call.arguments
                val displays = displayManager?.getDisplays(category as String?)
                if (displays != null) {
                    for (display: Display in displays) {
                        Log.i(TAG, "display: $display")
                        val d = DisplayJson(
                            display.displayId,
                            display.flags,
                            display.rotation,
                            display.name
                        )
                        listJson.add(d)
                    }
                }
                result.success(Gson().toJson(listJson))
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
        if (context == null)
            return null
        if (FlutterEngineCache.getInstance().get(tag) == null) {
            val flutterEngine = FlutterEngine(context!!)
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

    override fun onDetachedFromActivity() {
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        this.context = binding.activity
        this.displayManager = context?.getSystemService(Context.DISPLAY_SERVICE) as DisplayManager
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }
}
