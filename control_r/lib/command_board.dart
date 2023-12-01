import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial_ble/flutter_bluetooth_serial_ble.dart';

import 'continuous_widget.dart';
import 'notice_bar.dart';

class CommandBoard extends StatefulWidget {
  final BluetoothDevice server;

  const CommandBoard({super.key, required this.server});

  @override
  State<CommandBoard> createState() => _CommandBoardState();
}

class _CommandBoardState extends State<CommandBoard> {
  String dashBoardData = "No data";
  double sliderValue = 0.0;

  BluetoothConnection? connection;

  String _messageBuffer = '';

  final ScrollController listScrollController = ScrollController();

  bool isConnecting = true;
  bool get isConnected => (connection?.isConnected ?? false);

  bool isDisconnecting = false;

  @override
  void initState() {
    super.initState();

    BluetoothConnection.toAddress(widget.server.address).then((value) {
      Util.showToast('Connected to the device');
      connection = value;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection!.input!.listen(_onDataReceived).onDone(() {
        if (isDisconnecting) {
          Util.showToast('Disconnecting locally!');
        } else {
          Util.showToast('Disconnected remotely!');
        }
        if (mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      Util.showToast('Cannot connect, exception occured');
      Util.showToast(error);
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection?.dispose();
      connection = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final serverName = widget.server.name ?? "Unknown";
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Command Board"),
      ),
      body: SafeArea(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            isConnecting
                ? Text('Connecting to $serverName...')
                : isConnected
                    ? Text('Live with $serverName')
                    : Text('Log of $serverName'),
            Expanded(flex: 1, child: Center(child: Text(dashBoardData))),
            const Divider(),
            const Padding(
                padding: EdgeInsets.only(left: 16),
                child: Text('Control',
                    style: TextStyle(fontWeight: FontWeight.w200))),
            ContinuousWidget(sliderValue: sliderValue, sendCommand: _sendCommand),
            Text("${sliderValue.toInt().toString()} bit"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Slider(
                inactiveColor: Colors.grey,
                min: -255,
                max: 255,
                divisions: 255 * 2,
                value: sliderValue,
                label: sliderValue.toString(),
                onChanged: (value) {
                  setState(() {
                    sliderValue = value;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              child: ElevatedButton.icon(
                onPressed: () {
                  // Util.showToast("Pressed");
                  _sendCommand(sliderValue.toStringAsFixed(2));
                },
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Send'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    for (var byte in data) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    }
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }
    // Create a new message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    if (~index != 0) {
      setState(() {
        // Change the screen i.e. dashboard
        String str = backspacesCounter > 0
            ? _messageBuffer.substring(
                0, _messageBuffer.length - backspacesCounter)
            : _messageBuffer + dataString.substring(0, index);
        dashBoardData = "$str rpm at ";
        _messageBuffer = dataString.substring(index);
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
  }

  void _sendCommand(String text) async {
    // print("-------sendCommand----$text---------");
    text = text.trim();

    if (text.isNotEmpty) {
      try {
        connection!.output.add(Uint8List.fromList(utf8.encode("$text\n")));
        await connection!.output.allSent;

        Util.showToast(text);
      } catch (e) {
        // Ignore error, but notify state
        setState(() {});
      }
    }
  }
}
