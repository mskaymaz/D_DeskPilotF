import 'dart:async';

import 'package:flutter/services.dart';

import '../../domain/models/clock_model.dart';
import '../../domain/services/clock_service.dart';

class ClockServiceImpl implements IClockService {
  Timer? _timer;
  final _controller = StreamController<ClockState>.broadcast();

  @override
  Stream<ClockState> get onStateChanged => _controller.stream;

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
    final settings = ClockSettings();
    final timeString = _formatTime(now, settings);
    final dateString = _formatDate(now);
    return ClockState(timeString: timeString, dateString: dateString);
  }

  String _formatTime(DateTime date, ClockSettings settings) {
    if (settings.format == ClockFormat.h24) {
      if (settings.showSeconds) {
        return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}';
      }
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      final hour = date.hour % 12;
      final hour12 = hour == 0 ? 12 : hour;
      final period = date.hour < 12 ? 'AM' : 'PM';
      if (settings.showSeconds) {
        return '${hour12.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')} $period';
      }
      return '${hour12.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} $period';
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
