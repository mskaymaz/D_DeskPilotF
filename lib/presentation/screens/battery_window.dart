import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_tokens/design_tokens.dart';
import '../../domain/models/battery_model.dart';
import '../../application/providers/battery_provider.dart';

class BatteryWindow extends ConsumerWidget {
  BatteryWindow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batteryState = ref.watch(batteryNotifierProvider);
    final settings = BatterySettings();

    if (!settings.visible || !batteryState.isAvailable) {
      return const SizedBox.shrink();
    }

    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${batteryState.percentage}%',
            style: AppTypography.headlineMedium.copyWith(
              color: Color(settings.fontColor),
              fontWeight: settings.bold ? FontWeight.bold : FontWeight.normal,
              fontSize: 48.0 * settings.scale,
            ),
          ),
          const SizedBox(width: 8),
          if (settings.showIcon && batteryState.isCharging)
            SvgPicture.asset(
              'assets/images/lightning_icon.svg',
              width: 48.0 * settings.scale,
              height: 48.0 * settings.scale,
              colorFilter: ColorFilter.mode(
                batteryState.silentMode
                    ? const Color(0xFF666666)
                    : AppColors.primary,
                BlendMode.srcIn,
              ),
            ),
        ],
      ),
    );
  }
}
