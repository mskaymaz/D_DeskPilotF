enum ClockFormat { h12, h24 }

enum ClockFontFamily {
  system,
  stencil,
  digital7,
  dsDigital,
  technology,
}

class ClockSettings {
  final ClockFormat format;
  final bool showSeconds;
  final ClockFontFamily fontFamily;
  final int fontColor;
  final bool bold;
  final double scale;

  const ClockSettings({
    this.format = ClockFormat.h24,
    this.showSeconds = true,
    this.fontFamily = ClockFontFamily.system,
    this.fontColor = 0xFFFFFFFF,
    this.bold = false,
    this.scale = 1.0,
  });

  ClockSettings copyWith({
    ClockFormat? format,
    bool? showSeconds,
    ClockFontFamily? fontFamily,
    int? fontColor,
    bool? bold,
    double? scale,
  }) {
    return ClockSettings(
      format: format ?? this.format,
      showSeconds: showSeconds ?? this.showSeconds,
      fontFamily: fontFamily ?? this.fontFamily,
      fontColor: fontColor ?? this.fontColor,
      bold: bold ?? this.bold,
      scale: scale ?? this.scale,
    );
  }

  Map<String, dynamic> toJson() => {
        'format': format.index,
        'showSeconds': showSeconds,
        'fontFamily': fontFamily.index,
        'fontColor': fontColor.toRadixString(16).padLeft(8, '0'),
        'bold': bold,
        'scale': scale,
      };

  static ClockSettings fromJson(Map<String, dynamic> json) => ClockSettings(
        format: ClockFormat.values[json['format'] as int? ?? 0],
        showSeconds: json['showSeconds'] as bool? ?? true,
        fontFamily: ClockFontFamily.values[json['fontFamily'] as int? ?? 0],
        fontColor: int.parse(json['fontColor'] as String? ?? 'FFFFFFFF', radix: 16),
        bold: json['bold'] as bool? ?? false,
        scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
      );
}

class ClockState {
  final String timeString;
  final String dateString;
  final bool isLoading;

  const ClockState({
    this.timeString = '00:00:00',
    this.dateString = '',
    this.isLoading = false,
  });

  ClockState copyWith({
    String? timeString,
    String? dateString,
    bool? isLoading,
  }) {
    return ClockState(
      timeString: timeString ?? this.timeString,
      dateString: dateString ?? this.dateString,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
