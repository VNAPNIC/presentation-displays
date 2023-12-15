import Flutter
import UIKit

public class SwiftPresentationDisplaysPlugin: NSObject, FlutterPlugin {
    var additionalWindows = [UIScreen:UIWindow]()
    var screens = [UIScreen]()
    var flutterEngineChannel:FlutterMethodChannel?=nil
    public static var controllerAdded: ((FlutterViewController)->Void)?

    public override init() {
        super.init()

        screens.append(UIScreen.main)
        NotificationCenter.default.addObserver(forName: UIScreen.didConnectNotification,
                                               object: nil, queue: nil) {
            notification in

            // Get the new screen information.
            guard let newScreen = notification.object as? UIScreen else {
                    return
                  }

            let screenDimensions = newScreen.bounds
            // Configure a window for the screen.
            let newWindow = UIWindow(frame: screenDimensions)
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
                                               queue: nil) { notification in
            guard let screen = notification.object as? UIScreen else {
                    return
                  }

           // Remove the window associated with the screen.
                 for s in self.screens {
                   if s == screen {
                     if let index = self.screens.firstIndex(of: s) {
                       self.screens.remove(at: index)
                       // Remove the window and its contents.
                       self.additionalWindows.removeValue(forKey: s)
                     }
                   }
                 }
        }
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "presentation_displays_plugin", binaryMessenger: registrar.messenger())
        let instance = SwiftPresentationDisplaysPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        let eventChannel = FlutterEventChannel(name: "presentation_displays_plugin_events", binaryMessenger: registrar.messenger())
        let displayConnectedStreamHandler = DisplayConnectedStreamHandler()
        eventChannel.setStreamHandler(displayConnectedStreamHandler)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "listDisplay" {
            var jsonDisplaysList = "[";
            for i in 0..<screens.count {
                jsonDisplaysList+="{\"displayId\":"+String(i)+", \"name\":\"Screen "+String(i)+"\"},"
            }
            jsonDisplaysList = String(jsonDisplaysList.dropLast())
            jsonDisplaysList+="]"
            jsonDisplaysList = jsonDisplaysList.replacingOccurrences(of: "Screen 0", with: "Built-in Screen")
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
                    result(true)
                }
                else {
                    print("bad json")
                    result(false)
                }
            }
            catch let error as NSError {
                print(error)
                result(false)
            }
        }
        else if call.method=="hidePresentation"{
            let args = call.arguments as? String
            let data = args?.data(using: .utf8)!
            do {
                if let json = try JSONSerialization.jsonObject(with: data ?? Data(), options : .allowFragments) as? Dictionary<String,Any>
                {
                    print(json)
                    hidePresentation(index:json["displayId"] as? Int ?? 1)
                    result(true)
                }
                else {
                    print("bad json")
                    result(false)
                }
            }
            catch let error as NSError {
                print(error)
                result(false)
            }
        }
        else if call.method=="transferDataToPresentation"{
            self.flutterEngineChannel?.invokeMethod("DataTransfer", arguments: call.arguments)
            result(true)
        }
        else
        {
            result(FlutterMethodNotImplemented)
        }

    }

    private func showPresentation(index:Int, routerName:String )
    {
        if index>0 && index < self.screens.count && self.additionalWindows.keys.contains(self.screens[index])
        {
            let screen=self.screens[index]
            let window=self.additionalWindows[screen]

            if (window != nil){
                window!.isHidden=false
                if (window!.rootViewController == nil || !(window!.rootViewController is FlutterViewController)){
                    let extVC = FlutterViewController(project: nil, initialRoute: routerName, nibName: nil, bundle: nil)
                    SwiftPresentationDisplaysPlugin.controllerAdded!(extVC)
                    window?.rootViewController = extVC

                    self.flutterEngineChannel = FlutterMethodChannel(name: "presentation_displays_plugin_engine", binaryMessenger: extVC.binaryMessenger)
                }
            }
        }
    }

    private func hidePresentation(index:Int)
    {
        if index>0 && index < self.screens.count && self.additionalWindows.keys.contains(self.screens[index])
        {
            let screen=self.screens[index]
            let window=self.additionalWindows[screen]

            window?.isHidden=true
        }
    }

}

class DisplayConnectedStreamHandler: NSObject, FlutterStreamHandler{
    var sink: FlutterEventSink?
    var didConnectObserver: NSObjectProtocol?
    var didDisconnectObserver: NSObjectProtocol?

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        sink = events
        didConnectObserver = NotificationCenter.default.addObserver(forName: UIScreen.didConnectNotification,
                            object: nil, queue: nil) { (notification) in
            guard let sink = self.sink else { return }
            sink(1)
           }
        didDisconnectObserver = NotificationCenter.default.addObserver(forName: UIScreen.didDisconnectNotification,
                            object: nil, queue: nil) { (notification) in
            guard let sink = self.sink else { return }
            sink(0)
           }
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        sink = nil
        if (didConnectObserver != nil){
            NotificationCenter.default.removeObserver(didConnectObserver!)
        }
        if (didDisconnectObserver != nil){
            NotificationCenter.default.removeObserver(didDisconnectObserver!)
        }
        return nil
    }
}
