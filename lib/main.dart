import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'controllers/auth_controller.dart';
import 'controllers/home_controller.dart';
import 'controllers/prediction_controller.dart';
import 'controllers/profile_controller.dart';
import 'controllers/report_controller.dart';
import 'controllers/info_controller.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_routes.dart';
import 'routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();
  runApp(const MyAcharyajiApp());
}

class MyAcharyajiApp extends StatelessWidget {
  const MyAcharyajiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MyAcharyaji',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.routes,
      initialBinding: BindingsBuilder(() {
        Get.put(AuthController(), permanent: true);
        Get.lazyPut(() => HomeController());
        Get.lazyPut(() => PredictionController());
        Get.lazyPut(() => ProfileController());
        Get.lazyPut(() => ReportController());
        Get.lazyPut(() => InfoController());
      }),
    );
  }
}
