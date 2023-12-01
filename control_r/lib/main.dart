import 'package:control_r/front_page.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

ThemeData kdarkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(),
);

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      darkTheme: kdarkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const FrontPage());
  }
}


