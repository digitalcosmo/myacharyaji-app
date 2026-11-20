import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'controllers/auth_controller.dart';
import 'controllers/home_controller.dart';
import 'controllers/info_controller.dart';
import 'controllers/planner_controller.dart';
import 'controllers/profile_controller.dart';
import 'controllers/rashi_controller.dart';
import 'controllers/report_controller.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF080A1A),
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const MyAcharyajiApp());
}

class MyAcharyajiApp extends StatelessWidget {
  const MyAcharyajiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MyAcharyaji',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.routes,
      initialBinding: BindingsBuilder(() {
        Get.put(AuthController(), permanent: true);
        Get.put(HomeController(), permanent: true);
        Get.lazyPut(() => RashiController(), fenix: true);
        Get.lazyPut(() => ReportController(), fenix: true);
        Get.lazyPut(() => PlannerController(), fenix: true);
        Get.lazyPut(() => ProfileController(), fenix: true);
        Get.lazyPut(() => InfoController(), fenix: true);
      }),
    );
  }
}
