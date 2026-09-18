import 'dart:async';

import '../models/date_model.dart';

abstract class IDateService {
  Stream<DateState> get onStateChanged;
  Future<void> start();
  Future<void> stop();
  Future<DateState> getCurrentState();
}
