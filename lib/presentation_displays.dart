import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:presentation_displays/display.dart';

const _listDisplay = "listDisplay";
const _displayName = "displayName";

class DisplayController extends ChangeNotifier {
  final _receiverChannel = "presentation_displays_plugin_0_engine";
  final _senderChannel = "presentation_displays_plugin";

  var _viewId = 0;
  MethodChannel _channel;

  _onPlatformViewCreated(int viewId) {
    if (_viewId != viewId || _channel == null) {
      debugPrint(
          '------------------------>:_channel ${_senderChannel}_$viewId');
      _channel = MethodChannel("${_senderChannel}_$viewId");
      _channel.setMethodCallHandler((call) async {
        debugPrint(
            '------------------------>: method: ${call.method} | arguments: ${call.arguments}');
      });
    }
  }

  FutureOr<List<Display>> getDisplays() async {
    print("getDisplays ----------------------------- ${await _channel?.invokeMethod(_listDisplay)}");

    List<dynamic> dinamics = await jsonDecode(await _channel?.invokeMethod(_listDisplay)) ?? [];


    List<Display> displays = [];
    dinamics.forEach((element) {
      if(element is Display){
       displays.add(Display.fromJson(jsonDecode(jsonEncode(element))));
      }
    });
    return displays;
  }

  FutureOr<String> getName(int displayId) async {
    return await _channel?.invokeMethod(_displayName);
  }
}

class PresentationDisplays extends StatefulWidget {
  PresentationDisplays({@required this.controller});

  final DisplayController controller;

  @override
  _PresentationDisplaysState createState() => _PresentationDisplaysState();
}

class _PresentationDisplaysState extends State<PresentationDisplays> {
  @override
  Widget build(BuildContext context) {
    return AndroidView(
      viewType: widget.controller._senderChannel,
      onPlatformViewCreated: (viewId) =>
          widget.controller._onPlatformViewCreated(viewId),
    );
  }
}
