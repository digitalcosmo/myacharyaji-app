import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../controllers/home_controller.dart';
import '../../../controllers/planner_controller.dart';
import '../../../controllers/profile_controller.dart';
import '../../../controllers/rashi_controller.dart';
import '../../../controllers/report_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/dates.dart';
import '../../../models/five_d.dart';
import '../../../models/zone.dart';
import '../../../routes/app_routes.dart';
import '../../../ui/controls.dart';
import '../../../ui/dim_bars.dart';
import '../../../ui/glass.dart';
import '../../../ui/motion.dart';
import '../../../ui/zone_icon.dart';
import '../../../ui/states.dart';
import '../../../ui/stroke_icon.dart';
import '../../../ui/tab_page.dart';
import '../../../ui/tokens.dart';

/// Today: general rashi 5D for yesterday / today / tomorrow, plus a
/// shortcut to the client's own planner reading for today.
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final rashi = Get.find<RashiController>();
    return TabPage(
      onRefresh: () async => rashi.retry(),
      children: const [
        _Header(),
        _RashiPicker(),
        _DaySwitch(),
        _RashiReading(),
        _MyPlannerToday(),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final p = Get.find<ProfileController>();
    return Row(
      children: [
        Expanded(
          child: Obx(() {
            final first = p.firstName.value.trim();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(DateFormat('EEEE, d MMMM').format(DateTime.now()).toUpperCase(), style: T.cap),
                const SizedBox(height: 8),
                Text(first.isEmpty ? _greeting() : '${_greeting()},\n$first', style: T.h1),
              ],
            );
          }),
        ),
        Pressable(
          onTap: () => Get.toNamed(AppRoutes.profile),
          child: Obx(() {
            final n = p.displayName.trim();
            return Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [AppColors.vio, AppColors.teal]),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              alignment: Alignment.center,
              child: n.isEmpty
                  ? const StrokeIcon(Ic.user, color: Colors.white, size: 20)
                  : Text(n[0].toUpperCase(), style: T.h3.copyWith(color: Colors.white)),
            );
          }),
        ),
      ],
    );
  }
}

class _RashiPicker extends StatefulWidget {
  const _RashiPicker();
  @override
  State<_RashiPicker> createState() => _RashiPickerState();
}

class _RashiPickerState extends State<_RashiPicker> {
  final _scroll = ScrollController();
  static const _w = 78.0, _gap = 10.0;
  late final Worker _w1;

  @override
  void initState() {
    super.initState();
    final c = Get.find<RashiController>();
    _w1 = ever<int>(c.selected, (i) => _center(i));
    WidgetsBinding.instance.addPostFrameCallback((_) => _center(c.selected.value, animate: false));
  }

  void _center(int i, {bool animate = true}) {
    if (!_scroll.hasClients) return;
    final vw = _scroll.position.viewportDimension;
    final target = (i * (_w + _gap) - (vw - _w) / 2)
        .clamp(0.0, _scroll.position.maxScrollExtent);
    if (animate) {
      _scroll.animateTo(target, duration: const Duration(milliseconds: 500), curve: kEase);
    } else {
      _scroll.jumpTo(target);
    }
  }

  @override
  void dispose() {
    _w1.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<RashiController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('YOUR RASHI', style: T.cap),
        const SizedBox(height: 12),
        SizedBox(
          height: 98,
          child: ListView.separated(
            controller: _scroll,
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: kRashis.length,
            separatorBuilder: (_, __) => const SizedBox(width: _gap),
            itemBuilder: (_, i) => Obx(() {
              final sel = c.selected.value == i;
              final r = kRashis[i];
              return Pressable(
                onTap: () => c.selectRashi(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: kEase,
                  width: _w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: sel ? AppColors.sun.withValues(alpha: 0.16) : AppColors.card,
                    border: Border.all(
                        color: sel ? AppColors.sun.withValues(alpha: 0.6) : AppColors.line),
                    boxShadow: sel
                        ? [BoxShadow(color: AppColors.sun.withValues(alpha: 0.22), blurRadius: 18)]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      StrokeIcon(r.icon, color: sel ? AppColors.sun2 : AppColors.tx2, size: 28, strokeWidth: 1.7),
                      const SizedBox(height: 8),
                      Text(r.name,
                          style: T.small.copyWith(
                              fontSize: 12,
                              color: sel ? AppColors.tx : AppColors.tx2,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _DaySwitch extends StatelessWidget {
  const _DaySwitch();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<RashiController>();
    return Obx(() => Segmented(
          labels: const ['Yesterday', 'Today', 'Tomorrow'],
          index: c.offset.value + 1,
          onChanged: (i) => c.setOffset(i - 1),
        ));
  }
}

class _RashiReading extends StatelessWidget {
  const _RashiReading();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<RashiController>();
    return Obx(() {
      final r = c.rashi;
      final res = c.current;
      return Glass(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${r.name} · ${r.english}', style: T.h3),
                      const SizedBox(height: 4),
                      Text('General 5D for ${fmtDayLong(c.date)}', style: T.small),
                    ],
                  ),
                ),
                StrokeIcon(r.icon, color: AppColors.sun2, size: 30, strokeWidth: 1.6),
                const ZoneInfoButton(),
              ],
            ),
            const SizedBox(height: 18),
            ResultSwitch(
              result: res,
              onRetry: c.retry,
              loading: const Column(children: [
                Row(children: [
                  Expanded(child: Skeleton(height: 92, radius: 16)),
                  SizedBox(width: 10),
                  Expanded(child: Skeleton(height: 92, radius: 16)),
                ]),
                SizedBox(height: 22),
                DimBarsSkeleton(),
              ]),
              builder: (ok) => _Reading(
                key: ValueKey('${r.apiName}${c.offset.value}'),
                data: ok.data!,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _Reading extends StatelessWidget {
  final FiveD data;
  const _Reading({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Highest and lowest dimension: something concrete to act on, without
    // collapsing five different measures into one meaningless average.
    final sorted = [...kDims]..sort((a, b) => data.of(b.key).compareTo(data.of(a.key)));
    final best = sorted.first, low = sorted.last;
    final flat = data.of(best.key).round() == data.of(low.key).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!flat) ...[
          Row(
            children: [
              Expanded(child: _Highlight(title: 'Best area', dim: best, value: data.of(best.key))),
              const SizedBox(width: 10),
              Expanded(child: _Highlight(title: 'Take care with', dim: low, value: data.of(low.key))),
            ],
          ),
          const SizedBox(height: 22),
        ],
        DimBars(data),
      ],
    );
  }
}

class _Highlight extends StatelessWidget {
  final String title;
  final Dim dim;
  final double value;
  const _Highlight({required this.title, required this.dim, required this.value});

  @override
  Widget build(BuildContext context) {
    final z = Zone.of(value);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: z.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: z.color.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: T.cap.copyWith(fontSize: 10, letterSpacing: 1.2)),
          const SizedBox(height: 10),
          Row(
            children: [
              DimBadge(dim, size: 28),
              const SizedBox(width: 8),
              Expanded(child: Text(dim.label, style: T.strong.copyWith(fontSize: 14.5))),
              ZoneIcon(z, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(z.advice, style: T.small.copyWith(color: z.color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// Personal planner reading for today, when a report covers today.
class _MyPlannerToday extends StatelessWidget {
  const _MyPlannerToday();

  @override
  Widget build(BuildContext context) {
    final reports = Get.find<ReportController>();
    final planner = Get.find<PlannerController>();
    final home = Get.find<HomeController>();
    return Obx(() {
      final rep = reports.selected.value;
      if (rep == null || !rep.coversToday) return const SizedBox.shrink();
      final res = planner.dailyOf(today());
      return Pressable(
        onTap: () {
          planner.openDay(today());
          home.changeNav(HomeController.tabPlanner);
        },
        child: Glass(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.vio.withValues(alpha: 0.16), AppColors.card],
          ),
          borderColor: AppColors.vio.withValues(alpha: 0.3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CardHeader('Your planner today',
                  trailing: const StrokeIcon(Ic.chevRight, color: AppColors.tx3, size: 18)),
              const SizedBox(height: 4),
              Text(rep.name, style: T.small),
              const SizedBox(height: 16),
              ResultSwitch(
                result: res,
                onRetry: () => planner.ensureDaily(today(), force: true),
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
      );
    });
  }
}
