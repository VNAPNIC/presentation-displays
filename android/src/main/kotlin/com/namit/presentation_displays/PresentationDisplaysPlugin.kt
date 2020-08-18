package com.namit.presentation_displays

import io.flutter.plugin.common.PluginRegistry.Registrar

/** PresentationDisplaysPlugin */
object PresentationDisplaysPlugin {

  const val viewTypeId = "presentation_displays_plugin"

  /**
   * @hide
   */
  @JvmStatic
  fun registerWith(registrar: Registrar) {
    registrar.platformViewRegistry().registerViewFactory(viewTypeId, PresentationDisplaysFactory(registrar.messenger(),registrar))
  }
}
