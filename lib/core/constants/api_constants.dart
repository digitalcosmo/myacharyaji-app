/// CosmoKundli API endpoints (same contracts as the original MyAcharya app).
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://software.cosmokundli.com/API/';

  // Auth
  static const String sendOtp = 'SendOTP';
  static const String verifyOtp = 'VerifyOTP';

  // Profile
  static const String profileDetails = 'ProfileDetails';
  static const String profileUpdate = 'ProfileUpdate';
  static const String profileImageUpdate = 'ProfileImageUpdate';

  // Content
  static const String guideline = 'Guidline';
  static const String faq = 'FAQ';
  static const String generalPrediction = 'GenralPredction';
  static const String appDetails = 'AppDetails';
  static const String consultantDetails = 'ConsultanttDetails';

  // Planner (CV Planner 5D)
  static const String monthlyData = 'GetMonthData_Ach';
  static const String weeklyData = 'GetWeekData_Ach';
  static const String dailyData = 'GetDailyData_Ach';
  static const String reportList = 'GetReportList_Ach';

  static const String termsUrl = 'https://cosmoguru.com/terms-condition';
}
