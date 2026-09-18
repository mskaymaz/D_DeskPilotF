import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design_tokens/design_tokens.dart';
import '../../domain/models/date_model.dart';
import '../../application/providers/date_provider.dart';

class DateWindow extends ConsumerWidget {
  const DateWindow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateState = ref.watch(dateNotifierProvider);
    final settings = DateSettings();

    if (!settings.visible) {
      return const SizedBox.shrink();
    }

    final isHijri = dateState.displayMode == DateDisplayMode.hijri;

    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            dateState.displayText,
            style: AppTypography.headlineMedium.copyWith(
              color: Color(settings.fontColor),
              fontWeight: settings.bold ? FontWeight.bold : FontWeight.normal,
              fontSize: 48.0 * settings.scale,
            ),
          ),
          const SizedBox(width: 12),
          _ToggleButton(
            label: isHijri ? 'M' : 'H',
            tooltip: isHijri ? 'Miladiye geç' : 'Hicri\'ye geç',
            onTap: () {
              ref.read(dateNotifierProvider.notifier).toggleDisplayMode();
            },
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final String tooltip;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
            border: Border.all(
              color: AppColors.primaryLight,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
