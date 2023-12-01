import 'dart:async';

import 'package:control_r/notice_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial_ble/flutter_bluetooth_serial_ble.dart';

import 'command_board.dart';
import 'select_bonded_device_page.dart';

class FrontPage extends StatefulWidget {
  const FrontPage({super.key});

  @override
  State<FrontPage> createState() => _FrontPageState();
}

class _FrontPageState extends State<FrontPage> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;


  @override
  void initState() {
    super.initState();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    Future.doWhile(() async {
      // Wait if adapter not enabled
      if ((await FlutterBluetoothSerial.instance.isEnabled) ?? false) {
        return false;
      }
      await Future.delayed(const Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {
    });

    // Listen for futher state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
      });
    });
  }

  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 360,
        title: const Text('Control_R', style: TextStyle(fontSize: 34)),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          const Divider(),
          const Padding(
              padding: EdgeInsets.only(left: 16),
              child: Text('General',
                  style: TextStyle(fontWeight: FontWeight.w200))),
          SwitchListTile(
            title: const Text('Enable Bluetooth'),
            value: _bluetoothState.isEnabled,
            onChanged: (bool value) {
              // Do the request and update with the true value then
              future() async {
                // async lambda seems to not working
                if (value) {
                  await FlutterBluetoothSerial.instance.requestEnable();
                } else {
                  await FlutterBluetoothSerial.instance.requestDisable();
                }
              }

              future().then((_) {
                setState(() {});
              });
            },
          ),
          ListTile(
            title: const Text('Bluetooth status'),
            subtitle: Text(_bluetoothState.toString()),
            trailing: ElevatedButton.icon(
              icon: const Icon(Icons.settings),
              label: const Text('Settings'),
              onPressed: () {
                FlutterBluetoothSerial.instance.openSettings();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.bluetooth_connected),
              label: const Text('Connect to paired device'),
              onPressed: () async {
                final BluetoothDevice? selectedDevice =
                    await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return const SelectBondedDevicePage(
                          checkAvailability: false);
                    },
                  ),
                );
            
                if (selectedDevice != null) {
                  Util.showToast('Connect -> selected $selectedDevice.address');
                  _startCommandBoard(selectedDevice);
                } else {
                  Util.showToast('Connect -> no device selected');
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _startCommandBoard(BluetoothDevice server) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return CommandBoard(server: server);
        },
      ),
    );
  }
}
