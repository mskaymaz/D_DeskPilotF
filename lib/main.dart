import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';
import 'package:riverpod/riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  await windowManager.setBackgroundColor(Colors.transparent);
  await windowManager.setOpacity(1.0);
  await windowManager.setAlwaysOnTop(true);
  await windowManager.setTitleBarStyle(TitleBarStyle.hidden);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  final app = ProviderScope(child: DeskPilotApp());
  runApp(app);
}

class DeskPilotApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DeskPilotC',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.transparent,
        useMaterial3: true,
      ),
      home: DesktopSurface(),
    );
  }
}

class DesktopSurface extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Module windows will be positioned here
        // ClockWindow, DateWindow, BatteryWindow
        // TodoPanel, ReminderPanel
        // QuickActionsBar
      ],
    );
  }
}
