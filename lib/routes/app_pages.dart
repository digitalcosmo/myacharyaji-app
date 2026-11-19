import 'package:get/get.dart';
import 'app_routes.dart';
import '../features/auth/views/splash_screen.dart';
import '../features/auth/views/login_screen.dart';
import '../features/auth/views/otp_screen.dart';
import '../features/auth/views/acharya_code_screen.dart';
import '../features/home/views/home_screen.dart';
import '../features/profile/views/profile_screen.dart';
import '../features/reports/views/report_list_screen.dart';
import '../features/predictions/views/daily_prediction_screen.dart';
import '../features/predictions/views/weekly_prediction_screen.dart';
import '../features/predictions/views/monthly_prediction_screen.dart';
import '../features/reports/views/report_detail_screen.dart';
import '../features/profile/views/edit_profile_screen.dart';
import '../features/home/views/guidelines_screen.dart';
import '../features/home/views/faq_screen.dart';
import '../features/home/views/about_screen.dart';
import '../features/reports/views/report_reader_screen.dart';
import '../features/predictions/views/rashi_prediction_screen.dart';

class AppPages {
  AppPages._();

  static final routes = <GetPage>[
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
    GetPage(name: AppRoutes.login, page: () => const LoginScreen()),
    GetPage(name: AppRoutes.otp, page: () => const OtpScreen()),
    GetPage(name: AppRoutes.acharyaCode, page: () => const AcharyaCodeScreen()),
    GetPage(name: AppRoutes.home, page: () => const HomeScreen()),
    GetPage(name: AppRoutes.profile, page: () => const ProfileScreen()),
    GetPage(name: AppRoutes.editProfile, page: () => const EditProfileScreen()),
    GetPage(name: AppRoutes.reportList, page: () => const ReportListScreen()),
    GetPage(name: AppRoutes.reportDetail, page: () => const ReportDetailScreen()),
    GetPage(name: AppRoutes.dailyPrediction, page: () => const DailyPredictionScreen()),
    GetPage(name: AppRoutes.weeklyPrediction, page: () => const WeeklyPredictionScreen()),
    GetPage(name: AppRoutes.monthlyPrediction, page: () => const MonthlyPredictionScreen()),
    GetPage(name: AppRoutes.guidelines, page: () => const GuidelinesScreen()),
    GetPage(name: AppRoutes.faq, page: () => const FaqScreen()),
    GetPage(name: AppRoutes.about, page: () => const AboutScreen()),
    GetPage(name: AppRoutes.reportReader, page: () => const ReportReaderScreen()),
    GetPage(name: AppRoutes.rashiPrediction, page: () => const RashiPredictionScreen()),
  ];
}
