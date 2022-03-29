import Flutter
import UIKit

public class SwiftPresentationDisplaysPlugin: NSObject, FlutterPlugin {
  var additionalWindows = [UIScreen: UIWindow]()
  var screens = [UIScreen]()
  var flutterEngineChannel: FlutterMethodChannel = .init()
  public static var controllerAdded: ((FlutterViewController) -> Void)?

  override public init() {
    super.init()

    screens.append(UIScreen.main)
    NotificationCenter.default.addObserver(forName: UIScreen.didConnectNotification,
                                           object: nil, queue: nil)
    { notification in
      // Get the new screen information.
      guard let newScreen = notification.object as? UIScreen else {
        return
      }

      // Configure a window for the screen.
      let newWindow = UIWindow(frame: newScreen.bounds)
      newWindow.screen = newScreen

      // You must show the window explicitly.
      newWindow.isHidden = true

      // Save a reference to the window in a local array.
      self.screens.append(newScreen)
      self.additionalWindows[newScreen] = newWindow
    }

    NotificationCenter.default.addObserver(forName:
      UIScreen.didDisconnectNotification,
      object: nil,
      queue: nil)
    { notification in
        guard let disconnectedScreen = notification.object as? UIScreen else {
          return
        }

        // Remove the window associated with the screen.
        for screen in self.screens {
          if disconnectedScreen == screen {
            if let index = self.screens.firstIndex(of: screen) {
              self.screens.remove(at: index)
              // Remove the window and its contents.
              self.additionalWindows.removeValue(forKey: screen)
            }
          }
        }
      }
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "presentation_displays_plugin", binaryMessenger: registrar.messenger())
    let instance = SwiftPresentationDisplaysPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == "listDisplay" {
      var jsonDisplaysList = "["
      for i in 0 ..< screens.count {
        jsonDisplaysList += "{\"displayId\":" + String(i) + ", \"name\":\"Screen " + String(i) + "\"},"
      }
      jsonDisplaysList = String(jsonDisplaysList.dropLast())
      jsonDisplaysList += "]"
      jsonDisplaysList = jsonDisplaysList.replacingOccurrences(of: "Screen 0", with: "Built-in Screen")
      result(jsonDisplaysList)
    } else if call.method == "showPresentation" {
      let args = call.arguments as? String
      let data = args?.data(using: .utf8)!
      do {
        if let json = try JSONSerialization.jsonObject(with: data ?? Data(), options: .allowFragments) as? [String: Any] {
          print(json)
          showPresentation(index: json["displayId"] as? Int ?? 1, routerName: json["routerName"] as? String ?? "presentation")
        } else {
          print("bad json")
        }
      } catch let error as NSError {
        print(error)
      }
    } else if call.method == "transferDataToPresentation" {
      flutterEngineChannel.invokeMethod("DataTransfer", arguments: call.arguments)
    } else {
      result(FlutterMethodNotImplemented)
    }
  }

  private func showPresentation(index: Int, routerName: String) {
    if index > 0, index < screens.count, additionalWindows.keys.contains(screens[index]) {
      let screen = screens[index]
      let window = additionalWindows[screen]

      // You must show the window explicitly.
      window?.isHidden = false

      let extVC = FlutterViewController()
      SwiftPresentationDisplaysPlugin.controllerAdded?(extVC)
      extVC.setInitialRoute(routerName)
      window?.rootViewController = extVC

      flutterEngineChannel = FlutterMethodChannel(name: "presentation_displays_plugin_engine", binaryMessenger: extVC.binaryMessenger)
    }
  }
}
