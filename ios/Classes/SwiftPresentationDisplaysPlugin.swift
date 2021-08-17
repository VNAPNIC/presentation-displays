import Flutter
import UIKit

public class SwiftPresentationDisplaysPlugin: NSObject, FlutterPlugin {
    static var additionalWindows = [UIScreen:UIWindow]()
    static var screens = [UIScreen]()
    var flutterEngineChannel:FlutterMethodChannel=FlutterMethodChannel()
    public static var controllerAdded: ((FlutterViewController)->Void)?
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "presentation_displays_plugin", binaryMessenger: registrar.messenger())
        let instance = SwiftPresentationDisplaysPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        screens.append(UIScreen.main)

        NotificationCenter.default.addObserver(forName: UIScreen.didConnectNotification,
                                               object: nil, queue: nil) {
            notification in

            // Get the new screen information.
            let newScreen = notification.object as! UIScreen
            let screenDimensions = newScreen.bounds
            
            // Configure a window for the screen.
            let newWindow = UIWindow(frame: screenDimensions)
            newWindow.screen = newScreen

            // You must show the window explicitly.
            newWindow.isHidden = true

            // Save a reference to the window in a local array.
            self.screens.append(newScreen)
            self.additionalWindows[newScreen]=newWindow
        }
        NotificationCenter.default.addObserver(forName:
                                                    UIScreen.didDisconnectNotification,
                                               object: nil,
                                               queue: nil) { notification in
          let screen = notification.object as! UIScreen

          // Remove the window associated with the screen.
            for s in self.screens {
            if s == screen {
                let index = self.screens.index(of: s)
                self.screens.remove(at: index!)
              // Remove the window and its contents.
              self.additionalWindows.removeValue(forKey: s)
            }
          }
        }

    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        //    result("iOS " + UIDevice.current.systemVersion)
        if  call.method=="listDisplay"
        {
            var  jsonDisplaysList:String = "[";
            let screensList = SwiftPresentationDisplaysPlugin.screens
            for i in 0..<screensList.count {
                jsonDisplaysList+="{\"displayId\":"+String(i)+", \"name\":\"Screen "+String(i)+"\"},"
            }

            jsonDisplaysList = String(jsonDisplaysList.dropLast())
            jsonDisplaysList+="]"
            jsonDisplaysList = jsonDisplaysList.replacingOccurrences(of: "Screen 0", with: "Built-in Screen")
            print(jsonDisplaysList)
            result(jsonDisplaysList)
        }
        else if call.method=="showPresentation"{
            let args = call.arguments as? String
            let data = args?.data(using: .utf8)!
                do {
                    if let json = try JSONSerialization.jsonObject(with: data ?? Data(), options : .allowFragments) as? Dictionary<String,Any>
                        {
                        print(json)
                        showPresentation(index:json["displayId"] as? Int ?? 1, routerName: json["routerName"] as? String ?? "presentation")
                    }
                    else {
                    print("bad json")
                }
                }
                    catch let error as NSError {
                    print(error)
                }
                }
                    else if call.method=="transferDataToPresentation"{
                    self.flutterEngineChannel.invokeMethod("DataTransfer", arguments: call.arguments)
                }
            else
            {
                result(FlutterMethodNotImplemented)
            }

        }

        private  func showPresentation(index:Int, routerName:String )
        {
            if index>0 && index < SwiftPresentationDisplaysPlugin.screens.count && SwiftPresentationDisplaysPlugin.additionalWindows.keys.contains(SwiftPresentationDisplaysPlugin.screens[index])
            {
                let screen=SwiftPresentationDisplaysPlugin.screens[index]
                let window=SwiftPresentationDisplaysPlugin.additionalWindows[screen]

                // You must show the window explicitly.
                window?.isHidden=false

                let extVC = FlutterViewController()
                SwiftPresentationDisplaysPlugin.controllerAdded!(extVC)
                extVC.setInitialRoute(routerName)
                window?.rootViewController = extVC


                self.flutterEngineChannel = FlutterMethodChannel(name: "presentation_displays_plugin_engine", binaryMessenger: extVC.binaryMessenger)
            }

        }

    }
