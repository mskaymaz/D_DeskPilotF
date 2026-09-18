import 'dart:async';

import '../models/clock_model.dart';

abstract class IClockService {
  Stream<ClockState> get onStateChanged;
  Future<void> start();
  Future<void> stop();
  Future<ClockState> getCurrentState();
}
