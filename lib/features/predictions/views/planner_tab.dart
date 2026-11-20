import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/home_controller.dart';
import '../../../controllers/planner_controller.dart';
import '../../../controllers/report_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/dates.dart';
import '../../../models/five_d.dart';
import '../../../models/load_result.dart';
import '../../../models/planner_report.dart';
import '../../../ui/column_chart.dart';
import '../../../ui/controls.dart';
import '../../../ui/dim_bars.dart';
import '../../../ui/glass.dart';
import '../../../ui/motion.dart';
import '../../../ui/states.dart';
import '../../../ui/stroke_icon.dart';
import '../../../ui/tab_page.dart';
import '../../../ui/tokens.dart';
import '../../reports/views/report_tile.dart';

/// CV Planner: 5D for a day (routine events), a week (frequent events) and a
/// month (rare events), for whichever report is selected.
class PlannerTab extends StatelessWidget {
  const PlannerTab({super.key});

  @override
  Widget build(BuildContext context) {
    final reports = Get.find<ReportController>();
    final p = Get.find<PlannerController>();
    final home = Get.find<HomeController>();

    return Obx(() {
      final status = reports.status.value;
      final rep = reports.selected.value;

      if (status == LoadStatus.loading && rep == null) {
        return const TabPage(children: [
          _Title(),
          Skeleton(height: 50, radius: 16),
          Glass(child: DimBarsSkeleton()),
        ]);
      }
      if (status == LoadStatus.error && rep == null) {
        return TabPage(onRefresh: reports.load, children: [
          const _Title(),
          Glass(child: InlineNotice.error(reports.message.value, reports.load)),
        ]);
      }
      if (rep == null) {
        return TabPage(onRefresh: reports.load, children: [
          const _Title(),
          EmptyState(
            title: 'No planner yet',
            message: reports.message.value.isNotEmpty
                ? reports.message.value
                : 'When your Acharyaji sets up a CV Planner for your number in CosmoKundli, '
                    'your daily, weekly and monthly 5D will appear here.',
            icon: Ic.calendar,
            actionLabel: 'Ask your Acharyaji',
            onAction: () => home.changeNav(HomeController.tabAcharyaji),
          ),
        ]);
      }

      return TabPage(
        onRefresh: () async {
          await reports.load();
          p.retryVisible();
        },
        children: [
          _Title(report: rep),
          Obx(() => Segmented(
                labels: const ['Daily', 'Weekly', 'Monthly'],
                index: p.period.value.index,
                onChanged: (i) => p.setPeriod(PlannerPeriod.values[i]),
              )),
          Obx(() {
            final per = p.period.value;
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 380),
              switchInCurve: kEase,
              switchOutCurve: Curves.easeIn,
              layoutBuilder: (cur, prev) => Stack(
                alignment: Alignment.topCenter,
                children: [...prev, if (cur != null) cur],
              ),
              transitionBuilder: (child, a) => FadeTransition(
                opacity: a,
                child: SlideTransition(
                  position: Tween(begin: const Offset(0, 0.03), end: Offset.zero).animate(a),
                  child: child,
                ),
              ),
              child: KeyedSubtree(
                key: ValueKey(per),
                child: switch (per) {
                  PlannerPeriod.daily => const _DailyView(),
                  PlannerPeriod.weekly => const _WeeklyView(),
                  PlannerPeriod.monthly => const _MonthlyView(),
                },
              ),
            );
          }),
        ],
      );
    });
  }
}

// ───────────────────────── header ─────────────────────────

class _Title extends StatelessWidget {
  final PlannerReport? report;
  const _Title({this.report});

  @override
  Widget build(BuildContext context) {
    final reports = Get.find<ReportController>();
    final r = report;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Planner', style: T.h1),
        if (r != null) ...[
          const SizedBox(height: 14),
          Pressable(
            onTap: reports.reports.length > 1 ? () => _showReportSheet(context) : null,
            child: Glass(
              padding: const EdgeInsets.fromLTRB(10, 10, 14, 10),
              radius: 18,
              child: Row(
                children: [
                  ReportAvatar(r, size: 38),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.name, style: T.strong, maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text('${r.months}-month · ${fmtDayShort(r.start)} ${r.start.year} – ${fmtDayShort(r.end)} ${r.end.year}',
                            style: T.small.copyWith(fontSize: 11.5)),
                      ],
                    ),
                  ),
                  if (reports.reports.length > 1) ...[
                    Text('Switch', style: T.small.copyWith(color: AppColors.sun2, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 4),
                    const StrokeIcon(Ic.chevDown, color: AppColors.sun2, size: 16),
                  ],
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

void _showReportSheet(BuildContext context) {
  final reports = Get.find<ReportController>();
  showGlassSheet(context, builder: (ctx) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Whose planner?', style: T.h2),
        const SizedBox(height: 6),
        Text('Reports your Acharyaji has linked to your number.', style: T.small),
        const SizedBox(height: 16),
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: reports.reports.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final r = reports.reports[i];
              return FadeSlideIn(
                delay: Duration(milliseconds: 50 * i),
                child: ReportTile(
                  report: r,
                  showProgress: false,
                  selected: reports.selected.value?.rId == r.rId,
                  onTap: () {
                    reports.select(r);
                    Navigator.of(ctx).pop();
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  });
}

// ───────────────────────── daily ─────────────────────────

class _DailyView extends StatelessWidget {
  const _DailyView();

  @override
  Widget build(BuildContext context) {
    final p = Get.find<PlannerController>();
    return Obx(() {
      final rep = p.report;
      if (rep == null) return const SizedBox.shrink();
      final d = p.day.value;
      final week = p.daysOfWeek(mondayOf(d));
      final res = p.dailyOf(d);
      final isToday = sameDay(d, today());

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: staggered([
          Row(
            children: [
              Expanded(
                child: Pressable(
                  onTap: () => _showDayPicker(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(child: Text(fmtDayLong(d), style: T.h3.copyWith(fontSize: 19))),
                          const SizedBox(width: 6),
                          const StrokeIcon(Ic.chevDown, color: AppColors.tx2, size: 16),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(isToday ? 'Today · for routine events' : 'For routine events', style: T.small),
                    ],
                  ),
                ),
              ),
              if (!isToday && rep.coversToday) ...[
                Chip2(label: 'Today', onTap: p.goToday),
                const SizedBox(width: 8),
              ],
              RoundIconButton(
                icon: Ic.calendar,
                color: AppColors.sun,
                size: 42,
                tooltip: 'Pick a date',
                onTap: () => _showDayPicker(context),
              ),
            ],
          ),
          _WeekStrip(days: week, selected: d),
          Glass(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CardHeader('Daily 5D', note: 'For routine events'),
                const SizedBox(height: 16),
                ResultSwitch(
                  result: res,
                  onRetry: () => p.ensureDaily(d, force: true),
                  builder: (ok) => DimBars(ok.data!),
                ),
              ],
            ),
          ),
          Glass(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CardHeader('This week at a glance', note: 'Overall 5D by day'),
                const SizedBox(height: 14),
                ColumnChart(
                  color: AppColors.sun,
                  items: [
                    for (var i = 0; i < 7; i++) _columnFor(p, rep, week[i], kWeekdayInitials[i], null, sameDay(week[i], d)),
                  ],
                  onTap: (i) => p.selectDay(week[i]),
                ),
              ],
            ),
          ),
          const ToneLegend(),
        ], stepMs: 60),
      );
    });
  }
}

ColumnItem _columnFor(PlannerController p, PlannerReport rep, DateTime day, String label, String? dimKey, bool selected) {
  final r = p.dailyOf(day);
  final inRange = rep.contains(day);
  double? v;
  if (r != null && r.isOk) v = dimKey == null ? r.data!.average : r.data!.of(dimKey);
  return ColumnItem(
    label: label,
    value: v,
    selected: selected,
    enabled: inRange && (r == null || r.status != LoadStatus.locked),
    loading: inRange && (r == null || r.isLoading),
  );
}

class _WeekStrip extends StatelessWidget {
  final List<DateTime> days;
  final DateTime selected;
  const _WeekStrip({required this.days, required this.selected});

  @override
  Widget build(BuildContext context) {
    final p = Get.find<PlannerController>();
    final rep = p.report;
    if (rep == null) return const SizedBox.shrink();
    final canPrev = !days.first.isBefore(addDays(rep.start, 1));
    final canNext = days.last.isBefore(rep.end);
    return Row(
      children: [
        _ArrowButton(icon: Ic.chevLeft, enabled: canPrev, onTap: () => p.shiftDayWeek(-1)),
        Expanded(
          child: Row(
            children: [
              for (var i = 0; i < 7; i++) ...[
                if (i > 0) const SizedBox(width: 5),
                Expanded(child: _DayPill(day: days[i], selected: sameDay(days[i], selected))),
              ],
            ],
          ),
        ),
        _ArrowButton(icon: Ic.chevRight, enabled: canNext, onTap: () => p.shiftDayWeek(1)),
      ],
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final String icon;
  final bool enabled;
  final VoidCallback onTap;
  const _ArrowButton({required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        opacity: enabled ? 1 : 0.25,
        duration: const Duration(milliseconds: 250),
        child: SizedBox(
          width: 28,
          height: 66,
          child: Center(child: StrokeIcon(icon, color: AppColors.tx, size: 16)),
        ),
      ),
    );
  }
}

class _DayPill extends StatelessWidget {
  final DateTime day;
  final bool selected;
  const _DayPill({required this.day, required this.selected});

  @override
  Widget build(BuildContext context) {
    final p = Get.find<PlannerController>();
    final rep = p.report;
    if (rep == null) return const SizedBox.shrink();
    final inRange = rep.contains(day);
    final r = p.dailyOf(day);
    final isToday = sameDay(day, today());
    Color? dot;
    if (r != null && r.isOk) dot = toneColor(toneOf(r.data!.average));

    return Pressable(
      onTap: inRange ? () => p.selectDay(day) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: kEase,
        height: 66,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: selected ? AppColors.sun : (inRange ? AppColors.card : Colors.transparent),
          border: Border.all(
            color: selected
                ? AppColors.sun
                : isToday
                    ? AppColors.sun.withValues(alpha: 0.5)
                    : (inRange ? AppColors.line : Colors.white.withValues(alpha: 0.04)),
          ),
          boxShadow: selected ? [BoxShadow(color: AppColors.sun.withValues(alpha: 0.35), blurRadius: 16)] : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isToday ? 'Today' : kWeekdayInitials[day.weekday - 1],
              style: T.small.copyWith(
                fontSize: isToday ? 9.5 : 11,
                fontWeight: FontWeight.w600,
                color: selected
                    ? const Color(0xFF1A1205).withValues(alpha: 0.75)
                    : (inRange ? AppColors.tx3 : AppColors.tx3.withValues(alpha: 0.35)),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${day.day}',
              style: T.h3.copyWith(
                fontSize: 17,
                color: selected
                    ? const Color(0xFF1A1205)
                    : (inRange ? AppColors.tx : AppColors.tx3.withValues(alpha: 0.35)),
              ),
            ),
            const SizedBox(height: 5),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dot == null
                    ? Colors.transparent
                    : (selected ? const Color(0xFF1A1205).withValues(alpha: 0.7) : dot),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showDayPicker(BuildContext context) {
  showGlassSheet(context, builder: (_) => const _DayPickerSheet());
}

class _DayPickerSheet extends StatefulWidget {
  const _DayPickerSheet();
  @override
  State<_DayPickerSheet> createState() => _DayPickerSheetState();
}

class _DayPickerSheetState extends State<_DayPickerSheet> {
  final p = Get.find<PlannerController>();
  late DateTime _month = DateTime(p.day.value.year, p.day.value.month, 1);

  @override
  Widget build(BuildContext context) {
    final rep = p.report;
    if (rep == null) return const SizedBox.shrink();
    final months = rep.monthStarts;
    final idx = months.indexWhere((m) => sameMonth(m, _month));
    final canP = idx > 0, canN = idx >= 0 && idx < months.length - 1;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              RoundIconButton(
                icon: Ic.chevLeft,
                enabled: canP,
                tooltip: 'Previous month',
                onTap: () => setState(() => _month = months[idx - 1]),
              ),
              Expanded(child: Center(child: Text(fmtMonthYear(_month), style: T.h2.copyWith(fontSize: 20)))),
              RoundIconButton(
                icon: Ic.chevRight,
                enabled: canN,
                tooltip: 'Next month',
                onTap: () => setState(() => _month = months[idx + 1]),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: months.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => Chip2(
                label: '${fmtMonShortYear(months[i]).substring(0, 3)} ${'${months[i].year}'.substring(2)}',
                selected: sameMonth(months[i], _month),
                onTap: () => setState(() => _month = months[i]),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _MonthGrid(
            key: ValueKey(_month),
            month: _month,
            cell: (day) {
              final ok = rep.contains(day);
              final sel = sameDay(day, p.day.value);
              final r = p.dailyOf(day);
              Color? dot;
              if (r != null && r.isOk) dot = toneColor(toneOf(r.data!.average));
              return _CalCell(
                day: day,
                enabled: ok,
                background: sel ? AppColors.sun : (ok ? Colors.white.withValues(alpha: 0.06) : Colors.transparent),
                textColor: sel ? const Color(0xFF1A1205) : (ok ? AppColors.tx : Colors.white.withValues(alpha: 0.2)),
                dot: sel ? null : dot,
                isToday: sameDay(day, today()),
                onTap: () {
                  p.selectDay(day);
                  Navigator.of(context).pop();
                },
              );
            },
          ),
          const SizedBox(height: 16),
          const ToneLegend(),
          if (rep.coversToday) ...[
            const SizedBox(height: 16),
            SecondaryButton(
              label: 'Jump to today',
              expand: true,
              onTap: () {
                p.goToday();
                Navigator.of(context).pop();
              },
            ),
          ],
        ],
      ),
    );
  }
}

/// Mon–Sun calendar grid for one month.
class _MonthGrid extends StatelessWidget {
  final DateTime month;
  final Widget Function(DateTime day) cell;
  const _MonthGrid({super.key, required this.month, required this.cell});

  @override
  Widget build(BuildContext context) {
    final n = DateTime(month.year, month.month + 1, 0).day;
    final offset = DateTime(month.year, month.month, 1).weekday - 1;
    final total = ((offset + n) / 7).ceil() * 7;
    return Column(
      children: [
        Row(
          children: [
            for (final w in kWeekdayInitials)
              Expanded(child: Center(child: Text(w, style: T.small.copyWith(fontWeight: FontWeight.w600)))),
          ],
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
          padding: EdgeInsets.zero,
          children: [
            for (var i = 0; i < total; i++)
              if (i < offset || i >= offset + n)
                const SizedBox.shrink()
              else
                PopIn(
                  delay: Duration(milliseconds: 10 * (i - offset)),
                  child: cell(DateTime(month.year, month.month, i - offset + 1)),
                ),
          ],
        ),
      ],
    );
  }
}

class _CalCell extends StatelessWidget {
  final DateTime day;
  final bool enabled;
  final Color background;
  final Color textColor;
  final Color? dot;
  final bool isToday;
  final bool selected;
  final VoidCallback onTap;

  const _CalCell({
    required this.day,
    required this.enabled,
    required this.background,
    required this.textColor,
    required this.onTap,
    this.dot,
    this.isToday = false,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: enabled ? onTap : null,
      pressedScale: 0.9,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: kEase,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(11),
          border: selected
              ? Border.all(color: Colors.white, width: 2)
              : isToday
                  ? Border.all(color: Colors.white.withValues(alpha: 0.55), width: 1.2)
                  : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${day.day}', style: T.small.copyWith(fontSize: 12.5, fontWeight: FontWeight.w700, color: textColor)),
            if (dot != null) ...[
              const SizedBox(height: 3),
              Container(width: 4, height: 4, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
            ],
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── weekly ─────────────────────────

class _WeeklyView extends StatelessWidget {
  const _WeeklyView();

  @override
  Widget build(BuildContext context) {
    final p = Get.find<PlannerController>();
    return Obx(() {
      final rep = p.report;
      if (rep == null) return const SizedBox.shrink();
      final w = p.week.value;
      final weeks = rep.weeks;
      final i = weeks.indexWhere((x) => sameDay(x, w));
      final isThisWeek = sameDay(w, mondayOf(today()));
      final res = p.weeklyOf(w);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: staggered([
          _PeriodNav(
            title: fmtWeekRange(w),
            subtitle:
                '${isThisWeek ? 'This week' : 'Week ${i + 1} of ${weeks.length}'} · for frequent events',
            canPrev: p.canShiftWeek(-1),
            canNext: p.canShiftWeek(1),
            onPrev: () => p.shiftWeek(-1),
            onNext: () => p.shiftWeek(1),
            onPick: () => _showWeekPicker(context),
          ),
          Glass(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CardHeader('Weekly 5D', note: 'For frequent events'),
                const SizedBox(height: 16),
                ResultSwitch(
                  result: res,
                  onRetry: () => p.ensureWeekly(w, force: true),
                  builder: (ok) => DimBars(ok.data!),
                ),
              ],
            ),
          ),
          _DayByDay(days: p.daysOfWeek(w)),
        ], stepMs: 60),
      );
    });
  }
}

class _PeriodNav extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool canPrev;
  final bool canNext;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onPick;

  const _PeriodNav({
    required this.title,
    required this.subtitle,
    required this.canPrev,
    required this.canNext,
    required this.onPrev,
    required this.onNext,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RoundIconButton(icon: Ic.chevLeft, enabled: canPrev, onTap: onPrev, tooltip: 'Previous'),
        Expanded(
          child: Pressable(
            onTap: onPick,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(title, key: ValueKey(title), style: T.h3.copyWith(fontSize: 18)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const StrokeIcon(Ic.chevDown, color: AppColors.tx2, size: 15),
                  ],
                ),
                const SizedBox(height: 3),
                Text(subtitle, style: T.small, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
        RoundIconButton(icon: Ic.chevRight, enabled: canNext, onTap: onNext, tooltip: 'Next'),
      ],
    );
  }
}

/// Day-by-day bar graph for one dimension (or overall) across a week.
class _DayByDay extends StatefulWidget {
  final List<DateTime> days;
  const _DayByDay({required this.days});

  @override
  State<_DayByDay> createState() => _DayByDayState();
}

class _DayByDayState extends State<_DayByDay> {
  String? _dim; // null = overall

  @override
  Widget build(BuildContext context) {
    final p = Get.find<PlannerController>();
    final rep = p.report;
    if (rep == null) return const SizedBox.shrink();
    final dim = _dim == null ? null : kDims.firstWhere((d) => d.key == _dim);
    return Glass(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CardHeader('Day by day', note: 'Tap a day to open it'),
          const SizedBox(height: 14),
          _DimChips(selected: _dim, onChanged: (k) => setState(() => _dim = k)),
          const SizedBox(height: 16),
          Obx(() {
            // Touch the map so this rebuilds as days arrive.
            p.results.length;
            return ColumnChart(
              color: dim?.color ?? AppColors.sun,
              items: [
                for (var i = 0; i < widget.days.length; i++)
                  _columnFor(p, rep, widget.days[i], kWeekdayInitials[i], _dim, false),
              ],
              onTap: (i) => p.openDay(widget.days[i]),
            );
          }),
        ],
      ),
    );
  }
}

class _DimChips extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onChanged;
  const _DimChips({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        children: [
          Chip2(label: 'Overall', selected: selected == null, onTap: () => onChanged(null)),
          for (final d in kDims) ...[
            const SizedBox(width: 8),
            Chip2(
              label: d.label,
              selected: selected == d.key,
              accent: d.color,
              leading: StrokeIcon(d.icon, color: d.color, size: 14),
              onTap: () => onChanged(d.key),
            ),
          ],
        ],
      ),
    );
  }
}

void _showWeekPicker(BuildContext context) {
  final p = Get.find<PlannerController>();
  final rep = p.report;
  if (rep == null) return;
  final weeks = rep.weeks;
  final selKey = GlobalKey();

  showGlassSheet(context, builder: (ctx) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final c = selKey.currentContext;
      if (c != null) Scrollable.ensureVisible(c, alignment: 0.35);
    });
    final children = <Widget>[];
    int? lastMonth;
    for (var i = 0; i < weeks.length; i++) {
      final w = weeks[i];
      if (w.month != lastMonth) {
        lastMonth = w.month;
        children.add(Padding(
          padding: const EdgeInsets.fromLTRB(2, 14, 0, 8),
          child: Text(fmtMonthYear(w).toUpperCase(), style: T.cap),
        ));
      }
      final sel = sameDay(w, p.week.value);
      final r = p.weeklyOf(w);
      final bar = (r != null && r.isOk) ? toneColor(toneOf(r.data!.average)) : AppColors.line;
      children.add(Padding(
        key: sel ? selKey : null,
        padding: const EdgeInsets.only(bottom: 8),
        child: Pressable(
          onTap: () {
            p.selectWeek(w);
            Navigator.of(ctx).pop();
          },
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: sel ? AppColors.sun.withValues(alpha: 0.12) : AppColors.card,
              border: Border.all(color: sel ? AppColors.sun : AppColors.line),
            ),
            child: Row(
              children: [
                Container(width: 5, height: 34, decoration: BoxDecoration(color: bar, borderRadius: BorderRadius.circular(3))),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(fmtWeekRange(w), style: T.strong.copyWith(fontSize: 14.5)),
                      const SizedBox(height: 2),
                      Text(sameDay(w, mondayOf(today())) ? 'This week' : 'Week ${i + 1}', style: T.small),
                    ],
                  ),
                ),
                if (sel) const StrokeIcon(Ic.check, color: AppColors.sun, size: 18),
              ],
            ),
          ),
        ),
      ));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Pick a week', style: T.h2),
        const SizedBox(height: 4),
        Text('Weeks covered by ${rep.name}\'s planner.', style: T.small),
        Flexible(child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children))),
      ],
    );
  });
}

// ───────────────────────── monthly ─────────────────────────

class _MonthlyView extends StatelessWidget {
  const _MonthlyView();

  @override
  Widget build(BuildContext context) {
    final p = Get.find<PlannerController>();
    return Obx(() {
      final rep = p.report;
      if (rep == null) return const SizedBox.shrink();
      final m = p.month.value;
      final months = rep.monthStarts;
      final i = months.indexWhere((x) => sameMonth(x, m));
      final isThisMonth = sameMonth(m, today());
      final res = p.monthlyOf(m);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: staggered([
          _PeriodNav(
            title: fmtMonthYear(m),
            subtitle: '${isThisMonth ? 'This month' : 'Month ${i + 1} of ${months.length}'} · for rare events',
            canPrev: p.canShiftMonth(-1),
            canNext: p.canShiftMonth(1),
            onPrev: () => p.shiftMonth(-1),
            onNext: () => p.shiftMonth(1),
            onPick: () => _showMonthPicker(context),
          ),
          Glass(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CardHeader('Monthly 5D', note: 'For rare events'),
                const SizedBox(height: 16),
                ResultSwitch(
                  result: res,
                  onRetry: () => p.ensureMonthly(m, force: true),
                  builder: (ok) => DimBars(ok.data!),
                ),
              ],
            ),
          ),
          _MonthHeatmap(key: ValueKey('${m.year}-${m.month}'), month: m),
        ], stepMs: 60),
      );
    });
  }
}

/// Calendar heatmap of daily 5D for the month; tap a date for its reading.
class _MonthHeatmap extends StatefulWidget {
  final DateTime month;
  const _MonthHeatmap({super.key, required this.month});

  @override
  State<_MonthHeatmap> createState() => _MonthHeatmapState();
}

class _MonthHeatmapState extends State<_MonthHeatmap> {
  String? _dim;
  DateTime? _sel;

  Color _shade(Color base, double v) {
    final a = ((v - 20) / 70).clamp(0.0, 1.0);
    return base.withValues(alpha: 0.12 + a * 0.88);
  }

  @override
  Widget build(BuildContext context) {
    final p = Get.find<PlannerController>();
    final rep = p.report;
    if (rep == null) return const SizedBox.shrink();
    final base = _dim == null ? AppColors.sun : kDims.firstWhere((d) => d.key == _dim).color;

    return Obx(() {
      p.results.length; // rebuild as days stream in
      final selRes = _sel == null ? null : p.dailyOf(_sel!);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DimChips(selected: _dim, onChanged: (k) => setState(() => _dim = k)),
          const SizedBox(height: 12),
          Glass(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _MonthGrid(
                  month: widget.month,
                  cell: (day) {
                    final inRange = rep.contains(day);
                    final r = p.dailyOf(day);
                    double? v;
                    if (r != null && r.isOk) v = _dim == null ? r.data!.average : r.data!.of(_dim!);
                    final bg = !inRange
                        ? Colors.transparent
                        : v == null
                            ? Colors.white.withValues(alpha: 0.05)
                            : _shade(base, v);
                    final dark = v != null && ((v - 20) / 70) > 0.55;
                    return _CalCell(
                      day: day,
                      enabled: inRange,
                      background: bg,
                      textColor: !inRange
                          ? Colors.white.withValues(alpha: 0.18)
                          : dark
                              ? const Color(0xFF0B0D1F)
                              : AppColors.tx,
                      isToday: sameDay(day, today()),
                      selected: _sel != null && sameDay(day, _sel!),
                      onTap: () => setState(() => _sel = day),
                    );
                  },
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Text('Low', style: T.small),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          gradient: LinearGradient(colors: [_shade(base, 20), _shade(base, 90)]),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('High', style: T.small),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (c, a) => FadeTransition(
              opacity: a,
              child: SizeTransition(sizeFactor: a, axisAlignment: -1, child: c),
            ),
            child: _sel == null
                ? Padding(
                    key: const ValueKey('hint'),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text('Tap any date to see its 5D', style: T.small, textAlign: TextAlign.center),
                  )
                : Glass(
                    key: ValueKey(_sel),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(fmtDayLong(_sel!), style: T.h3)),
                            SecondaryButton(label: 'Open day', onTap: () => p.openDay(_sel!)),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ResultSwitch(
                          result: selRes,
                          onRetry: () => p.ensureDaily(_sel!, force: true),
                          loading: const Skeleton(height: 44),
                          builder: (ok) => Row(
                            children: [
                              for (final d in kDims)
                                Expanded(
                                  child: Column(
                                    children: [
                                      DimBadge(d, size: 30),
                                      const SizedBox(height: 8),
                                      AnimatedPercent(value: ok.data!.of(d.key), style: T.pct.copyWith(fontSize: 14)),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      );
    });
  }
}

void _showMonthPicker(BuildContext context) {
  final p = Get.find<PlannerController>();
  final rep = p.report;
  if (rep == null) return;
  final months = rep.monthStarts;
  showGlassSheet(context, builder: (ctx) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Pick a month', style: T.h2),
        const SizedBox(height: 4),
        Text('Dot shows the month\'s overall 5D once loaded.', style: T.small),
        const SizedBox(height: 16),
        Flexible(
          child: GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.35,
            children: [
              for (var i = 0; i < months.length; i++)
                Builder(builder: (_) {
                  final m = months[i];
                  final sel = sameMonth(m, p.month.value);
                  final r = p.monthlyOf(m);
                  final dot = (r != null && r.isOk) ? toneColor(toneOf(r.data!.average)) : null;
                  return PopIn(
                    delay: Duration(milliseconds: 30 * i),
                    child: Pressable(
                      onTap: () {
                        p.selectMonth(m);
                        Navigator.of(ctx).pop();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: sel ? AppColors.sun.withValues(alpha: 0.15) : AppColors.card,
                          border: Border.all(color: sel ? AppColors.sun : AppColors.line),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(fmtMonShortYear(m).substring(0, 3), style: T.strong),
                            const SizedBox(height: 2),
                            Text('${m.year}', style: T.small),
                            const SizedBox(height: 6),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: dot ?? Colors.white.withValues(alpha: 0.12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  });
}
