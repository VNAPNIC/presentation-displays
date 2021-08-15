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
  final VoidCallback? function;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(4.0),
      child: RaisedButton(
        onPressed: function,
        child: Text(
          title,
          style: TextStyle(fontSize: 25),
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
  List<Display?> displays = [];

  TextEditingController _indexToShareController = TextEditingController();
  TextEditingController _dataToTransferController = TextEditingController();

  TextEditingController _nameOfIdController = TextEditingController();
  String _nameOfId = "";
  TextEditingController _nameOfIndexController = TextEditingController();
  String _nameOfIndex = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              _transferData(),
              _getDisplayeById(),
              _getDisplayByIndex(),
            ],
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
        Button("Get Displays", () async {
          final values = await displayManager.getDisplays();
          print(values);
          displays.clear();

          setState(() {
            displays.addAll(values!);
          });
          print(displays);
        }),
        ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            padding: const EdgeInsets.all(8),
            itemCount: displays.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                height: 50,
                child: Center(
                    child: Text(
                        ' ${displays[index]?.displayId} ${displays[index]?.name}')),
              );
            }),
        Divider()
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
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Index to share screen',
            ),
          ),
        ),
        Button("Show presentation", () async {
          int? index = int.tryParse(_indexToShareController.text);
          if (index != null && index < displays.length) {
            displayManager.showSecondaryDisplay(
                displayId:
                    displays.length > 0 ? displays[index]?.displayId ?? -1 : 1,
                routerName: "presentation");
          }
        }),
        Divider(),
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
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Data to transfer',
            ),
          ),
        ),
        Button("TransferData", () async {
          String data = _dataToTransferController.text;

          final value = await displayManager.transferDataToPresentation(data);
          print(value);
        }),
        Divider(),
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
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Id',
            ),
          ),
        ),
        Button("NameByDisplayId", () async {
          int? id = int.tryParse(_nameOfIdController.text);
          if (id != null) {
            final value = await displayManager
                .getNameByDisplayId(displays[id]?.displayId ?? -1);
            print(value);
            setState(() {
              _nameOfId = value ?? "";
            });
          }
        }),
        Container(
          height: 50,
          child: Center(child: Text(_nameOfId)),
        ),
        Divider(),
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
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Index',
            ),
          ),
        ),
        Button("NameByIndex", () async {
          int? index = int.tryParse(_nameOfIndexController.text);
          if (index != null) {
            final value = await displayManager.getNameByIndex(index);
            print(value);
            setState(() {
              _nameOfIndex = value ?? "";
            });
          }
        }),
        Container(
          height: 50,
          child: Center(child: Text(_nameOfIndex)),
        ),
        Divider(),
      ],
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
