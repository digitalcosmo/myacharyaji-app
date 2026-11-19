import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/home_controller.dart';
import '../../../controllers/prediction_controller.dart';
import '../../../controllers/report_controller.dart';
import '../../../controllers/info_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/zone_badge.dart';
import '../../../widgets/dimension_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final home = Get.find<HomeController>();
    final pred = Get.find<PredictionController>();
    final report = Get.find<ReportController>();
    final info = Get.find<InfoController>();

    // Load data on first build
    report.loadReports();
    info.loadConsultantDetails();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: AppColors.astronomicalBlue,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [AppColors.astronomicalBlue, Color(0xFF0F1B3D)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 22,
                              backgroundColor: AppColors.solarGold,
                              child: Icon(Icons.person, color: Colors.white, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Namaste 🙏', style: GoogleFonts.poppins(fontSize: 14, color: AppColors.reportBlueIce)),
                                  Obx(() => Text(
                                    info.consultantName.value.isNotEmpty ? info.consultantName.value : 'Acharyaji',
                                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                                  )),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Today's Overview — from PredictionController
                Obx(() => GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Today's Overview", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                          ZoneBadge(score: pred.overallScore),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(pred.formattedDate, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted)),
                      const SizedBox(height: 12),
                      if (pred.isLoading.value)
                        const Center(child: CircularProgressIndicator())
                      else
                        ...pred.dimensions.map((d) => DimensionBar(
                          dimension: d['key'],
                          label: d['label'],
                          score: d['score'],
                        )),
                    ],
                  ),
                )),

                const SizedBox(height: 16),

                Text('Quick Access', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    _QuickAction(icon: Icons.calendar_today, label: 'Daily', onTap: () => Get.toNamed(AppRoutes.dailyPrediction)),
                    _QuickAction(icon: Icons.date_range, label: 'Weekly', onTap: () => Get.toNamed(AppRoutes.weeklyPrediction)),
                    _QuickAction(icon: Icons.calendar_month, label: 'Monthly', onTap: () => Get.toNamed(AppRoutes.monthlyPrediction)),
                    _QuickAction(icon: Icons.description_outlined, label: 'Reports', onTap: () => Get.toNamed(AppRoutes.reportList)),
                    _QuickAction(icon: Icons.person_outline, label: 'Profile', onTap: () => Get.toNamed(AppRoutes.profile)),
                    _QuickAction(icon: Icons.help_outline, label: 'FAQ', onTap: () => Get.toNamed(AppRoutes.faq)),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Members', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                    TextButton(
                      onPressed: () => Get.toNamed(AppRoutes.reportList),
                      child: Text('See all', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.solarGold)),
                    ),
                  ],
                ),
                Obx(() {
                  if (report.isLoading.value) return const Center(child: CircularProgressIndicator());
                  if (report.reportList.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('No members found', style: GoogleFonts.poppins(color: AppColors.textMuted)),
                    );
                  }
                  return Column(
                    children: report.reportList.take(3).map((r) => _MemberTile(member: r)).toList(),
                  );
                }),

                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Obx(() => NavigationBar(
        selectedIndex: home.currentNavIndex.value,
        backgroundColor: Colors.white,
        indicatorColor: AppColors.astronomicalBlue.withOpacity(0.1),
        onDestinationSelected: (i) {
          home.changeNav(i);
          switch (i) {
            case 1: Get.toNamed(AppRoutes.dailyPrediction); break;
            case 2: Get.toNamed(AppRoutes.reportList); break;
            case 3: Get.toNamed(AppRoutes.profile); break;
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), selectedIcon: Icon(Icons.auto_awesome), label: 'Predictions'),
          NavigationDestination(icon: Icon(Icons.description_outlined), selectedIcon: Icon(Icons.description), label: 'Reports'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      )),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.orbitLine.withOpacity(0.5)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.astronomicalBlue, size: 28),
            const SizedBox(height: 6),
            Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final Map<String, dynamic> member;
  const _MemberTile({required this.member});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: InkWell(
          onTap: () {
            final rc = Get.find<ReportController>();
            final idx = rc.reportList.indexOf(member);
            if (idx >= 0) rc.selectMember(idx);
            Get.toNamed(AppRoutes.dailyPrediction);
          },
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: AppColors.reportBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person_outline, color: AppColors.reportBlue, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(member['Name'] ?? '', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text('Duration: ${member['Duration'] ?? ''}', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
