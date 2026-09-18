enum BatteryStatus { charging, discharging, full, low, critical, unknown }

class BatterySettings {
  final bool visible;
  final bool showIcon;
  final String fontFamily;
  final int fontColor;
  final bool bold;
  final double scale;
  final int lowBatteryThreshold;
  final int fullChargeThreshold;
  final bool alertEnabled;
  final int alertInterval;
  final bool silentMode;

  const BatterySettings({
    this.visible = true,
    this.showIcon = true,
    this.fontFamily = 'Inter',
    this.fontColor = 0xFFFFFFFF,
    this.bold = false,
    this.scale = 1.0,
    this.lowBatteryThreshold = 20,
    this.fullChargeThreshold = 90,
    this.alertEnabled = true,
    this.alertInterval = 30,
    this.silentMode = false,
  });

  BatterySettings copyWith({
    bool? visible,
    bool? showIcon,
    String? fontFamily,
    int? fontColor,
    bool? bold,
    double? scale,
    int? lowBatteryThreshold,
    int? fullChargeThreshold,
    bool? alertEnabled,
    int? alertInterval,
    bool? silentMode,
  }) {
    return BatterySettings(
      visible: visible ?? this.visible,
      showIcon: showIcon ?? this.showIcon,
      fontFamily: fontFamily ?? this.fontFamily,
      fontColor: fontColor ?? this.fontColor,
      bold: bold ?? this.bold,
      scale: scale ?? this.scale,
      lowBatteryThreshold: lowBatteryThreshold ?? this.lowBatteryThreshold,
      fullChargeThreshold: fullChargeThreshold ?? this.fullChargeThreshold,
      alertEnabled: alertEnabled ?? this.alertEnabled,
      alertInterval: alertInterval ?? this.alertInterval,
      silentMode: silentMode ?? this.silentMode,
    );
  }

  Map<String, dynamic> toJson() => {
        'visible': visible,
        'showIcon': showIcon,
        'fontFamily': fontFamily,
        'fontColor': fontColor.toRadixString(16).padLeft(8, '0'),
        'bold': bold,
        'scale': scale,
        'lowBatteryThreshold': lowBatteryThreshold,
        'fullChargeThreshold': fullChargeThreshold,
        'alertEnabled': alertEnabled,
        'alertInterval': alertInterval,
        'silentMode': silentMode,
      };

  static BatterySettings fromJson(Map<String, dynamic> json) => BatterySettings(
        visible: json['visible'] as bool? ?? true,
        showIcon: json['showIcon'] as bool? ?? true,
        fontFamily: json['fontFamily'] as String? ?? 'Inter',
        fontColor: int.parse(json['fontColor'] as String? ?? 'FFFFFFFF', radix: 16),
        bold: json['bold'] as bool? ?? false,
        scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
        lowBatteryThreshold: json['lowBatteryThreshold'] as int? ?? 20,
        fullChargeThreshold: json['fullChargeThreshold'] as int? ?? 90,
        alertEnabled: json['alertEnabled'] as bool? ?? true,
        alertInterval: json['alertInterval'] as int? ?? 30,
        silentMode: json['silentMode'] as bool? ?? false,
      );
}

class BatteryState {
  final int percentage;
  final BatteryStatus status;
  final bool isCharging;
  final bool isPluggedIn;
  final bool isLowBattery;
  final bool isFullCharge;
  final bool isAvailable;
  final bool silentMode;

  const BatteryState({
    this.percentage = 0,
    this.status = BatteryStatus.unknown,
    this.isCharging = false,
    this.isPluggedIn = false,
    this.isLowBattery = false,
    this.isFullCharge = false,
    this.isAvailable = true,
    this.silentMode = false,
  });

  bool get isDesktop => !isAvailable || percentage < 0;

  BatteryState copyWith({
    int? percentage,
    BatteryStatus? status,
    bool? isCharging,
    bool? isPluggedIn,
    bool? isLowBattery,
    bool? isFullCharge,
    bool? isAvailable,
    bool? silentMode,
  }) {
    return BatteryState(
      percentage: percentage ?? this.percentage,
      status: status ?? this.status,
      isCharging: isCharging ?? this.isCharging,
      isPluggedIn: isPluggedIn ?? this.isPluggedIn,
      isLowBattery: isLowBattery ?? this.isLowBattery,
      isFullCharge: isFullCharge ?? this.isFullCharge,
      isAvailable: isAvailable ?? this.isAvailable,
      silentMode: silentMode ?? this.silentMode,
    );
  }
}
