import 'package:get/get.dart';
import '../core/storage/user_data.dart';
import '../routes/app_routes.dart';
import 'info_controller.dart';
import 'planner_controller.dart';
import 'profile_controller.dart';
import 'report_controller.dart';

/// Bottom-tab navigation and session actions.
class HomeController extends GetxController {
  static const tabToday = 0;
  static const tabReports = 1;
  static const tabPlanner = 2;
  static const tabAcharyaji = 3;

  final currentNavIndex = 0.obs;

  /// Bumped on every tab switch; tabs key their content on it so entrance
  /// animations replay each time a tab is opened (as in the prototype).
  final visit = 0.obs;

  void changeNav(int index) {
    if (index == currentNavIndex.value) return;
    currentNavIndex.value = index;
    visit.value++;
  }

  Future<void> logout() async {
    await UserData.clear();
    Get.offAllNamed(AppRoutes.login);
    // Drop every per-user controller so the next sign-in starts clean
    // (registered with fenix: true, so they are rebuilt on next use).
    // Wait for the home route's exit transition before removing them.
    Future.delayed(const Duration(milliseconds: 700), () {
      Get.delete<PlannerController>(force: true);
      Get.delete<ReportController>(force: true);
      Get.delete<ProfileController>(force: true);
      Get.delete<InfoController>(force: true);
      currentNavIndex.value = tabToday;
    });
  }
}
