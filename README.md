# presentation_displays

#### Supported mobile platforms iOS and Android

Flutter plugin supports to run on two screens. It's basically a tablet connected to another screen via an HDMI or Wireless

#### Plugin: [https://pub.dev/packages/presentation_displays](https://pub.dev/packages/presentation_displays)

Idea: We create a `Widget` by using Flutter code and pass it to Native code side then convert it to` FlutterEngine` and save it to `FlutterEngineCache` for later use.

Next, we define the Display by using displayId and we will define the UI flutter that needs to display by grabbing `FlutterEngine` in `FlutterEngineCache` and transferring it to Dialog `Presentation` as a View.

We provide methods to get a list of connected devices and the information of each device then transfer data from the main display to the secondary display.

Simple steps:

- Create Widgets that need to display and define them as a permanent router when you configure the router in the Flutter code.

- Get the Displays list by calling `displayManager.getDisplays ()`

- Define which Display needs to display
For instance: `displays [1] .displayId` Display the index 2.

- Display it on Display with your routerName as `presentation` `displayManager.showSecondaryDisplay (displayId: displays [1] .displayId, routerName: "presentation") `

- Transmit the data from the main display to the secondary display by `displayManager.transferDataToPresentation (" test transfer data ")`
- The secondary screen receives data

```dart
@override
Widget build (BuildContext context) {
    return SecondaryDisplay (
        callback: (argument) {
        setState (() {
        value = argument;
        });
    }
    );
}
```

You can take a look at our example to learn more about how the plugin works

#### Test on Sunmi-D2 device

![The example app running in android](https://github.com/VNAPNIC/presentation-displays/blob/master/Sequence_small.gif?raw=true)

