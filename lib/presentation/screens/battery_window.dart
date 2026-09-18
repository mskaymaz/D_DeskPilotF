import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_tokens/design_tokens.dart';
import '../../domain/models/battery_model.dart';
import '../../application/providers/battery_provider.dart';

class BatteryWindow extends ConsumerWidget {
  const BatteryWindow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batteryState = ref.watch(batteryNotifierProvider);
    final settings = BatterySettings();

    if (!settings.visible) {
      return const SizedBox.shrink();
    }

    if (batteryState.isDesktop) {
      return Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.desktop_windows,
              size: 36.0 * settings.scale,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              'Masaüstü',
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.textSecondary,
                fontSize: 32.0 * settings.scale,
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '%${batteryState.percentage}',
            style: AppTypography.headlineMedium.copyWith(
              color: _getBatteryColor(batteryState),
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

  Color _getBatteryColor(BatteryState state) {
    if (state.isLowBattery) return AppColors.error;
    if (state.isFullCharge) return AppColors.success;
    return AppColors.textPrimary;
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
        colorFilter: ColorFilter.mode(
          AppColors.warning,
          BlendMode.srcIn,
        ),
      );
    } catch (_) {
      return Icon(
        Icons.bolt,
        size: size,
        color: AppColors.warning,
      );
    }
  }

  Widget _buildLevelIcon(double size) {
    final level = batteryState.percentage;
    IconData icon;
    Color color;

    if (level >= 90) {
      icon = Icons.battery_full;
      color = AppColors.success;
    } else if (level >= 60) {
      icon = Icons.battery_5_bar;
      color = AppColors.success;
    } else if (level >= 40) {
      icon = Icons.battery_4_bar;
      color = AppColors.warning;
    } else if (level >= 20) {
      icon = Icons.battery_2_bar;
      color = AppColors.warning;
    } else {
      icon = Icons.battery_alert;
      color = AppColors.error;
    }

    return Icon(icon, size: size, color: color);
  }
}
