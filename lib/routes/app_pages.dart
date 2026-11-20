import 'package:get/get.dart';
import '../features/auth/views/acharya_code_screen.dart';
import '../features/auth/views/login_screen.dart';
import '../features/auth/views/otp_screen.dart';
import '../features/auth/views/splash_screen.dart';
import '../features/home/views/faq_screen.dart';
import '../features/home/views/guidelines_screen.dart';
import '../features/home/views/home_screen.dart';
import '../features/profile/views/edit_profile_screen.dart';
import '../features/profile/views/profile_screen.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final routes = <GetPage>[
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
    GetPage(name: AppRoutes.login, page: () => const LoginScreen()),
    GetPage(name: AppRoutes.otp, page: () => const OtpScreen()),
    GetPage(name: AppRoutes.acharyaCode, page: () => const AcharyaCodeScreen()),
    GetPage(name: AppRoutes.home, page: () => const HomeScreen(), transition: Transition.fadeIn),
    GetPage(name: AppRoutes.profile, page: () => const ProfileScreen(), transition: Transition.cupertino),
    GetPage(name: AppRoutes.editProfile, page: () => const EditProfileScreen(), transition: Transition.cupertino),
    GetPage(name: AppRoutes.guidelines, page: () => const GuidelinesScreen(), transition: Transition.cupertino),
    GetPage(name: AppRoutes.faq, page: () => const FaqScreen(), transition: Transition.cupertino),
  ];
}
