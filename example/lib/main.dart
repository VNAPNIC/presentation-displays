import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:presentation_displays/presentation_displays.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DisplayController controller = DisplayController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              RaisedButton(onPressed: () async {
                print("_MyAppState --------------------------------> ${await controller.getDisplays()}");
              }),
              Expanded(child: PresentationDisplays(controller: controller,)),
            ],
          ),
        ),
      ),
    );
  }
}
