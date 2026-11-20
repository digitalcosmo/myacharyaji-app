import 'package:intl/intl.dart';

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Calendar-safe day arithmetic (immune to DST shifts).
DateTime addDays(DateTime d, int n) => DateTime(d.year, d.month, d.day + n);

DateTime mondayOf(DateTime d) => addDays(dateOnly(d), -(d.weekday - 1));

bool sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

bool sameMonth(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month;

DateTime today() => dateOnly(DateTime.now());

/// ISO-8601 week number and week-year. The week belongs to the year that
/// contains its Thursday, so 29 Dec 2025 is week 1 of 2026.
({int week, int year}) isoWeek(DateTime d) {
  final thursday = addDays(dateOnly(d), 4 - d.weekday);
  final jan1 = DateTime(thursday.year, 1, 1);
  final week = (thursday.difference(jan1).inDays ~/ 7) + 1;
  return (week: week, year: thursday.year);
}

final _api = DateFormat('yyyy-MM-dd');
final _apiMonth = DateFormat('MMM yy');

/// "2026-11-20" — GetDailyData_Ach and GenralPredction.
String apiDate(DateTime d) => _api.format(d);

/// "NOV 26" — GetMonthData_Ach.
String apiMonth(DateTime d) => _apiMonth.format(d).toUpperCase();

String fmtDayLong(DateTime d) => DateFormat('EEE, d MMM').format(d);
String fmtDayShort(DateTime d) => DateFormat('d MMM').format(d);
String fmtMonthYear(DateTime d) => DateFormat('MMMM yyyy').format(d);
String fmtMonShortYear(DateTime d) => DateFormat('MMM yyyy').format(d);
String fmtWeekRange(DateTime monday) {
  final sun = addDays(monday, 6);
  return '${DateFormat('d MMM').format(monday)} – ${DateFormat('d MMM').format(sun)}';
}

const kWeekdayShort = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
