import Flutter
import UIKit

public class SwiftPresentationDisplaysPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "presentation_displays", binaryMessenger: registrar.messenger())
    let instance = SwiftPresentationDisplaysPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
