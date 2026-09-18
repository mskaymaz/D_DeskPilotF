import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../domain/models/battery_model.dart';
import '../../application/providers/battery_provider.dart';
import '../../application/providers/module_settings_provider.dart';
import '../widgets/color_settings_dialog.dart';

class BatteryWindow extends ConsumerWidget {
  const BatteryWindow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batteryState = ref.watch(batteryNotifierProvider);
    final fontColor = ref.watch(batteryFontColorProvider);
    final settings = BatterySettings();

    void openColorSettings() {
      showColorSettingsDialog(
        context: context,
        current: fontColor,
        onSelected: (c) => ref.read(batteryFontColorProvider.notifier).state = c,
      );
    }

    if (!settings.visible) {
      return const SizedBox.shrink();
    }

    if (batteryState.isDesktop) {
      return GestureDetector(
        onSecondaryTap: openColorSettings,
        child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.desktop_windows,
            size: 36.0 * settings.scale,
            color: Colors.white70,
          ),
          const SizedBox(width: 8),
          Text(
            'Masaüstü',
            style: TextStyle(
              color: Colors.white70,
              shadows: const [
                Shadow(blurRadius: 6, color: Colors.black54, offset: Offset(0, 2)),
              ],
              fontSize: 32.0 * settings.scale,
            ),
          ),
          ],
        ),
      );
    }

    return GestureDetector(
      onSecondaryTap: openColorSettings,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '%${batteryState.percentage}',
            style: TextStyle(
              color: fontColor,
            shadows: const [
              Shadow(blurRadius: 6, color: Colors.black54, offset: Offset(0, 2)),
            ],
            fontWeight: settings.bold ? FontWeight.bold : FontWeight.normal,
            fontSize: 48.0 * settings.scale,
          ),
        ),
        const SizedBox(width: 8),
        if (settings.showIcon)
          _BatteryIcon(
            batteryState: batteryState,
            settings: settings,
          ),
        ],
      ),
    );
  }
}

class _BatteryIcon extends StatelessWidget {
  final BatteryState batteryState;
  final BatterySettings settings;

  const _BatteryIcon({
    required this.batteryState,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    final size = 48.0 * settings.scale;

    if (batteryState.isCharging) {
      return _buildChargingIcon(size);
    }

    return _buildLevelIcon(size);
  }

  Widget _buildChargingIcon(double size) {
    try {
      return SvgPicture.asset(
        'assets/images/lightning_icon.svg',
        width: size,
        height: size,
        colorFilter: const ColorFilter.mode(
          Color(0xFFFFC107),
          BlendMode.srcIn,
        ),
      );
    } catch (_) {
      return Icon(
        Icons.bolt,
        size: size,
        color: const Color(0xFFFFC107),
      );
    }
  }

  Widget _buildLevelIcon(double size) {
    final level = batteryState.percentage;
    IconData icon;
    Color color;

    if (level >= 90) {
      icon = Icons.battery_full;
      color = const Color(0xFF4CAF50);
    } else if (level >= 60) {
      icon = Icons.battery_5_bar;
      color = const Color(0xFF4CAF50);
    } else if (level >= 40) {
      icon = Icons.battery_4_bar;
      color = const Color(0xFFFFC107);
    } else if (level >= 20) {
      icon = Icons.battery_2_bar;
      color = const Color(0xFFFFC107);
    } else {
      icon = Icons.battery_alert;
      color = const Color(0xFFCF6679);
    }

    return Icon(icon, size: size, color: color);
  }
}
