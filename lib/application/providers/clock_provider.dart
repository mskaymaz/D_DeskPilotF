import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';

import '../../domain/models/clock_model.dart';
import '../../domain/services/clock_service.dart';

class ClockNotifier extends StateNotifier<ClockState> {
  final IClockService _clockService;
  StreamSubscription<ClockState>? _subscription;

  ClockNotifier(this._clockService) : super(const ClockState()) {
    _subscribe();
  }

  void _subscribe() {
    _subscription = _clockService.onStateChanged.listen((newState) {
      state = newState as ClockState;
    });
  }

  Future<void> start() async {
    await _clockService.start();
    _subscribe();
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    await _clockService.stop();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _clockService.stop();
    super.dispose();
  }
}

final clockServiceProvider = Provider<IClockService>((ref) {
  throw UnimplementedError('IClockService must be provided');
});

final clockNotifierProvider = StateNotifierProvider<ClockNotifier, ClockState>((ref) {
  final service = ref.read(clockServiceProvider);
  return ClockNotifier(service);
});
