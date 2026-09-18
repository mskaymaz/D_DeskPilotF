import 'package:hijri/hijri_calendar.dart';

class HijriDate {
  final int year;
  final int month;
  final int day;

  const HijriDate(this.year, this.month, this.day);

  static const List<String> monthNames = [
    'Muharrem',
    'Safer',
    'Rebiülevvel',
    'Rebiülahir',
    'Cemaziyelevvel',
    'Cemaziyelahir',
    'Recep',
    'Şaban',
    'Ramazan',
    'Şevval',
    'Zilkade',
    'Zilhicce',
  ];

  static HijriDate fromGregorian(DateTime date) {
    HijriCalendar.language = 'tr';
    final hijri = HijriCalendar.fromDate(date);
    return HijriDate(hijri.hYear, hijri.hMonth, hijri.hDay);
  }

  String format() {
    if (month < 1 || month > 12) return '--';
    return '$day ${monthNames[month - 1]} $year';
  }

  String formatShort() {
    if (month < 1 || month > 12) return '--';
    return '$day ${monthNames[month - 1]}';
  }
}
