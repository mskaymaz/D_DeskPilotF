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
      state = newState.copyWith(displayMode: state.displayMode);
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

  void toggleDisplayMode() {
    switch (state.displayMode) {
      case DateDisplayMode.gregorian:
        state = state.copyWith(displayMode: DateDisplayMode.hijri);
        break;
      case DateDisplayMode.hijri:
        state = state.copyWith(displayMode: DateDisplayMode.gregorian);
        break;
      case DateDisplayMode.combined:
        state = state.copyWith(displayMode: DateDisplayMode.gregorian);
        break;
    }
  }

  void setDisplayMode(DateDisplayMode mode) {
    state = state.copyWith(displayMode: mode);
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
