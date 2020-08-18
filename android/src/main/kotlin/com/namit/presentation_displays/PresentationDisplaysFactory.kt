package com.namit.presentation_displays

import android.content.Context
import android.hardware.display.DisplayManager
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

//class PresentationDisplaysFactory(private val messenger: BinaryMessenger, private val registrar: PluginRegistry.Registrar)
//    : PlatformViewFactory(StandardMessageCodec.INSTANCE){
//
//    /**
//     * @hide
//     */
//    override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
//        val methodChannel = MethodChannel(messenger, "${PresentationDisplaysPlugin.viewTypeId}_$viewId")
//        val displayManager = context?.getSystemService(Context.DISPLAY_SERVICE) as DisplayManager
//        return PresentationDisplaysView(registrar, methodChannel, viewId, displayManager)
//    }
//}