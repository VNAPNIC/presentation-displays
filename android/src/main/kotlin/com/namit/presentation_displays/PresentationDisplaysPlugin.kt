package com.namit.presentation_displays

import io.flutter.plugin.common.PluginRegistry.Registrar

/** PresentationDisplaysPlugin */
object PresentationDisplaysPlugin {

  val viewTypeId = "presentation_displays_plugin"

  @JvmStatic
  fun registerWith(registrar: Registrar) {
    registrar.platformViewRegistry().registerViewFactory(viewTypeId, PresentationDisplaysFactory(registrar.messenger(),registrar))
  }
}
