import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/clock_model.dart';
import '../../domain/services/clock_service.dart';
import '../../infrastructure/platform/clock_service_impl.dart';

class ClockNotifier extends StateNotifier<ClockState> {
  final ClockServiceImpl _clockService;
  StreamSubscription<ClockState>? _subscription;

  ClockNotifier(this._clockService) : super(const ClockState()) {
    _subscribe();
  }

  void _subscribe() {
    _subscription = _clockService.onStateChanged.listen((newState) {
      state = newState;
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

  void toggleFormat() {
    final newFormat = _clockService.format == ClockFormat.h24
        ? ClockFormat.h12
        : ClockFormat.h24;
    _clockService.setFormat(newFormat);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _clockService.stop();
    super.dispose();
  }
}

final clockServiceProvider = Provider<ClockServiceImpl>((ref) {
  throw UnimplementedError('IClockService must be provided');
});

final clockNotifierProvider = StateNotifierProvider<ClockNotifier, ClockState>((ref) {
  final service = ref.read(clockServiceProvider);
  return ClockNotifier(service);
});
