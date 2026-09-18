import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design_tokens/design_tokens.dart';
import '../../domain/models/clock_model.dart';
import '../../application/providers/clock_provider.dart';

class ClockWindow extends ConsumerWidget {
  ClockWindow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clockState = ref.watch(clockNotifierProvider);
    final settings = ClockSettings();

    return Center(
      child: Text(
        clockState.timeString,
        style: AppTypography.headlineMedium.copyWith(
          color: Color(settings.fontColor),
          fontWeight: settings.bold ? FontWeight.bold : FontWeight.normal,
          fontFamily: _fontFamily(settings.fontFamily),
          fontSize: 48.0 * settings.scale,
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
