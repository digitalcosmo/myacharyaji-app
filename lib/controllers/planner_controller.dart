import 'dart:async';
import 'package:get/get.dart';
import '../core/network/api_client.dart';
import '../core/network/api_repository.dart';
import '../core/utils/dates.dart';
import '../models/load_result.dart';
import '../models/planner_report.dart';
import 'report_controller.dart';

enum PlannerPeriod { daily, weekly, monthly }

/// CV Planner (5D daily / weekly / monthly) for the selected report.
///
/// Every reading is cached per report, so moving back and forth between
/// days, weeks and months never re-requests what is already on screen.
/// Charts that need many days (week-at-a-glance, month heatmap) are filled
/// from GetDailyData_Ach with a small concurrency limit.
class PlannerController extends GetxController {
  final ApiRepository _repo = ApiRepository();
  late final ReportController reports;

  final period = PlannerPeriod.daily.obs;
  final day = today().obs;
  final week = mondayOf(today()).obs;
  final month = DateTime(today().year, today().month, 1).obs;

  /// key → result. Keys: "rid|d|2026-11-20", "rid|w|2026-11-16", "rid|m|2026-11".
  final results = <String, FiveDResult>{}.obs;

  final _inflight = <String, Future<void>>{};
  static const _maxParallel = 4;

  PlannerReport? get report => reports.selected.value;

  @override
  void onInit() {
    super.onInit();
    reports = Get.find<ReportController>();
    ever<PlannerReport?>(reports.selected, (_) => _resetToReport());
    _resetToReport();
  }

  void _resetToReport() {
    final r = report;
    if (r == null) return;
    final d = r.defaultDay;
    day.value = d;
    week.value = mondayOf(d);
    month.value = DateTime(d.year, d.month, 1);
    refreshVisible();
    // The Today tab shows today's personal 5D next to the rashi reading.
    if (r.coversToday) ensureDaily(today());
  }

  // ───────── keys ─────────
  String _dKey(String rid, DateTime d) => '$rid|d|${apiDate(d)}';
  String _wKey(String rid, DateTime monday) => '$rid|w|${apiDate(monday)}';
  String _mKey(String rid, DateTime m) => '$rid|m|${m.year}-${m.month}';

  FiveDResult? dailyOf(DateTime d) {
    final r = report;
    return r == null ? null : results[_dKey(r.rId, d)];
  }

  FiveDResult? weeklyOf(DateTime monday) {
    final r = report;
    return r == null ? null : results[_wKey(r.rId, monday)];
  }

  FiveDResult? monthlyOf(DateTime m) {
    final r = report;
    return r == null ? null : results[_mKey(r.rId, m)];
  }

  // ───────── fetchers ─────────
  Future<void> _fetch(String key, Future<Map<String, dynamic>> Function() call,
      {bool force = false}) {
    final existing = results[key];
    if (!force && existing != null && existing.status != LoadStatus.error) {
      return Future.value();
    }
    final running = _inflight[key];
    if (running != null) return running;

    results[key] = const FiveDResult.loading();
    final f = () async {
      try {
        results[key] = FiveDResult.fromApi(await call());
      } catch (e) {
        results[key] = FiveDResult.error(friendlyError(e));
      } finally {
        _inflight.remove(key);
      }
    }();
    _inflight[key] = f;
    return f;
  }

  Future<void> ensureDaily(DateTime d, {bool force = false}) {
    final r = report;
    if (r == null || !r.contains(d)) return Future.value();
    return _fetch(_dKey(r.rId, d),
        () => _repo.getDailyData({'R_ID': r.rId, 'date': apiDate(d)}),
        force: force);
  }

  Future<void> ensureWeekly(DateTime monday, {bool force = false}) {
    final r = report;
    if (r == null) return Future.value();
    final iso = isoWeek(monday);
    return _fetch(
        _wKey(r.rId, monday),
        () => _repo.getWeeklyData({
              'R_ID': r.rId,
              'weeknumber': '${iso.week}',
              'year': '${iso.year}',
            }),
        force: force);
  }

  Future<void> ensureMonthly(DateTime m, {bool force = false}) {
    final r = report;
    if (r == null) return Future.value();
    return _fetch(_mKey(r.rId, m),
        () => _repo.getMonthlyData({'R_ID': r.rId, 'month': apiMonth(m)}),
        force: force);
  }

  /// Loads many days with at most [_maxParallel] requests in flight.
  Future<void> ensureDays(List<DateTime> days) async {
    final r = report;
    if (r == null) return;
    final todo = days.where(r.contains).toList();
    var i = 0;
    Future<void> worker() async {
      while (i < todo.length) {
        final d = todo[i++];
        await ensureDaily(d);
      }
    }

    await Future.wait(List.generate(_maxParallel, (_) => worker()));
  }

  List<DateTime> daysOfWeek(DateTime monday) =>
      List.generate(7, (i) => addDays(monday, i));

  List<DateTime> daysOfMonth(DateTime m) {
    final n = DateTime(m.year, m.month + 1, 0).day;
    return List.generate(n, (i) => DateTime(m.year, m.month, i + 1));
  }

  /// Loads whatever the current view needs.
  void refreshVisible({bool force = false}) {
    if (report == null) return;
    switch (period.value) {
      case PlannerPeriod.daily:
        ensureDaily(day.value, force: force);
        ensureDays(daysOfWeek(mondayOf(day.value)));
        break;
      case PlannerPeriod.weekly:
        ensureWeekly(week.value, force: force);
        ensureDays(daysOfWeek(week.value));
        break;
      case PlannerPeriod.monthly:
        ensureMonthly(month.value, force: force);
        ensureDays(daysOfMonth(month.value));
        break;
    }
  }

  // ───────── navigation ─────────
  void setPeriod(PlannerPeriod p) {
    if (period.value == p) return;
    period.value = p;
    // Keep the three views pointing at the same moment in time.
    week.value = mondayOf(day.value);
    month.value = DateTime(day.value.year, day.value.month, 1);
    refreshVisible();
  }

  void selectDay(DateTime d) {
    final r = report;
    if (r == null || !r.contains(d)) return;
    day.value = dateOnly(d);
    refreshVisible();
  }

  void openDay(DateTime d) {
    selectDay(d);
    period.value = PlannerPeriod.daily;
    refreshVisible();
  }

  void selectWeek(DateTime monday) {
    week.value = mondayOf(monday);
    final r = report;
    // Keep the day inside the chosen week (and inside the report).
    if (r != null) {
      var d = week.value;
      if (d.isBefore(r.start)) d = r.start;
      day.value = d;
    }
    refreshVisible();
  }

  void selectMonth(DateTime m) {
    month.value = DateTime(m.year, m.month, 1);
    final r = report;
    if (r != null) {
      var d = month.value;
      if (d.isBefore(r.start)) d = r.start;
      if (!sameMonth(day.value, month.value)) day.value = d;
    }
    refreshVisible();
  }

  bool canShiftDay(int n) => report?.contains(addDays(day.value, n)) ?? false;

  bool canShiftWeek(int n) {
    final r = report;
    if (r == null) return false;
    final target = addDays(week.value, 7 * n);
    return !addDays(target, 6).isBefore(r.start) && !target.isAfter(r.end);
  }

  bool canShiftMonth(int n) {
    final r = report;
    if (r == null) return false;
    final m = DateTime(month.value.year, month.value.month + n, 1);
    return !DateTime(m.year, m.month + 1, 0).isBefore(r.start) && !m.isAfter(r.end);
  }

  void shiftDay(int n) {
    if (canShiftDay(n)) selectDay(addDays(day.value, n));
  }

  /// Moves the daily week strip by a week, landing on the nearest valid day.
  void shiftDayWeek(int n) {
    final r = report;
    if (r == null) return;
    var d = addDays(day.value, 7 * n);
    if (d.isBefore(r.start)) d = r.start;
    if (d.isAfter(r.end)) d = r.end;
    selectDay(d);
  }

  void shiftWeek(int n) {
    if (canShiftWeek(n)) selectWeek(addDays(week.value, 7 * n));
  }

  void shiftMonth(int n) {
    if (canShiftMonth(n)) {
      selectMonth(DateTime(month.value.year, month.value.month + n, 1));
    }
  }

  void goToday() {
    final r = report;
    if (r == null || !r.coversToday) return;
    day.value = today();
    week.value = mondayOf(today());
    month.value = DateTime(today().year, today().month, 1);
    refreshVisible();
  }

  void retryVisible() => refreshVisible(force: true);
}
