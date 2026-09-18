enum DateFormatType { dotted, slash, iso }

enum DateOrder { gregorianFirst, hijriFirst }

enum DateDisplayMode { gregorian, hijri, combined }

class DateSettings {
  final DateFormatType format;
  final DateOrder order;
  final bool showWeekNumber;
  final bool showGregorian;
  final bool showHijriOnly;
  final String fontFamily;
  final int fontColor;
  final bool bold;
  final double scale;
  final bool visible;

  const DateSettings({
    this.format = DateFormatType.dotted,
    this.order = DateOrder.gregorianFirst,
    this.showWeekNumber = false,
    this.showGregorian = true,
    this.showHijriOnly = false,
    this.fontFamily = 'Inter',
    this.fontColor = 0xFFFFFFFF,
    this.bold = false,
    this.scale = 1.0,
    this.visible = true,
  });

  DateSettings copyWith({
    DateFormatType? format,
    DateOrder? order,
    bool? showWeekNumber,
    bool? showGregorian,
    bool? showHijriOnly,
    String? fontFamily,
    int? fontColor,
    bool? bold,
    double? scale,
    bool? visible,
  }) {
    return DateSettings(
      format: format ?? this.format,
      order: order ?? this.order,
      showWeekNumber: showWeekNumber ?? this.showWeekNumber,
      showGregorian: showGregorian ?? this.showGregorian,
      showHijriOnly: showHijriOnly ?? this.showHijriOnly,
      fontFamily: fontFamily ?? this.fontFamily,
      fontColor: fontColor ?? this.fontColor,
      bold: bold ?? this.bold,
      scale: scale ?? this.scale,
      visible: visible ?? this.visible,
    );
  }

  Map<String, dynamic> toJson() => {
        'format': format.index,
        'order': order.index,
        'showWeekNumber': showWeekNumber,
        'showGregorian': showGregorian,
        'showHijriOnly': showHijriOnly,
        'fontFamily': fontFamily,
        'fontColor': fontColor.toRadixString(16).padLeft(8, '0'),
        'bold': bold,
        'scale': scale,
        'visible': visible,
      };

  static DateSettings fromJson(Map<String, dynamic> json) => DateSettings(
        format: DateFormatType.values[json['format'] as int? ?? 0],
        order: DateOrder.values[json['order'] as int? ?? 0],
        showWeekNumber: json['showWeekNumber'] as bool? ?? false,
        showGregorian: json['showGregorian'] as bool? ?? true,
        showHijriOnly: json['showHijriOnly'] as bool? ?? false,
        fontFamily: json['fontFamily'] as String? ?? 'Inter',
        fontColor: int.parse(json['fontColor'] as String? ?? 'FFFFFFFF', radix: 16),
        bold: json['bold'] as bool? ?? false,
        scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
        visible: json['visible'] as bool? ?? true,
      );
}

class DateState {
  final String gregorianDate;
  final String hijriDate;
  final String combinedDate;
  final String weekNumber;
  final DateDisplayMode displayMode;
  final bool isLoading;

  const DateState({
    this.gregorianDate = '',
    this.hijriDate = '',
    this.combinedDate = '',
    this.weekNumber = '',
    this.displayMode = DateDisplayMode.gregorian,
    this.isLoading = false,
  });

  DateState copyWith({
    String? gregorianDate,
    String? hijriDate,
    String? combinedDate,
    String? weekNumber,
    DateDisplayMode? displayMode,
    bool? isLoading,
  }) {
    return DateState(
      gregorianDate: gregorianDate ?? this.gregorianDate,
      hijriDate: hijriDate ?? this.hijriDate,
      combinedDate: combinedDate ?? this.combinedDate,
      weekNumber: weekNumber ?? this.weekNumber,
      displayMode: displayMode ?? this.displayMode,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  String get displayText {
    switch (displayMode) {
      case DateDisplayMode.gregorian:
        return gregorianDate;
      case DateDisplayMode.hijri:
        return hijriDate;
      case DateDisplayMode.combined:
        return combinedDate;
    }
  }
}
