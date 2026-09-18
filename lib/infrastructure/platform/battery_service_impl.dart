import 'dart:async';
import 'dart:io';

import '../../domain/models/battery_model.dart';
import '../../domain/services/battery_service.dart';

class BatteryServiceImpl implements IBatteryService {
  Timer? _timer;
  final _controller = StreamController<BatteryState>.broadcast();
  bool _isDesktop = false;

  @override
  Stream<BatteryState> get onStateChanged => _controller.stream;

  @override
  Future<void> start() async {
    _timer?.cancel();
    await _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Future<BatteryState> getCurrentState() async {
    return _queryBattery();
  }

  Future<void> _tick() async {
    final state = await _queryBattery();
    _controller.add(state);
  }

  Future<BatteryState> _queryBattery() async {
    if (_isDesktop) {
      return const BatteryState(
        percentage: -1,
        status: BatteryStatus.unknown,
        isCharging: false,
        isPluggedIn: true,
        isLowBattery: false,
        isFullCharge: false,
        isAvailable: false,
      );
    }

    try {
      final result = await Process.run(
        'powershell',
        [
          '-NoProfile',
          '-Command',
          r'Get-WmiObject Win32_Battery | Select-Object EstimatedChargeRemaining, BatteryStatus, PowerOnline | Format-List',
        ],
      ).timeout(const Duration(seconds: 10));

      if (result.exitCode == 0 && result.stdout.toString().isNotEmpty) {
        final output = result.stdout.toString();
        if (output.contains('EstimatedChargeRemaining')) {
          return _parseOutput(output);
        }
      }
    } on TimeoutException {
      _isDesktop = true;
    } catch (_) {
      _isDesktop = true;
    }

    return const BatteryState(
      percentage: -1,
      status: BatteryStatus.unknown,
      isCharging: false,
      isPluggedIn: true,
      isLowBattery: false,
      isFullCharge: false,
      isAvailable: false,
    );
  }

  BatteryState _parseOutput(String output) {
    try {
      int percentage = 0;
      int batteryStatus = 0;
      bool powerOnline = false;

      for (var line in output.split('\n')) {
        final trimmed = line.trim();
        if (trimmed.startsWith('EstimatedChargeRemaining')) {
          final match = RegExp(r':\s*(\d+)').firstMatch(trimmed);
          if (match != null) percentage = int.parse(match.group(1)!);
        }
        if (trimmed.startsWith('BatteryStatus')) {
          final match = RegExp(r':\s*(\d+)').firstMatch(trimmed);
          if (match != null) batteryStatus = int.parse(match.group(1)!);
        }
        if (trimmed.startsWith('PowerOnline')) {
          final match = RegExp(r':\s*(True|False|true|false)').firstMatch(trimmed);
          if (match != null) {
            powerOnline = match.group(1)!.toLowerCase() == 'true';
          }
        }
      }

      final isCharging = batteryStatus >= 2 && batteryStatus <= 9;
      final isPluggedIn = powerOnline || isCharging;
      final isLowBattery = percentage < 20;
      final isFullCharge = percentage >= 90;

      return BatteryState(
        percentage: percentage,
        status: _getStatus(batteryStatus),
        isCharging: isCharging,
        isPluggedIn: isPluggedIn,
        isLowBattery: isLowBattery,
        isFullCharge: isFullCharge,
        isAvailable: true,
      );
    } catch (_) {
      return const BatteryState(
        percentage: -1,
        isAvailable: false,
      );
    }
  }

  BatteryStatus _getStatus(int status) {
    switch (status) {
      case 3:
        return BatteryStatus.full;
      case 4:
      case 5:
      case 9:
        return BatteryStatus.low;
      case 6:
      case 7:
      case 8:
        return BatteryStatus.charging;
      case 2:
        return BatteryStatus.charging;
      case 1:
      default:
        return BatteryStatus.discharging;
    }
  }
}
