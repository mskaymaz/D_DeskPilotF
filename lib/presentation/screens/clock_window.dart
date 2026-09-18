import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design_tokens/design_tokens.dart';
import '../../domain/models/clock_model.dart';
import '../../application/providers/clock_provider.dart';

class ClockWindow extends ConsumerWidget {
  const ClockWindow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clockState = ref.watch(clockNotifierProvider);
    final settings = ClockSettings();
    final is24 = settings.format == ClockFormat.h24;
    final baseFontSize = 48.0 * settings.scale;
    final periodFontSize = baseFontSize * 0.3;

    return Center(
      child: GestureDetector(
        onTap: () {
          ref.read(clockNotifierProvider.notifier).toggleFormat();
        },
        child: Tooltip(
          message: is24 ? '12 saat formatına geç' : '24 saat formatına geç',
          child: clockState.period.isEmpty
              ? Text(
                  clockState.timeString,
                  style: AppTypography.headlineMedium.copyWith(
                    color: Color(settings.fontColor),
                    fontWeight: settings.bold ? FontWeight.bold : FontWeight.normal,
                    fontFamily: _fontFamily(settings.fontFamily),
                    fontSize: baseFontSize,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      clockState.timeString,
                      style: AppTypography.headlineMedium.copyWith(
                        color: Color(settings.fontColor),
                        fontWeight: settings.bold ? FontWeight.bold : FontWeight.normal,
                        fontFamily: _fontFamily(settings.fontFamily),
                        fontSize: baseFontSize,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      clockState.period,
                      style: AppTypography.headlineMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: settings.bold ? FontWeight.bold : FontWeight.normal,
                        fontFamily: _fontFamily(settings.fontFamily),
                        fontSize: periodFontSize,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  String? _fontFamily(ClockFontFamily family) {
    switch (family) {
      case ClockFontFamily.stencil:
        return 'Stencil';
      case ClockFontFamily.digital7:
        return 'Digital-7';
      case ClockFontFamily.dsDigital:
        return 'DS-Digital';
      case ClockFontFamily.technology:
        return 'Technology';
      case ClockFontFamily.system:
      default:
        return null;
    }
  }
}
