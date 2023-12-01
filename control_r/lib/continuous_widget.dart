import 'dart:async';

import 'package:flutter/material.dart';

class ContinuousWidget extends StatefulWidget {
  double sliderValue;
  final Function sendCommand;
  ContinuousWidget(
      {super.key, required this.sliderValue, required this.sendCommand});

  @override
  State<ContinuousWidget> createState() => _ContinuousWidgetState();
}

class _ContinuousWidgetState extends State<ContinuousWidget> {
  bool isToggledOn = false;
  // A function to print the value and increment it by one
  void printValue() {
    print(widget.sliderValue);
    widget.sendCommand(widget.sliderValue.toString());
  }

  // Create a timer that runs the printValue function every 0.5 second
  late Timer timer;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: const Text('Continuous'),
      value: isToggledOn,
      onChanged: (bool value) {
        setState(() {
          isToggledOn = value;
          if (value) {
            // If true, create a new timer
            timer = Timer.periodic(
                const Duration(milliseconds: 500), (t) => printValue());
          } else {
            // If false, cancel the existing timer
            timer.cancel();
            print('Printing stopped');
          }
        });
      },
    );
  }
}
