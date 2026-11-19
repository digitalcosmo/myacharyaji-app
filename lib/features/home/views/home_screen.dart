import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/home_controller.dart';
import '../../../controllers/prediction_controller.dart';
import '../../../controllers/report_controller.dart';
import '../../../controllers/info_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../home/views/home_tab.dart';
import '../../reports/views/reports_tab.dart';
import '../../predictions/views/planner_tab.dart';
import '../../home/views/acharyaji_tab.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final home = Get.find<HomeController>();
    // Ensure data loads for all tabs
    final ic = Get.find<InfoController>();
    if (ic.consultantName.value.isEmpty) {
      ic.loadConsultantDetails();
      ic.loadFAQs();
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Obx(() => IndexedStack(
        index: home.currentNavIndex.value,
        children: const [
          HomeTab(),
          ReportsTab(),
          PlannerTab(),
          AcharyajiTab(),
        ],
      )),
      bottomNavigationBar: Obx(() => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0A0D22),
          border: Border(top: BorderSide(color: AppColors.line)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                _TabItem(
                  icon: Icons.auto_awesome_outlined,
                  activeIcon: Icons.auto_awesome,
                  label: 'Home',
                  isActive: home.currentNavIndex.value == 0,
                  onTap: () => home.changeNav(0),
                ),
                _TabItem(
                  icon: Icons.description_outlined,
                  activeIcon: Icons.description,
                  label: 'Reports',
                  isActive: home.currentNavIndex.value == 1,
                  onTap: () => home.changeNav(1),
                ),
                _TabItem(
                  icon: Icons.calendar_today_outlined,
                  activeIcon: Icons.calendar_today,
                  label: 'Planner',
                  isActive: home.currentNavIndex.value == 2,
                  onTap: () => home.changeNav(2),
                ),
                _TabItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Acharyaji',
                  isActive: home.currentNavIndex.value == 3,
                  onTap: () => home.changeNav(3),
                ),
              ],
            ),
          ),
        ),
      )),
    );
  }
}

class _TabItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _TabItem({required this.icon, required this.activeIcon, required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppColors.sun : AppColors.tx3,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? AppColors.sun : AppColors.tx3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
