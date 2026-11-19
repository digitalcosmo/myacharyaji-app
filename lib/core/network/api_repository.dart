import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import 'api_client.dart';
import 'mock_data.dart';

/// Central repository — every API call goes through here.
/// When [ApiConstants.useMock] is true the call returns canned data
/// without hitting the network.
class ApiRepository {
  final ApiClient _client = ApiClient();

  // ───── Auth ─────

  Future<Map<String, dynamic>> sendOtp(Map<String, dynamic> data) async {
    if (ApiConstants.useMock) {
      await Future.delayed(const Duration(milliseconds: 600));
      return {'status': true, 'msg': 'OTP sent successfully'};
    }
    final r = await _client.post(ApiConstants.sendOtp, data: data);
    return r.data;
  }

  Future<Map<String, dynamic>> verifyOtp(Map<String, dynamic> data) async {
    if (ApiConstants.useMock) {
      await Future.delayed(const Duration(milliseconds: 600));
      return {
        'status': true,
        'msg': 'OTP verified',
        'uID': 'MOCK_UID_001',
        'regstration_required': 'No',
      };
    }
    final r = await _client.post(ApiConstants.verifyOtp, data: data);
    return r.data;
  }

  // ───── Acharyaji code ─────

  Future<Map<String, dynamic>> validateAppCode(Map<String, dynamic> data) async {
    if (ApiConstants.useMock) {
      await Future.delayed(const Duration(milliseconds: 600));
      return {
        'status': true,
        'app_id': 'MOCK_APP_001',
        'app_name': 'MyAcharyaji',
        'icon': '',
      };
    }
    final r = await _client.post(ApiConstants.appDetails, data: data);
    return r.data;
  }

  // ───── Profile ─────

  Future<Map<String, dynamic>> getProfile(String userId) async {
    if (ApiConstants.useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      return {
        'status': true,
        'first_name': 'Arjun',
        'middle_name': '',
        'surname': 'Patel',
        'mobile': '+919123456789',
        'Gender': 'male',
        'dob': '1992-03-15',
        'image': '',
      };
    }
    final r = await _client.post(ApiConstants.profileDetails, data: {'uID': userId});
    return r.data;
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    if (ApiConstants.useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      return {'status': true, 'msg': 'Profile updated'};
    }
    final r = await _client.post(ApiConstants.profileUpdate, data: data);
    return r.data;
  }

  // ───── Consultant / About ─────

  Future<Map<String, dynamic>> getConsultantDetails(String appId) async {
    if (ApiConstants.useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return {
        'status': true,
        'name': 'Pandit Raghunath Sharma',
        'address': 'Jyotish Bhawan, Varanasi',
        'mobile': '+919876543210',
        'email': 'pandit.sharma@example.com',
        'descripton': 'Expert Vedic astrologer with 25 years of experience.',
        'icon': '',
      };
    }
    final r = await _client.post(ApiConstants.consultantDetails, data: {'app_id': appId});
    return r.data;
  }

  // ───── Info ─────

  Future<Map<String, dynamic>> getGuidelines() async {
    if (ApiConstants.useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return {
        'content': '<h3>Understanding Zones</h3><p>Zones range from Optimal (86-100) to Critical (0-15).</p>'
            '<h3>The 5D Dimensions</h3><p>Career, Finance, Health, Social and Love.</p>'
            '<h3>Reading Your Reports</h3><p>Reports combine planetary positions with the CVPT algorithm.</p>',
      };
    }
    final r = await _client.get(ApiConstants.guideline);
    return r.data;
  }

  Future<Map<String, dynamic>> getFaqs() async {
    if (ApiConstants.useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return {
        'status': true,
        'list': [
          {'question': 'What is CosmoKundli?', 'answer': 'CosmoKundli is a Vedic astrology system using the CVPT methodology.'},
          {'question': 'How are predictions generated?', 'answer': 'Using your birth chart combined with current planetary transits.'},
          {'question': 'What do the zones mean?', 'answer': 'Zones range from Optimal (best) to Critical (most challenging).'},
        ],
      };
    }
    final r = await _client.get(ApiConstants.faq);
    return r.data;
  }

  // ───── Report List ─────

  Future<Map<String, dynamic>> getReportList(String userId, String appId) async {
    if (ApiConstants.useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return {
        'status': true,
        'message': null,
        'reports': [
          {'R_ID': '101', 'Name': 'Arjun Patel', 'Starting_Month': '2025-07', 'Duration': '6', 'IsActive': '1'},
          {'R_ID': '102', 'Name': 'Priya Patel', 'Starting_Month': '2025-06', 'Duration': '12', 'IsActive': '1'},
        ],
      };
    }
    final r = await _client.post(ApiConstants.reportList, data: {'uID': userId, 'app_id': appId});
    return r.data;
  }

  // ───── Predictions ─────

  Future<Map<String, dynamic>> getDailyData(Map<String, dynamic> data) async {
    if (ApiConstants.useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return {
        'status': true,
        'message': 'Success',
        'next': true,
        'previous': true,
        'career': 78,
        'finance': 55,
        'health': 88,
        'social': 44,
        'love': 66,
      };
    }
    final r = await _client.post(ApiConstants.dailyData, data: data);
    return r.data;
  }

  Future<Map<String, dynamic>> getWeeklyData(Map<String, dynamic> data) async {
    if (ApiConstants.useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return {
        'status': true,
        'message': 'Success',
        'next': true,
        'previous': true,
        'career': 72,
        'finance': 60,
        'health': 85,
        'social': 50,
        'love': 70,
      };
    }
    final r = await _client.post(ApiConstants.weeklyData, data: data);
    return r.data;
  }

  Future<Map<String, dynamic>> getMonthlyData(Map<String, dynamic> data) async {
    if (ApiConstants.useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return {
        'status': true,
        'message': 'Success',
        'next': true,
        'previous': true,
        'career': 71,
        'finance': 62,
        'health': 79,
        'social': 54,
        'love': 69,
      };
    }
    final r = await _client.post(ApiConstants.monthlyData, data: data);
    return r.data;
  }

  // ───── General (Rashi) Prediction ─────

  Future<Map<String, dynamic>> getGeneralPrediction(Map<String, dynamic> data) async {
    if (ApiConstants.useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      return {
        'status': true,
        'career': 72,
        'finance': 58,
        'health': 81,
        'social': 45,
        'love': 66,
      };
    }
    final r = await _client.post(ApiConstants.generalPrediction, data: data);
    return r.data;
  }
}
