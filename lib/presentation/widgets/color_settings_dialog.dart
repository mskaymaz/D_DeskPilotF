import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';

const _presetColors = [
  Colors.white,
  Colors.black,
  Colors.red,
  Colors.green,
  Colors.blue,
  Colors.yellow,
  Colors.orange,
  Colors.purple,
  Colors.cyan,
  Colors.pink,
];

Future<void> showColorSettingsDialog({
  required BuildContext context,
  required Color current,
  required ValueChanged<Color> onSelected,
}) {
  final tr = AppLocalizations.of(context)?.tr ?? (String key) => key;
  return showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        title: Text(
          tr('settings'),
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        content: SizedBox(
          width: 260,
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final color in _presetColors)
                GestureDetector(
                  onTap: () {
                    onSelected(color);
                    Navigator.of(dialogContext).pop();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                      border: Border.all(
                        color: color == current ? Colors.white : Colors.white24,
                        width: color == current ? 3 : 1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => exit(0),
            child: Text(tr('exit_app'), style: const TextStyle(color: Colors.redAccent)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(tr('close'), style: const TextStyle(color: Colors.white70)),
          ),
        ],
      );
    },
  );
}
