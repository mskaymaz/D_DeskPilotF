import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:window_manager/window_manager.dart';
import 'core/design_tokens/design_tokens.dart';
import 'core/localization/app_localizations.dart';
import 'application/providers/clock_provider.dart';
import 'infrastructure/platform/clock_service_impl.dart';
import 'presentation/screens/clock_window.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  await windowManager.setBackgroundColor(AppColors.windowBackground);
  await windowManager.setOpacity(1.0);
  await windowManager.setAlwaysOnTop(true);
  await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
  await windowManager.setMinimumSize(AppSizing.windowMinSize);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(
    ProviderScope(
      overrides: [
        clockServiceProvider.overrideWithValue(ClockServiceImpl()),
      ],
      child: const DeskPilotApp(),
    ),
  );
}

class DeskPilotApp extends ConsumerWidget {
  const DeskPilotApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DeskPilotF',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ),
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
      home: DesktopSurface(),
    );
  }
}

class DesktopSurface extends ConsumerStatefulWidget {
  DesktopSurface({super.key});

  @override
  ConsumerState<DesktopSurface> createState() => _DesktopSurfaceState();
}

class _DesktopSurfaceState extends ConsumerState<DesktopSurface> {
  @override
  void initState() {
    super.initState();
    ref.read(clockNotifierProvider.notifier).start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ClockWindow(),
      ),
    );
  }
}
