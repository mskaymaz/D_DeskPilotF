import 'dart:async';

import '../../domain/models/clock_model.dart';
import '../../domain/services/clock_service.dart';

class ClockServiceImpl implements IClockService {
  Timer? _timer;
  final _controller = StreamController<ClockState>.broadcast();
  ClockFormat _format = ClockFormat.h24;

  @override
  Stream<ClockState> get onStateChanged => _controller.stream;

  void setFormat(ClockFormat format) {
    _format = format;
    _tick();
  }

  ClockFormat get format => _format;

  @override
  Future<void> start() async {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    _tick();
  }

  @override
  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Future<ClockState> getCurrentState() async {
    return _buildState();
  }

  void _tick() {
    _controller.add(_buildState());
  }

  ClockState _buildState() {
    final now = DateTime.now();
    final result = _formatTime(now);
    return ClockState(timeString: result.$1, period: result.$2);
  }

  (String, String) _formatTime(DateTime date) {
    if (_format == ClockFormat.h24) {
      return ('${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}', '');
    } else {
      final hour = date.hour % 12;
      final hour12 = hour == 0 ? 12 : hour;
      final period = date.hour < 12 ? 'AM' : 'PM';
      return ('${hour12.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}', period);
    }
  }
}
