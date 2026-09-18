import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';

import '../../domain/models/battery_model.dart';
import '../../domain/services/battery_service.dart';

class BatteryNotifier extends StateNotifier<BatteryState> {
  final IBatteryService _batteryService;
  StreamSubscription<BatteryState>? _subscription;

  BatteryNotifier(this._batteryService) : super(const BatteryState()) {
    _subscribe();
  }

  void _subscribe() {
    _subscription = _batteryService.onStateChanged.listen((newState) {
      state = newState as BatteryState;
    });
  }

  Future<void> start() async {
    await _batteryService.start();
    _subscribe();
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    await _batteryService.stop();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _batteryService.stop();
    super.dispose();
  }
}

final batteryServiceProvider = Provider<IBatteryService>((ref) {
  throw UnimplementedError('IBatteryService must be provided');
});

final batteryNotifierProvider = StateNotifierProvider<BatteryNotifier, BatteryState>((ref) {
  final service = ref.read(batteryServiceProvider);
  return BatteryNotifier(service);
});
