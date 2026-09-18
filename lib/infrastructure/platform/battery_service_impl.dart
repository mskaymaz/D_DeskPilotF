import 'dart:async';
import 'dart:io';

import '../../domain/models/battery_model.dart';
import '../../domain/services/battery_service.dart';

class BatteryServiceImpl implements IBatteryService {
  Timer? _timer;
  final _controller = StreamController<BatteryState>.broadcast();

  @override
  Stream<BatteryState> get onStateChanged => _controller.stream;

  @override
  Future<void> start() async {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _tick());
    _tick();
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

  void _tick() {
    _controller.add(_queryBattery());
  }

  BatteryState _queryBattery() {
    try {
      final result = Process.runSync(
        'powershell',
        ['-NoProfile', '-Command', 'Get-WmiObject Win32_Battery | Select-Object EstimatedChargeRemaining, BatteryStatus, PowerOnline'],
        runInShell: true,
      );

      if (result.exitCode == 0 && result.stdout.isNotEmpty) {
        return _parseOutput(result.stdout.toString());
      }
    } catch (_) {}

    return BatteryState();
  }

  BatteryState _parseOutput(String output) {
    try {
      int percentage = 0;
      int batteryStatus = 0;
      bool powerOnline = false;

      for (var line in output.split('\n')) {
        if (line.contains('EstimatedChargeRemaining')) {
          final match = RegExp(r':\s*(\d+)').firstMatch(line);
          if (match != null) percentage = int.parse(match.group(1)!);
        }
        if (line.contains('BatteryStatus')) {
          final match = RegExp(r':\s*(\d+)').firstMatch(line);
          if (match != null) batteryStatus = int.parse(match.group(1)!);
        }
        if (line.contains('PowerOnline')) {
          final match = RegExp(r':\s*(true|True|TRUE|false|False|FALSE)').firstMatch(line);
          if (match != null) {
            powerOnline = match.group(1)!.toLowerCase() == 'true';
          }
        }
      }

      final status = _getStatus(batteryStatus);
      final isCharging = status == BatteryStatus.charging;
      final isPluggedIn = powerOnline || isCharging;
      final isLowBattery = percentage < 20;
      final isFullCharge = percentage >= 90;

      return BatteryState(
        percentage: percentage,
        status: status,
        isCharging: isCharging,
        isPluggedIn: isPluggedIn,
        isLowBattery: isLowBattery,
        isFullCharge: isFullCharge,
        isAvailable: true,
      );
    } catch (_) {
      return BatteryState();
    }
  }

  BatteryStatus _getStatus(int status) {
    switch (status) {
      case 1:
        return BatteryStatus.full;
      case 2:
        return BatteryStatus.low;
      case 3:
        return BatteryStatus.critical;
      case 4:
      case 7:
        return BatteryStatus.charging;
      case 5:
        return BatteryStatus.full;
      case 6:
        return BatteryStatus.low;
      case 8:
      default:
        return BatteryStatus.unknown;
    }
  }
}
