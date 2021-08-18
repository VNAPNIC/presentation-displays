import UIKit
import Flutter
import presentation_displays
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    SwiftPresentationDisplaysPlugin.controllerAdded = controllerAdded
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    func controllerAdded(controller:FlutterViewController)
    {
        GeneratedPluginRegistrant.register(with: controller)
    }
}
