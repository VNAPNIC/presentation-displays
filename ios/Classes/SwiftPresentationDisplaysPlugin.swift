import Flutter
import UIKit

public class SwiftPresentationDisplaysPlugin: NSObject, FlutterPlugin {
     static var additionalWindows = [UIWindow]()
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "presentation_displays_plugin", binaryMessenger: registrar.messenger())
    let instance = SwiftPresentationDisplaysPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
      
      NotificationCenter.default.addObserver(forName: UIScreen.didConnectNotification,
                                                 object: nil, queue: nil) { notification in
            // Get the new screen information.
            let newScreen = notification.object as! UIScreen
            let screenDimensions = newScreen.bounds

            // Configure a window for the screen.
            let newWindow = UIWindow(frame: screenDimensions)
            newWindow.screen = newScreen
          
            // You must show the window explicitly.
            newWindow.isHidden = false
            // Save a reference to the window in a local array.
          self.additionalWindows.append(newWindow)
      }
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      //    result("iOS " + UIDevice.current.systemVersion)
      if call.method=="showPresentation"{
          showPresentation()
      }
  }
    private  func showPresentation()
    {
        let extVC = FlutterViewController()
        extVC.setInitialRoute("presentation")
        SwiftPresentationDisplaysPlugin.additionalWindows[0].rootViewController = extVC
    }
}
