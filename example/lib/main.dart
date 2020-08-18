import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:presentation_displays/PresentationDisplays.dart';
import 'package:presentation_displays/displays_manager.dart';
import 'package:presentation_displays/display.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(builder: (_) => DisplayManager());
    case 'presentation':
      return MaterialPageRoute(builder: (_) => Presentation());
    default:
      return MaterialPageRoute(
          builder: (_) =>
              Scaffold(
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
        child: Text(title, style: TextStyle(fontSize: 40),),
      ),
    );
  }
}

/// Displays manager

class DisplayManager extends StatefulWidget {
  @override
  _DisplayManagerState createState() => _DisplayManagerState();
}

class _DisplayManagerState extends State<DisplayManager> {
  DisplayController controller = DisplayController();
  List<Display> displays = [];

  @override
  Widget build(BuildContext context) {
    return DisplaysManager(
      controller: controller,
      child: Scaffold(
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
                    final values = await controller.getDisplays();
                    print(values);
                    displays.clear();
                    displays.addAll(values);
                    print(displays);
                  }),
                  Button("ShowPresentation", () async {
                    final value = await controller.showPresentation(displayId: displays[1].displayId,routerName:"presentation");
                  }),
                  Button("NameByDisplayId", () async {
                    final value = await controller
                        .getNameByDisplayId(displays[1].displayId);
                    print(value);
                  }),
                  Button("NameByIndex", () async {
                    final value = await controller.getNameByIndex(1);
                    print(value);
                  }),
                  Button("TransferData", () async {
                    final value = await controller.transferDataToPresentation("test transfer data");
                    print(value);
                  })
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


/// Presentation
class Presentation extends StatefulWidget {
  @override
  _PresentationState createState() => _PresentationState();
}

class _PresentationState extends State<Presentation> {
  String value = "init";
  @override
  Widget build(BuildContext context) {
    return PresentationDisplay(callback: (argument){
      setState(() {
        value = argument;
      });
    },child: Center(child: Text(value),),);
  }
}

