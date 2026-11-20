import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../controllers/home_controller.dart';
import '../../../controllers/planner_controller.dart';
import '../../../controllers/report_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/dates.dart';
import '../../../models/five_d.dart';
import '../../../models/load_result.dart';
import '../../../models/planner_report.dart';
import '../../../models/zone.dart';
import '../../../ui/column_chart.dart';
import '../../../ui/controls.dart';
import '../../../ui/dim_bars.dart';
import '../../../ui/glass.dart';
import '../../../ui/motion.dart';
import '../../../ui/states.dart';
import '../../../ui/stroke_icon.dart';
import '../../../ui/tab_page.dart';
import '../../../ui/tokens.dart';
import '../../../ui/zone_icon.dart';
import '../../reports/views/report_tile.dart';

const double _gap = 16;

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
        gap: 20,
        onRefresh: () async {
          await reports.load();
          p.retryVisible();
        },
        children: [
          _Title(report: rep),
          Obx(() => Segmented(
                labels: const ['Daily', 'Weekly', 'Monthly'],
                index: p.period.value.index,
                onChanged: (i) {
                  HapticFeedback.selectionClick();
                  p.setPeriod(PlannerPeriod.values[i]);
                },
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
    final many = reports.reports.length > 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Planner', style: T.h1),
        if (r != null) ...[
          const SizedBox(height: 16),
          Pressable(
            onTap: many ? () => _showReportSheet(context) : null,
            child: Glass(
              padding: const EdgeInsets.fromLTRB(10, 10, 14, 10),
              radius: 18,
              child: Row(
                children: [
                  ReportAvatar(r, size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.name, style: T.strong, maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(
                          '${r.months}-month · ${fmtDayShort(r.start)} ${r.start.year} – ${fmtDayShort(r.end)} ${r.end.year}',
                          style: T.small.copyWith(fontSize: 11.5),
                        ),
                      ],
                    ),
                  ),
                  if (many) ...[
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

// ───────────────────────── shared pieces ─────────────────────────

/// The 5D card for the current day / week / month. Swipe it sideways to go
/// to the previous or next period; the content slides in that direction.
class _FiveDCard extends StatelessWidget {
  final String title;
  final String note;
  final Object periodKey;
  final FiveDResult? result;
  final VoidCallback onRetry;

  const _FiveDCard({
    required this.title,
    required this.note,
    required this.periodKey,
    required this.result,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final p = Get.find<PlannerController>();
    return SwipeArea(
      onSwipe: p.swipe,
      canSwipe: p.canSwipe,
      child: Glass(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: Text(title.toUpperCase(), style: T.cap)),
                Text(note, style: T.small),
                const ZoneInfoButton(),
              ],
            ),
            const SizedBox(height: 18),
            DirectionalSwitcher(
              switchKey: periodKey,
              direction: p.navDir,
              child: ResultSwitch(
                result: result,
                onRetry: onRetry,
                builder: (ok) => DimBars(ok.data!),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StrokeIcon(Ic.chevLeft, color: AppColors.tx3.withValues(alpha: 0.6), size: 12),
                const SizedBox(width: 6),
                Text('Swipe for previous / next',
                    style: T.small.copyWith(fontSize: 11, color: AppColors.tx3.withValues(alpha: 0.8))),
                const SizedBox(width: 6),
                StrokeIcon(Ic.chevRight, color: AppColors.tx3.withValues(alpha: 0.6), size: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DimChips extends StatelessWidget {
  const _DimChips();

  @override
  Widget build(BuildContext context) {
    final p = Get.find<PlannerController>();
    return SizedBox(
      height: 36,
      child: Obx(() {
        final sel = p.dim.value;
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          itemCount: kDims.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final d = kDims[i];
            return Chip2(
              label: d.label,
              selected: sel == d.key,
              accent: d.color,
              leading: StrokeIcon(d.icon, color: d.color, size: 15),
              onTap: () {
                HapticFeedback.selectionClick();
                p.dim.value = d.key;
              },
            );
          },
        );
      }),
    );
  }
}

/// Day-by-day bar graph of one dimension across a week, coloured by zone.
class _WeekColumns extends StatelessWidget {
  final List<DateTime> days;
  final DateTime? selected;
  final ValueChanged<DateTime> onTap;
  const _WeekColumns({required this.days, required this.onTap, this.selected});

  @override
  Widget build(BuildContext context) {
    final p = Get.find<PlannerController>();
    return Obx(() {
      final rep = p.report;
      if (rep == null) return const SizedBox.shrink();
      final key = p.dim.value;
      p.results.length; // rebuild as days arrive
      final items = <ColumnItem>[];
      for (final day in days) {
        final r = p.dailyOf(day);
        final inRange = rep.contains(day);
        items.add(ColumnItem(
          label: kWeekdayShort[day.weekday - 1],
          value: (r != null && r.isOk) ? r.data!.of(key) : null,
          selected: selected != null && sameDay(day, selected!),
          enabled: inRange && (r == null || r.status != LoadStatus.locked),
          loading: inRange && (r == null || r.isLoading),
        ));
      }
      return ColumnChart(items: items, onTap: (i) => onTap(days[i]));
    });
  }
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
        children: staggered(gap: _gap, stepMs: 60, [
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
                          Flexible(child: Text(fmtDayLong(d), style: T.h3.copyWith(fontSize: 20))),
                          const SizedBox(width: 6),
                          const StrokeIcon(Ic.chevDown, color: AppColors.tx2, size: 16),
                        ],
                      ),
                      const SizedBox(height: 4),
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
                size: 44,
                tooltip: 'Pick a date',
                onTap: () => _showDayPicker(context),
              ),
            ],
          ),
          const _DayStrip(),
          _FiveDCard(
            title: 'Daily 5D',
            note: fmtDayShort(d),
            periodKey: d,
            result: res,
            onRetry: () => p.ensureDaily(d, force: true),
          ),
          Glass(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: Text('THIS WEEK, DAY BY DAY', style: T.cap)),
                    Text(fmtWeekRange(week.first), style: T.small),
                  ],
                ),
                const SizedBox(height: 14),
                const _DimChips(),
                const SizedBox(height: 18),
                _WeekColumns(days: week, selected: d, onTap: p.selectDay),
              ],
            ),
          ),
        ]),
      );
    });
  }
}

/// Every day of the report in one horizontally scrollable strip. Scroll
/// freely across weeks and months; the selected day stays centred.
class _DayStrip extends StatefulWidget {
  const _DayStrip();
  @override
  State<_DayStrip> createState() => _DayStripState();
}

class _DayStripState extends State<_DayStrip> {
  static const _w = 52.0, _gapW = 8.0;
  final _scroll = ScrollController();
  final p = Get.find<PlannerController>();
  late final Worker _w1;

  @override
  void initState() {
    super.initState();
    _w1 = ever<DateTime>(p.day, (_) => _center());
    WidgetsBinding.instance.addPostFrameCallback((_) => _center(animate: false));
  }

  @override
  void dispose() {
    _w1.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _center({bool animate = true}) {
    final rep = p.report;
    if (rep == null || !_scroll.hasClients) return;
    final i = p.day.value.difference(rep.start).inDays;
    final vw = _scroll.position.viewportDimension;
    final target = (4 + i * (_w + _gapW) - (vw - _w) / 2).clamp(0.0, _scroll.position.maxScrollExtent);
    if (animate) {
      _scroll.animateTo(target, duration: const Duration(milliseconds: 450), curve: kEase);
    } else {
      _scroll.jumpTo(target);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rep = p.report;
    if (rep == null) return const SizedBox.shrink();
    // Day count via calendar dates (DST-safe), inclusive of the last day.
    final count = DateTime.utc(rep.end.year, rep.end.month, rep.end.day)
            .difference(DateTime.utc(rep.start.year, rep.start.month, rep.start.day))
            .inDays +
        1;
    return SizedBox(
      height: 80,
      child: ShaderMask(
        // Soft fade at both edges hints that the strip scrolls.
        shaderCallback: (r) => const LinearGradient(
          colors: [Colors.transparent, Colors.white, Colors.white, Colors.transparent],
          stops: [0, 0.06, 0.94, 1],
        ).createShader(r),
        blendMode: BlendMode.dstIn,
        child: ListView.separated(
          controller: _scroll,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          itemCount: count,
          separatorBuilder: (_, __) => const SizedBox(width: _gapW),
          itemBuilder: (_, i) {
            final day = addDays(rep.start, i);
            return Obx(() => SizedBox(
                  width: _w,
                  child: _DayPill(day: day, selected: sameDay(day, p.day.value)),
                ));
          },
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
    final isToday = sameDay(day, today());
    final firstOfMonth = day.day == 1;
    const ink = Color(0xFF1A1205);

    return Pressable(
      onTap: () {
        HapticFeedback.selectionClick();
        p.selectDay(day);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: kEase,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: selected ? AppColors.sun : AppColors.card,
          border: Border.all(
            color: selected ? AppColors.sun : (isToday ? AppColors.sun.withValues(alpha: 0.6) : AppColors.line),
            width: isToday && !selected ? 1.4 : 1,
          ),
          boxShadow: selected ? [BoxShadow(color: AppColors.sun.withValues(alpha: 0.35), blurRadius: 14)] : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              firstOfMonth ? fmtMonShortYear(day).substring(0, 3) : kWeekdayShort[day.weekday - 1],
              style: T.small.copyWith(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: selected ? ink.withValues(alpha: 0.75) : (firstOfMonth ? AppColors.sun2 : AppColors.tx3),
              ),
            ),
            const SizedBox(height: 3),
            Text('${day.day}', style: T.h3.copyWith(fontSize: 18, color: selected ? ink : AppColors.tx)),
            const SizedBox(height: 3),
            Text(
              isToday ? 'Today' : '',
              style: T.small.copyWith(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: selected ? ink : AppColors.sun2,
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
          const SizedBox(height: 16),
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
          const SizedBox(height: 18),
          _MonthGrid(
            key: ValueKey(_month),
            month: _month,
            cell: (day) {
              final ok = rep.contains(day);
              final sel = sameDay(day, p.day.value);
              return _CalCell(
                day: day,
                enabled: ok,
                background: sel ? AppColors.sun : (ok ? Colors.white.withValues(alpha: 0.06) : Colors.transparent),
                textColor: sel ? const Color(0xFF1A1205) : (ok ? AppColors.tx : Colors.white.withValues(alpha: 0.2)),
                isToday: sameDay(day, today()),
                onTap: () {
                  p.selectDay(day);
                  Navigator.of(context).pop();
                },
              );
            },
          ),
          if (rep.coversToday) ...[
            const SizedBox(height: 18),
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

/// Mo–Su calendar grid for one month.
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
            for (final w in kWeekdayShort)
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
  final bool isToday;
  final bool selected;
  final VoidCallback onTap;

  const _CalCell({
    required this.day,
    required this.enabled,
    required this.background,
    required this.textColor,
    required this.onTap,
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
                  ? Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.2)
                  : null,
        ),
        alignment: Alignment.center,
        child: Text('${day.day}', style: T.small.copyWith(fontSize: 13, fontWeight: FontWeight.w700, color: textColor)),
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
        children: staggered(gap: _gap, stepMs: 60, [
          _PeriodNav(
            title: fmtWeekRange(w),
            subtitle: '${isThisWeek ? 'This week' : 'Week ${i + 1} of ${weeks.length}'} · for frequent events',
            canPrev: p.canShiftWeek(-1),
            canNext: p.canShiftWeek(1),
            onPrev: () => p.shiftWeek(-1),
            onNext: () => p.shiftWeek(1),
            onPick: () => _showWeekPicker(context),
          ),
          _FiveDCard(
            title: 'Weekly 5D',
            note: isThisWeek ? 'This week' : 'Week ${i + 1}',
            periodKey: w,
            result: res,
            onRetry: () => p.ensureWeekly(w, force: true),
          ),
          Glass(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: Text('DAY BY DAY', style: T.cap)),
                    Text('Tap a day to open it', style: T.small),
                  ],
                ),
                const SizedBox(height: 14),
                const _DimChips(),
                const SizedBox(height: 18),
                _WeekColumns(days: p.daysOfWeek(w), onTap: p.openDay),
              ],
            ),
          ),
        ]),
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
        const SizedBox(width: 8),
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
                        child: Text(title, key: ValueKey(title), style: T.h3.copyWith(fontSize: 19)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const StrokeIcon(Ic.chevDown, color: AppColors.tx2, size: 15),
                  ],
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: T.small, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        RoundIconButton(icon: Ic.chevRight, enabled: canNext, onTap: onNext, tooltip: 'Next'),
      ],
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
          padding: const EdgeInsets.fromLTRB(2, 16, 0, 8),
          child: Text(fmtMonthYear(w).toUpperCase(), style: T.cap),
        ));
      }
      final sel = sameDay(w, p.week.value);
      final isThis = sameDay(w, mondayOf(today()));
      children.add(Padding(
        key: sel ? selKey : null,
        padding: const EdgeInsets.only(bottom: 8),
        child: Pressable(
          onTap: () {
            p.selectWeek(w);
            Navigator.of(ctx).pop();
          },
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: sel ? AppColors.sun.withValues(alpha: 0.12) : AppColors.card,
              border: Border.all(color: sel ? AppColors.sun : AppColors.line),
            ),
            child: Row(
              children: [
                SizedBox(width: 64, child: Text('Week ${i + 1}', style: T.small.copyWith(fontWeight: FontWeight.w600))),
                Expanded(child: Text(fmtWeekRange(w), style: T.strong.copyWith(fontSize: 14.5))),
                if (isThis)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text('This week', style: T.small.copyWith(color: AppColors.sun2, fontWeight: FontWeight.w600)),
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
        Flexible(
          child: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
          ),
        ),
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
        children: staggered(gap: _gap, stepMs: 60, [
          _PeriodNav(
            title: fmtMonthYear(m),
            subtitle: '${isThisMonth ? 'This month' : 'Month ${i + 1} of ${months.length}'} · for rare events',
            canPrev: p.canShiftMonth(-1),
            canNext: p.canShiftMonth(1),
            onPrev: () => p.shiftMonth(-1),
            onNext: () => p.shiftMonth(1),
            onPick: () => _showMonthPicker(context),
          ),
          _FiveDCard(
            title: 'Monthly 5D',
            note: fmtMonShortYear(m),
            periodKey: m,
            result: res,
            onRetry: () => p.ensureMonthly(m, force: true),
          ),
          _MonthHeatmap(key: ValueKey('${m.year}-${m.month}'), month: m),
        ]),
      );
    });
  }
}

/// Calendar of one dimension's daily zone across the month; tap a date to
/// see all five for that day.
class _MonthHeatmap extends StatefulWidget {
  final DateTime month;
  const _MonthHeatmap({super.key, required this.month});

  @override
  State<_MonthHeatmap> createState() => _MonthHeatmapState();
}

class _MonthHeatmapState extends State<_MonthHeatmap> {
  DateTime? _sel;

  @override
  Widget build(BuildContext context) {
    final p = Get.find<PlannerController>();
    final rep = p.report;
    if (rep == null) return const SizedBox.shrink();

    return Obx(() {
      p.results.length; // rebuild as days stream in
      final key = p.dim.value;
      final sel = _sel;
      final selRes = sel == null ? null : p.dailyOf(sel);
      return Glass(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: Text('DAY BY DAY', style: T.cap)),
                Text('Tap a date', style: T.small),
                const ZoneInfoButton(),
              ],
            ),
            const SizedBox(height: 14),
            const _DimChips(),
            const SizedBox(height: 18),
            _MonthGrid(
              month: widget.month,
              cell: (day) {
                final inRange = rep.contains(day);
                final r = p.dailyOf(day);
                final v = (r != null && r.isOk) ? r.data!.of(key) : null;
                final z = v == null ? null : Zone.of(v);
                return _CalCell(
                  day: day,
                  enabled: inRange,
                  background: !inRange
                      ? Colors.transparent
                      : z == null
                          ? Colors.white.withValues(alpha: 0.05)
                          : z.color.withValues(alpha: 0.9),
                  textColor: !inRange
                      ? Colors.white.withValues(alpha: 0.18)
                      : z == null
                          ? AppColors.tx2
                          : z.onColor,
                  isToday: sameDay(day, today()),
                  selected: sel != null && sameDay(day, sel),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _sel = day);
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            const ZoneStrip(),
            const SizedBox(height: 14),
            AnimatedSize(
              duration: const Duration(milliseconds: 380),
              curve: kEase,
              alignment: Alignment.topCenter,
              child: sel == null
                  ? Text('Tap any date to see all five for that day', style: T.small, textAlign: TextAlign.center)
                  : Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text(fmtDayLong(sel), style: T.h3.copyWith(fontSize: 16))),
                              SecondaryButton(label: 'Open day', onTap: () => p.openDay(sel)),
                            ],
                          ),
                          const SizedBox(height: 14),
                          ResultSwitch(
                            result: selRes,
                            onRetry: () => p.ensureDaily(sel, force: true),
                            loading: const Skeleton(height: 60),
                            builder: (ok) => Row(
                              children: [
                                for (final d in kDims)
                                  Expanded(
                                    child: Column(
                                      children: [
                                        DimBadge(d, size: 30),
                                        const SizedBox(height: 8),
                                        AnimatedPercent(value: ok.data!.of(d.key), style: T.pct.copyWith(fontSize: 14)),
                                        const SizedBox(height: 2),
                                        ZoneIcon(Zone.of(ok.data!.of(d.key)), size: 18),
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
        ),
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
        Text('Months covered by ${rep.name}\'s planner.', style: T.small),
        const SizedBox(height: 16),
        Flexible(
          child: GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.5,
            children: [
              for (var i = 0; i < months.length; i++)
                Builder(builder: (_) {
                  final m = months[i];
                  final sel = sameMonth(m, p.month.value);
                  final isThis = sameMonth(m, today());
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
                          border: Border.all(
                            color: sel ? AppColors.sun : (isThis ? AppColors.sun.withValues(alpha: 0.45) : AppColors.line),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(fmtMonShortYear(m).substring(0, 3), style: T.strong),
                            const SizedBox(height: 2),
                            Text(isThis ? 'This month' : '${m.year}',
                                style: T.small.copyWith(color: isThis ? AppColors.sun2 : AppColors.tx3)),
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
