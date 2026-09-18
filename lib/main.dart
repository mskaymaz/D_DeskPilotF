import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'core/localization/app_localizations.dart';
import 'application/providers/battery_provider.dart';
import 'application/providers/clock_provider.dart';
import 'application/providers/date_provider.dart';
import 'infrastructure/platform/battery_service_impl.dart';
import 'infrastructure/platform/clock_service_impl.dart';
import 'infrastructure/platform/date_service_impl.dart';
import 'presentation/screens/battery_window.dart';
import 'presentation/screens/clock_window.dart';
import 'presentation/screens/date_window.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  final wc = await WindowController.fromCurrentEngine();
  switch (wc.arguments) {
    case 'clock':
      runApp(const ClockModuleApp());
      break;
    case 'date':
      runApp(const DateModuleApp());
      break;
    case 'battery':
      runApp(const BatteryModuleApp());
      break;
    default:
      runApp(const ControllerApp());
  }
}

Future<void> _setupModuleWindow({
  required Size size,
  required Offset position,
}) async {
  await windowManager.setAsFrameless();
  await windowManager.setHasShadow(false);
  await windowManager.setResizable(false);
  await windowManager.setAlwaysOnTop(true);
  windowManager.waitUntilReadyToShow(
    WindowOptions(
      size: size,
      backgroundColor: Colors.transparent,
      skipTaskbar: true,
      titleBarStyle: TitleBarStyle.hidden,
    ),
    () async {
      await windowManager.setPosition(position);
      await windowManager.show();
    },
  );
}

MaterialApp _transparentApp(Widget home) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'DeskPilotF',
    theme: ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.transparent,
      useMaterial3: false,
    ),
    localizationsDelegates: [
      AppLocalizationsDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [
      Locale('tr', ''),
      Locale('en', ''),
    ],
    locale: const Locale('tr', ''),
    home: home,
  );
}

class _WindowDragArea extends StatelessWidget {
  final Widget child;

  const _WindowDragArea({required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (_) => windowManager.startDragging(),
      child: Container(
        color: Colors.transparent,
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}

class ClockModuleApp extends StatelessWidget {
  const ClockModuleApp({super.key});

  @override
  Widget build(BuildContext context) {
    _setupModuleWindow(
      size: const Size(400, 110),
      position: const Offset(140, 140),
    );
    return ProviderScope(
      overrides: [
        clockServiceProvider.overrideWithValue(ClockServiceImpl()),
      ],
      child: _transparentApp(const _ClockHost()),
    );
  }
}

class _ClockHost extends ConsumerStatefulWidget {
  const _ClockHost();

  @override
  ConsumerState<_ClockHost> createState() => _ClockHostState();
}

class _ClockHostState extends ConsumerState<_ClockHost> {
  @override
  void initState() {
    super.initState();
    ref.read(clockNotifierProvider.notifier).start();
  }

  @override
  Widget build(BuildContext context) {
    return const _WindowDragArea(child: ClockWindow());
  }
}

class DateModuleApp extends StatelessWidget {
  const DateModuleApp({super.key});

  @override
  Widget build(BuildContext context) {
    _setupModuleWindow(
      size: const Size(440, 110),
      position: const Offset(140, 270),
    );
    return ProviderScope(
      overrides: [
        dateServiceProvider.overrideWithValue(DateServiceImpl()),
      ],
      child: _transparentApp(const _DateHost()),
    );
  }
}

class _DateHost extends ConsumerStatefulWidget {
  const _DateHost();

  @override
  ConsumerState<_DateHost> createState() => _DateHostState();
}

class _DateHostState extends ConsumerState<_DateHost> {
  @override
  void initState() {
    super.initState();
    ref.read(dateNotifierProvider.notifier).start();
  }

  @override
  Widget build(BuildContext context) {
    return const _WindowDragArea(child: DateWindow());
  }
}

class BatteryModuleApp extends StatelessWidget {
  const BatteryModuleApp({super.key});

  @override
  Widget build(BuildContext context) {
    _setupModuleWindow(
      size: const Size(280, 110),
      position: const Offset(140, 400),
    );
    return ProviderScope(
      overrides: [
        batteryServiceProvider.overrideWithValue(BatteryServiceImpl()),
      ],
      child: _transparentApp(const _BatteryHost()),
    );
  }
}

class _BatteryHost extends ConsumerStatefulWidget {
  const _BatteryHost();

  @override
  ConsumerState<_BatteryHost> createState() => _BatteryHostState();
}

class _BatteryHostState extends ConsumerState<_BatteryHost> {
  @override
  void initState() {
    super.initState();
    ref.read(batteryNotifierProvider.notifier).start();
  }

  @override
  Widget build(BuildContext context) {
    return const _WindowDragArea(child: BatteryWindow());
  }
}

class ControllerApp extends StatefulWidget {
  const ControllerApp({super.key});

  @override
  State<ControllerApp> createState() => _ControllerAppState();
}

class _ControllerAppState extends State<ControllerApp> {
  @override
  void initState() {
    super.initState();
    _spawnModules();
  }

  Future<void> _spawnModules() async {
    final existing = await WindowController.getAll();
    final running = existing.map((e) => e.arguments).toSet();
    for (final arg in ['clock', 'date', 'battery']) {
      if (running.contains(arg)) continue;
      final controller = await WindowController.create(
        WindowConfiguration(hiddenAtLaunch: true, arguments: arg),
      );
      await controller.show();
    }
    await windowManager.hide();
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SizedBox.shrink(),
    );
  }
}
