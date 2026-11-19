/// API endpoints — swap `useMock` to false and update `baseUrl` to go live.
class ApiConstants {
  ApiConstants._();

  static const bool useMock = false;
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

  // Reports & Predictions
  static const String monthlyData = 'GetMonthData_Ach';
  static const String weeklyData = 'GetWeekData_Ach';
  static const String dailyData = 'GetDailyData_Ach';
  static const String reportList = 'GetReportList_Ach';
}
