import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design_tokens/design_tokens.dart';
import '../../domain/models/date_model.dart';
import '../../application/providers/date_provider.dart';

class DateWindow extends ConsumerWidget {
  DateWindow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateState = ref.watch(dateNotifierProvider);
    final settings = DateSettings();

    if (!settings.visible) {
      return const SizedBox.shrink();
    }

    return Center(
      child: Text(
        settings.showHijriOnly
            ? dateState.hijriDate
            : settings.showHijri
                ? dateState.combinedDate
                : dateState.gregorianDate,
        style: AppTypography.headlineMedium.copyWith(
          color: Color(settings.fontColor),
          fontWeight: settings.bold ? FontWeight.bold : FontWeight.normal,
          fontSize: 48.0 * settings.scale,
        ),
      ),
    );
  }
}
