import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:presentation_displays/displays_manager.dart';

/// Only use a subscription to listen within the presentation display
/// [arguments] returned  type [dynamic]
typedef ArgumentsCallback = Function(dynamic arguments);

/// This widget will wrap the Presentation View Flutter UI, it will receive data transmitted from [DisplayManager].
/// [PresentationDisplay.callback] instance of [ArgumentsCallback] to receive data transmitted from the [DisplayManager].
/// [PresentationDisplay.child] Your Flutter UI on Presentation Screen
class PresentationDisplay extends StatefulWidget {
  PresentationDisplay({@required this.callback, this.child});

  /// instance of [ArgumentsCallback] to receive data transmitted from the [DisplaysManager].
  final ArgumentsCallback callback;

  /// Your Flutter UI on Presentation Screen
  final Widget child;

  @override
  _PresentationDisplayState createState() => _PresentationDisplayState();
}

class _PresentationDisplayState extends State<PresentationDisplay> {
  final _presentationChannel = "presentation_displays_plugin_engine";
  MethodChannel _presentationMethodChannel;

  @override
  void initState() {
    _addListenerForPresentation(widget.callback);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child ?? Container();
  }

  _addListenerForPresentation(ArgumentsCallback function) {
    _presentationMethodChannel = MethodChannel(_presentationChannel);
    _presentationMethodChannel.setMethodCallHandler((call) async {
      function(call.arguments);
    });
  }
}
