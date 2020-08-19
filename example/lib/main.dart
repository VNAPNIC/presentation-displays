import 'package:flutter/material.dart';
import 'package:presentation_displays/displays_manager.dart';
import 'package:presentation_displays/display.dart';
import 'package:presentation_displays/secondary_display.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(builder: (_) => DisplayManagerScreen());
    case 'presentation':
      return MaterialPageRoute(builder: (_) => SecondaryScreen());
    default:
      return MaterialPageRoute(
          builder: (_) => Scaffold(
                body: Center(
                    child: Text('No route defined for ${settings.name}')),
              ));
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: generateRoute,
      initialRoute: '/',
    );
  }
}

class Button extends StatelessWidget {
  Button(this.title, this.function);

  final String title;
  final Function function;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(4.0),
      child: RaisedButton(
        onPressed: function,
        child: Text(
          title,
          style: TextStyle(fontSize: 40),
        ),
      ),
    );
  }
}

/// Main Screen
class DisplayManagerScreen extends StatefulWidget {
  @override
  _DisplayManagerScreenState createState() => _DisplayManagerScreenState();
}

class _DisplayManagerScreenState extends State<DisplayManagerScreen> {
  DisplayManager displayManager = DisplayManager();
  List<Display> displays = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Wrap(
              alignment: WrapAlignment.center,
              children: <Widget>[
                Button("Get Displays", () async {
                  final values = await displayManager.getDisplays();
                  print(values);
                  displays.clear();
                  displays.addAll(values);
                  print(displays);
                }),
                Button("Show presentation", () async {
                  displayManager.showSecondaryDisplay(
                      displayId: displays[1].displayId,
                      routerName: "presentation");
                }),
                Button("NameByDisplayId", () async {
                  final value = await displayManager
                      .getNameByDisplayId(displays[1].displayId);
                  print(value);
                }),
                Button("NameByIndex", () async {
                  final value = await displayManager.getNameByIndex(1);
                  print(value);
                }),
                Button("TransferData", () async {
                  final value = await displayManager
                      .transferDataToPresentation("test transfer data");
                  print(value);
                })
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// UI of Presentation display
class SecondaryScreen extends StatefulWidget {
  @override
  _SecondaryScreenState createState() => _SecondaryScreenState();
}

class _SecondaryScreenState extends State<SecondaryScreen> {
  String value = "init";

  @override
  Widget build(BuildContext context) {
    return SecondaryDisplay(
      callback: (argument) {
        setState(() {
          value = argument;
        });
      },
      child: Center(
        child: Text(value),
      ),
    );
  }
}
