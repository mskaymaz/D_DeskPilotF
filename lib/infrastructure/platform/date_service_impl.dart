import 'dart:async';

import 'package:intl/intl.dart';

import '../../domain/models/date_model.dart';
import '../../domain/services/date_service.dart';
import 'hijri_date.dart';

class DateServiceImpl implements IDateService {
  Timer? _timer;
  final _controller = StreamController<DateState>.broadcast();

  @override
  Stream<DateState> get onStateChanged => _controller.stream;

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
  Future<DateState> getCurrentState() async {
    return _buildState();
  }

  void _tick() {
    _controller.add(_buildState());
  }

  DateState _buildState() {
    try {
      final now = DateTime.now();
      final settings = DateSettings();
      return DateState(
        gregorianDate: _formatGregorian(now, settings),
        hijriDate: _formatHijri(now),
        combinedDate: _formatCombined(now, settings),
        weekNumber: _getWeekNumber(now),
      );
    } catch (_) {
      return const DateState(
        gregorianDate: '--',
        hijriDate: '--',
        combinedDate: '--',
        weekNumber: '--',
      );
    }
  }

  String _formatGregorian(DateTime date, DateSettings settings) {
    String pattern;
    switch (settings.format) {
      case DateFormatType.dotted:
        pattern = 'dd.MM.yyyy';
        break;
      case DateFormatType.slash:
        pattern = 'dd/MM/yyyy';
        break;
      case DateFormatType.iso:
        pattern = 'yyyy-MM-dd';
        break;
    }
    return DateFormat(pattern, 'tr_TR').format(date);
  }

  String _formatHijri(DateTime date) {
    try {
      final hijri = HijriDate.fromGregorian(date);
      return hijri.format();
    } catch (_) {
      return '--';
    }
  }

  String _formatCombined(DateTime date, DateSettings settings) {
    final gregorian = _formatGregorian(date, settings);
    final hijri = _formatHijri(date);

    if (settings.order == DateOrder.gregorianFirst) {
      return '$gregorian — $hijri';
    }
    return '$hijri — $gregorian';
  }

  String _getWeekNumber(DateTime date) {
    final jan4 = DateTime(date.year, 1, 4);
    final offset = (jan4.weekday - 1);
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays + 1;
    final weekNum = ((dayOfYear + offset - 1) / 7).ceil();
    return 'H${weekNum.toString().padLeft(2, '0')}';
  }
}
