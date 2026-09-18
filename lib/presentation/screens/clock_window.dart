import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/clock_model.dart';
import '../../application/providers/clock_provider.dart';
import '../../application/providers/module_settings_provider.dart';
import '../widgets/color_settings_dialog.dart';

const _textShadow = [
  Shadow(blurRadius: 6, color: Colors.black54, offset: Offset(0, 2)),
];

class ClockWindow extends ConsumerWidget {
  const ClockWindow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clockState = ref.watch(clockNotifierProvider);
    final fontColor = ref.watch(clockFontColorProvider);
    final settings = ClockSettings();
    final is24 = settings.format == ClockFormat.h24;
    final baseFontSize = 48.0 * settings.scale;
    final periodFontSize = baseFontSize * 0.3;

    return GestureDetector(
      onTap: () {
        ref.read(clockNotifierProvider.notifier).toggleFormat();
      },
      onSecondaryTap: () {
        showColorSettingsDialog(
          context: context,
          current: fontColor,
          onSelected: (c) => ref.read(clockFontColorProvider.notifier).state = c,
        );
      },
      child: Tooltip(
        message: is24 ? '12 saat formatına geç' : '24 saat formatına geç',
        child: clockState.period.isEmpty
            ? Text(
                clockState.timeString,
                style: TextStyle(
                  color: fontColor,
                  shadows: _textShadow,
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
                    style: TextStyle(
                      color: fontColor,
                      shadows: _textShadow,
                      fontWeight: settings.bold ? FontWeight.bold : FontWeight.normal,
                      fontFamily: _fontFamily(settings.fontFamily),
                      fontSize: baseFontSize,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    clockState.period,
                    style: TextStyle(
                      color: fontColor.withOpacity(0.7),
                      shadows: _textShadow,
                      fontWeight: settings.bold ? FontWeight.bold : FontWeight.normal,
                      fontFamily: _fontFamily(settings.fontFamily),
                      fontSize: periodFontSize,
                    ),
                  ),
                ],
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
