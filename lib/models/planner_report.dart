import '../core/utils/dates.dart';

/// One planner report set up by the consultant in CosmoKundli and mapped to
/// the client's mobile number (GetReportList_Ach). A number can carry several
/// reports — e.g. the client and a family member — told apart by [name].
class PlannerReport {
  final String rId;
  final String name;

  /// First day of the report (Starting_Month is "yyyy-MM").
  final DateTime start;

  /// Last day of the report (inclusive).
  final DateTime end;

  /// 3, 6 or 12 months.
  final int months;

  /// IsActive flag from the backend ("1" / "0").
  final bool isActive;

  const PlannerReport({
    required this.rId,
    required this.name,
    required this.start,
    required this.end,
    required this.months,
    required this.isActive,
  });

  static PlannerReport? tryParse(Map<String, dynamic> j) {
    final rId = '${j['R_ID'] ?? ''}'.trim();
    final sm = '${j['Starting_Month'] ?? ''}'.trim();
    if (rId.isEmpty || sm.isEmpty) return null;
    final parts = sm.split('-');
    if (parts.length < 2) return null;
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (y == null || m == null) return null;
    final months = int.tryParse('${j['Duration'] ?? ''}'.trim()) ?? 0;
    final start = DateTime(y, m, 1);
    // Day 0 of the month after the last covered month = its last day.
    final end = DateTime(y, m + (months <= 0 ? 1 : months), 0);
    return PlannerReport(
      rId: rId,
      name: '${j['Name'] ?? ''}'.trim().isEmpty ? 'Report $rId' : '${j['Name']}'.trim(),
      start: start,
      end: end,
      months: months,
      isActive: '${j['IsActive']}' == '1',
    );
  }

  bool contains(DateTime d) {
    final x = dateOnly(d);
    return !x.isBefore(start) && !x.isAfter(end);
  }

  bool get coversToday => contains(DateTime.now());
  bool get isUpcoming => dateOnly(DateTime.now()).isBefore(start);
  bool get isOver => dateOnly(DateTime.now()).isAfter(end);

  /// 0..1 of the report period that has elapsed.
  double get progress {
    final total = end.difference(start).inDays + 1;
    final done = dateOnly(DateTime.now()).difference(start).inDays + 1;
    return (done / total).clamp(0.0, 1.0);
  }

  /// The date the planner should open on: today if covered, otherwise the
  /// nearest edge of the report.
  DateTime get defaultDay {
    final t = dateOnly(DateTime.now());
    if (t.isBefore(start)) return start;
    if (t.isAfter(end)) return end;
    return t;
  }

  /// Mondays of every week that overlaps the report.
  List<DateTime> get weeks {
    final out = <DateTime>[];
    var w = mondayOf(start);
    while (!w.isAfter(end)) {
      out.add(w);
      w = addDays(w, 7);
    }
    return out;
  }

  /// First day of every month the report covers.
  List<DateTime> get monthStarts => List.generate(
        months <= 0 ? 1 : months,
        (i) => DateTime(start.year, start.month + i, 1),
      );

  String get initials {
    final p = name.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    if (p.isEmpty) return '?';
    if (p.length == 1) return p.first.substring(0, 1).toUpperCase();
    return (p.first.substring(0, 1) + p.last.substring(0, 1)).toUpperCase();
  }
}
