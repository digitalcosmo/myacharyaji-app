import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/home_controller.dart';
import '../../../controllers/planner_controller.dart';
import '../../../controllers/report_controller.dart';
import '../../../models/load_result.dart';
import '../../../ui/glass.dart';
import '../../../ui/states.dart';
import '../../../ui/stroke_icon.dart';
import '../../../ui/tab_page.dart';
import '../../../ui/tokens.dart';
import 'report_tile.dart';

/// Every planner report mapped to this client's number. One number can hold
/// reports for several people (same number entered twice in CosmoKundli);
/// each opens its own planner.
class ReportsTab extends StatelessWidget {
  const ReportsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final reports = Get.find<ReportController>();
    final planner = Get.find<PlannerController>();
    final home = Get.find<HomeController>();

    return Obx(() {
      final status = reports.status.value;
      final list = reports.reports.toList();
      final sel = reports.selected.value;

      final header = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reports', style: T.h1),
          const SizedBox(height: 8),
          Text(
            list.length > 1
                ? '${list.length} planners are linked to your number. Tap one to open it.'
                : 'Planners your Acharyaji has linked to your number.',
            style: T.muted,
          ),
        ],
      );

      if (status == LoadStatus.loading && list.isEmpty) {
        return TabPage(children: [
          header,
          for (var i = 0; i < 2; i++)
            const Glass(
              child: Row(children: [
                Skeleton(height: 52, width: 52, radius: 16),
                SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Skeleton(height: 12, width: 90),
                    SizedBox(height: 10),
                    Skeleton(height: 16, width: 160),
                    SizedBox(height: 8),
                    Skeleton(height: 12, width: 120),
                  ]),
                ),
              ]),
            ),
        ]);
      }

      if (status == LoadStatus.error && list.isEmpty) {
        return TabPage(onRefresh: reports.load, children: [
          header,
          Glass(child: InlineNotice.error(reports.message.value, reports.load)),
        ]);
      }

      if (list.isEmpty) {
        return TabPage(onRefresh: reports.load, children: [
          header,
          EmptyState(
            title: 'No reports yet',
            message: reports.message.value.isNotEmpty
                ? reports.message.value
                : 'Your Acharyaji hasn\'t linked a planner to this number yet. '
                    'Once they do, it will show up here automatically.',
            actionLabel: 'Contact your Acharyaji',
            onAction: () => home.changeNav(HomeController.tabAcharyaji),
          ),
        ]);
      }

      return TabPage(
        onRefresh: reports.load,
        gap: 12,
        children: [
          header,
          const SizedBox(height: 2),
          for (final r in list)
            ReportTile(
              report: r,
              selected: sel?.rId == r.rId,
              onTap: () async {
                await reports.select(r);
                planner.setPeriod(PlannerPeriod.daily);
                home.changeNav(HomeController.tabPlanner);
              },
            ),
          if (list.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 1),
                    child: StrokeIcon(Ic.help, color: Color(0xFF8682A8), size: 15),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Each card is a separate person\'s planner, even when they share your number.',
                      style: T.small,
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }
}
