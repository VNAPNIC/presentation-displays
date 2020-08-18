import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:presentation_displays/displays_manager.dart';

typedef ArgumentsCallback = Function(dynamic arguments);



class PresentationDisplay extends StatefulWidget {

  /// This widget will wrap the Presentation View Flutter UI, it will receive data transmitted from [DisplaysManager].
  /// [callback] func to receive data transmitted from the [DisplaysManager].
  /// [child] Flutter UI displayed on Presentation
  PresentationDisplay({@required this.callback, this.child});

 final ArgumentsCallback callback;

 final Widget child;

  @override
  _PresentationDisplayState createState() => _PresentationDisplayState();
}

class _PresentationDisplayState extends State<PresentationDisplay> {
  final _presentationChannel = "presentation_displays_plugin_0_engine";
  MethodChannel _presentationMethodChannel;

  @override
  void initState() {
    _addListenerForPresentation(widget.callback);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child??Container();
  }

  /// Only use a subscription to listen within the presentation display
  /// <p>
  /// Sets a callback for receiving method calls on this [_addListenerForPresentation].
  /// The given callback will replace the currently registered callback for this
  /// [_addListenerForPresentation], if any.
  ///
  /// If the future returned by the handler completes with a result
  /// </p>
  _addListenerForPresentation(ArgumentsCallback function) {
    _presentationMethodChannel = MethodChannel(_presentationChannel);
    _presentationMethodChannel.setMethodCallHandler((call) async {
      function(call.arguments);
    });
  }
}
