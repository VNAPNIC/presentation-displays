import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:presentation_displays/displays_manager.dart';
import 'package:presentation_displays/secondary_display.dart';

/// This widget will wrap the main display, it will receive data transmitted from [DisplayManager].
/// [MainDisplay.callback] instance of [ArgumentsCallback] to receive data transmitted from the [DisplayManager].
/// [MainDisplay.child] child widget of main display
class MainDisplay extends StatefulWidget {
  const MainDisplay({Key? key, required this.callback, required this.child})
      : super(key: key);

  /// instance of [ArgumentsCallback] to receive data transmitted from the [DisplaysManager].
  final ArgumentsCallback callback;

  /// Your Flutter UI on Main Screen
  final Widget child;

  @override
  _MainDisplayState createState() => _MainDisplayState();
}

class _MainDisplayState extends State<MainDisplay> {
  final _mainChannel = "main_display_channel";
  MethodChannel? _mainMethodChannel;

  @override
  void initState() {
    _addListenerForMain(widget.callback);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  _addListenerForMain(ArgumentsCallback function) {
    _mainMethodChannel = MethodChannel(_mainChannel);
    _mainMethodChannel?.setMethodCallHandler((call) async {
      function(call.arguments);
    });
  }
}
