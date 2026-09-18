import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  await windowManager.setBackgroundColor(Colors.transparent);
  await windowManager.setOpacity(1.0);
  await windowManager.setAlwaysOnTop(true);
  await windowManager.setTitleBarStyle(TitleBarStyle.hidden);

  await windowManager.setMinimumSize(const Size(800, 600));

  runApp(const DeskPilotApp());
}

class DeskPilotApp extends StatelessWidget {
  const DeskPilotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DeskPilotF',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.transparent,
        useMaterial3: true,
      ),
      home: const DesktopSurface(),
    );
  }
}

class DesktopSurface extends StatelessWidget {
  const DesktopSurface({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Text(
          'DeskPilotF',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
    );
  }
}
