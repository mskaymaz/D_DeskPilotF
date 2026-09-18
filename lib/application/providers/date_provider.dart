import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';

import '../../domain/models/date_model.dart';
import '../../domain/services/date_service.dart';

class DateNotifier extends StateNotifier<DateState> {
  final IDateService _dateService;
  StreamSubscription<DateState>? _subscription;

  DateNotifier(this._dateService) : super(const DateState()) {
    _subscribe();
  }

  void _subscribe() {
    _subscription = _dateService.onStateChanged.listen((newState) {
      state = newState as DateState;
    });
  }

  Future<void> start() async {
    await _dateService.start();
    _subscribe();
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    await _dateService.stop();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _dateService.stop();
    super.dispose();
  }
}

final dateServiceProvider = Provider<IDateService>((ref) {
  throw UnimplementedError('IDateService must be provided');
});

final dateNotifierProvider = StateNotifierProvider<DateNotifier, DateState>((ref) {
  final service = ref.read(dateServiceProvider);
  return DateNotifier(service);
});
