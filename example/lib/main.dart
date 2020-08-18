import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:presentation_displays/presentation_displays.dart';
import 'package:presentation_displays/display.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DisplayController controller = DisplayController();

  List<Display> displays = [];

  @override
  void initState() {
    controller.addListenerForPresentation((value) {
      debugPrint('MyApp ---------> arguments: $value');
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PresentationDisplays(
        controller: controller,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: Center(
            child: Column(
              children: <Widget>[
                Wrap(
                  children: <Widget>[
                    Button("Get Displays", () async {
                      final values = await controller.getDisplays();
                      print(values);
                      displays.clear();
                      displays.addAll(values);
                      print(displays);
                    }),
                    Button("ShowPresentation", () async {
                      final value = await controller.showPresentation(displays[1].displayId,"testtttttttttttttttt");
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
                      final value = await controller
                          .transferDataToPresentation("test transfer data");
                      print(value);
                    })
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
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
        child: Text(title),
      ),
    );
  }
}
