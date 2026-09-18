import 'dart:async';

import '../models/battery_model.dart';

abstract class IBatteryService {
  Stream<BatteryState> get onStateChanged;
  Future<void> start();
  Future<void> stop();
  Future<BatteryState> getCurrentState();
}
