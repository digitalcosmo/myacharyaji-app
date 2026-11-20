import 'dart:convert';
import '../constants/api_constants.dart';
import 'api_client.dart';

/// Central repository — every API call goes through here. No mock data:
/// whatever the CosmoKundli server returns is what the app shows.
class ApiRepository {
  final ApiClient _client = ApiClient();

  /// Some endpoints answer with a text/html content type, so Dio hands back
  /// a String. Normalise everything to a JSON map.
  Map<String, dynamic> _map(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is String && data.trim().isNotEmpty) {
      final decoded = jsonDecode(data);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    }
    throw const FormatException('Unexpected response from server');
  }

  Future<Map<String, dynamic>> _post(String ep, Map<String, dynamic> body) async =>
      _map((await _client.post(ep, data: body)).data);

  Future<Map<String, dynamic>> _get(String ep) async =>
      _map((await _client.get(ep)).data);

  // ───── Auth ─────
  Future<Map<String, dynamic>> sendOtp(Map<String, dynamic> data) =>
      _post(ApiConstants.sendOtp, data);

  Future<Map<String, dynamic>> verifyOtp(Map<String, dynamic> data) =>
      _post(ApiConstants.verifyOtp, data);

  // ───── Acharyaji code ─────
  Future<Map<String, dynamic>> validateAppCode(Map<String, dynamic> data) =>
      _post(ApiConstants.appDetails, data);

  // ───── Profile ─────
  Future<Map<String, dynamic>> getProfile(String userId) =>
      _post(ApiConstants.profileDetails, {'uID': userId});

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) =>
      _post(ApiConstants.profileUpdate, data);

  // ───── Consultant ─────
  Future<Map<String, dynamic>> getConsultantDetails(String appId) =>
      _post(ApiConstants.consultantDetails, {'app_id': appId});

  // ───── Info ─────
  Future<Map<String, dynamic>> getGuidelines() => _get(ApiConstants.guideline);

  Future<Map<String, dynamic>> getFaqs() => _get(ApiConstants.faq);

  // ───── Reports mapped to this number ─────
  Future<Map<String, dynamic>> getReportList(String userId, String appId) =>
      _post(ApiConstants.reportList, {'uID': userId, 'app_id': appId});

  // ───── CV Planner 5D ─────
  /// {R_ID, date: yyyy-MM-dd}
  Future<Map<String, dynamic>> getDailyData(Map<String, dynamic> data) =>
      _post(ApiConstants.dailyData, data);

  /// {R_ID, weeknumber, year} — ISO week
  Future<Map<String, dynamic>> getWeeklyData(Map<String, dynamic> data) =>
      _post(ApiConstants.weeklyData, data);

  /// {R_ID, month: "NOV 26"}
  Future<Map<String, dynamic>> getMonthlyData(Map<String, dynamic> data) =>
      _post(ApiConstants.monthlyData, data);

  // ───── General (rashi) prediction ─────
  /// {rashi: Hindi name e.g. "Mesh", date: yyyy-MM-dd}
  Future<Map<String, dynamic>> getGeneralPrediction(Map<String, dynamic> data) =>
      _post(ApiConstants.generalPrediction, data);
}
