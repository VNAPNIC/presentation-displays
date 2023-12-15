import 'package:flutter/material.dart';
import 'package:presentation_displays/display.dart';
import 'package:presentation_displays/displays_manager.dart';
import 'package:presentation_displays/main_display.dart';
import 'package:presentation_displays/secondary_display.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(builder: (_) => const DisplayManagerScreen());
    case 'presentation':
      return MaterialPageRoute(builder: (_) => const SecondaryScreen());
    default:
      return MaterialPageRoute(
          builder: (_) => Scaffold(
                body: Center(
                    child: Text('No route defined for ${settings.name}')),
              ));
  }
}

void main() {
  debugPrint('first main');
  runApp(const MyApp());
}

@pragma('vm:entry-point')
void secondaryDisplayMain() {
  debugPrint('second main');
  runApp(const MySecondApp());
}

class MySecondApp extends StatelessWidget {
  const MySecondApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      onGenerateRoute: generateRoute,
      initialRoute: 'presentation',
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      onGenerateRoute: generateRoute,
      initialRoute: '/',
    );
  }
}

class Button extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;

  const Button({Key? key, required this.title, this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4.0),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(
          title,
          style: const TextStyle(fontSize: 25),
        ),
      ),
    );
  }
}

/// Main Screen
class DisplayManagerScreen extends StatefulWidget {
  const DisplayManagerScreen({Key? key}) : super(key: key);

  @override
  _DisplayManagerScreenState createState() => _DisplayManagerScreenState();
}

class _DisplayManagerScreenState extends State<DisplayManagerScreen> {
  DisplayManager displayManager = DisplayManager();
  List<Display?> displays = [];

  final TextEditingController _indexToShareController = TextEditingController();
  final TextEditingController _dataToTransferController =
      TextEditingController();

  final TextEditingController _nameOfIdController = TextEditingController();
  String _nameOfId = "";
  final TextEditingController _nameOfIndexController = TextEditingController();
  String _nameOfIndex = "";

  dynamic dataFromMain;

  @override
  void initState() {
    displayManager.connectedDisplaysChangedStream?.listen(
      (event) {
        debugPrint("connected displays changed: $event");
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MainDisplay(
      callback: (arguments) {
        setState(() {
          dataFromMain = arguments;
        });
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _getDisplays(),
                _showPresentation(),
                _hidePresentation(),
                _transferData(),
                _dataFromSecond(),
                _getDisplayeById(),
                _getDisplayByIndex(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getDisplays() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Button(
            title: "Get Displays",
            onPressed: () async {
              final values = await displayManager.getDisplays();
              displays.clear();
              setState(() {
                displays.addAll(values!);
              });
            }),
        ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            padding: const EdgeInsets.all(8),
            itemCount: displays.length,
            itemBuilder: (BuildContext context, int index) {
              return SizedBox(
                height: 50,
                child: Center(
                    child: Text(
                        ' ${displays[index]?.displayId} ${displays[index]?.name}')),
              );
            }),
        const Divider()
      ],
    );
  }

  Widget _showPresentation() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _indexToShareController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Index to share screen',
            ),
          ),
        ),
        Button(
            title: "Show presentation",
            onPressed: () async {
              int? displayId = int.tryParse(_indexToShareController.text);
              if (displayId != null) {
                for (final display in displays) {
                  if (display?.displayId == displayId) {
                    displayManager.showSecondaryDisplay(
                        displayId: displayId, routerName: "presentation");
                  }
                }
              }
            }),
        const Divider(),
      ],
    );
  }

  Widget _hidePresentation() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _indexToShareController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Index to hide screen',
            ),
          ),
        ),
        Button(
            title: "Hide presentation",
            onPressed: () async {
              int? displayId = int.tryParse(_indexToShareController.text);
              if (displayId != null) {
                for (final display in displays) {
                  if (display?.displayId == displayId) {
                    displayManager.hideSecondaryDisplay(displayId: displayId);
                  }
                }
              }
            }),
        const Divider(),
      ],
    );
  }

  Widget _transferData() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _dataToTransferController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Data to transfer',
            ),
          ),
        ),
        Button(
            title: "TransferData",
            onPressed: () async {
              String data = _dataToTransferController.text;
              await displayManager.transferDataToPresentation(data);
            }),
        const Divider(),
      ],
    );
  }

  Widget _dataFromSecond() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Data from second: ${dataFromMain ?? '-'}'),
        ),
        const Divider(),
      ],
    );
  }

  Widget _getDisplayeById() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _nameOfIdController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Id',
            ),
          ),
        ),
        Button(
            title: "NameByDisplayId",
            onPressed: () async {
              int? id = int.tryParse(_nameOfIdController.text);
              if (id != null) {
                final value = await displayManager
                    .getNameByDisplayId(displays[id]?.displayId ?? -1);
                setState(() {
                  _nameOfId = value ?? "";
                });
              }
            }),
        SizedBox(
          height: 50,
          child: Center(child: Text(_nameOfId)),
        ),
        const Divider(),
      ],
    );
  }

  Widget _getDisplayByIndex() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _nameOfIndexController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Index',
            ),
          ),
        ),
        Button(
            title: "NameByIndex",
            onPressed: () async {
              int? index = int.tryParse(_nameOfIndexController.text);
              if (index != null) {
                final value = await displayManager.getNameByIndex(index);
                setState(() {
                  _nameOfIndex = value ?? "";
                });
              }
            }),
        SizedBox(
          height: 50,
          child: Center(child: Text(_nameOfIndex)),
        ),
        const Divider(),
      ],
    );
  }
}

/// UI of Presentation display
class SecondaryScreen extends StatefulWidget {
  const SecondaryScreen({Key? key}) : super(key: key);

  @override
  _SecondaryScreenState createState() => _SecondaryScreenState();
}

class _SecondaryScreenState extends State<SecondaryScreen> {
  String value = "init";
  DisplayManager displayManager = DisplayManager();

  final TextEditingController _dataToTransferController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SecondaryDisplay(
      callback: (dynamic argument) {
        setState(() {
          value = argument;
        });
      },
      child: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [_getTransferToMainButton(), _getDataFromMainText()],
          ),
        ),
      ),
    ));
  }

  Widget _getTransferToMainButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _dataToTransferController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Data',
            ),
          ),
        ),
        Button(
            title: "TransferDataToMain",
            onPressed: () async {
              displayManager.transferDataToMain(_dataToTransferController.text);
            }),
        const Divider(),
      ],
    );
  }

  Widget _getDataFromMainText() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 50,
          child: Center(child: Text('Data from main: $value')),
        ),
        const Divider(),
      ],
    );
  }
}
