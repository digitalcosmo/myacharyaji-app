import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../core/network/api_repository.dart';
import '../core/storage/user_data.dart';

class PredictionController extends GetxController {
  final ApiRepository _repo = ApiRepository();

  final isLoading = false.obs;

  // Tab: 0=Daily, 1=Weekly, 2=Monthly
  final currentTab = 0.obs;

  // Period string for new UI
  final selectedPeriod = 'daily'.obs;

  // Sentiments & situations from API
  final sentiments = <Map<String, dynamic>>[].obs;
  final situations = <Map<String, dynamic>>[].obs;

  // 5D scores
  final career = 0.obs;
  final finance = 0.obs;
  final health = 0.obs;
  final social = 0.obs;
  final love = 0.obs;

  // Navigation
  final hasNext = false.obs;
  final hasPrevious = false.obs;

  // Daily
  final currentDate = DateTime.now().obs;
  String get formattedDate => DateFormat('yMMMd').format(currentDate.value);
  String get dayName => DateFormat('EEEE').format(currentDate.value);
  String get apiDate => DateFormat('yyyy-MM-dd').format(currentDate.value);

  // Weekly
  final currentWeekDate = DateTime.now().obs;
  int get weekNumber {
    final dayOfYear = int.parse(DateFormat('D').format(currentWeekDate.value));
    return ((dayOfYear - currentWeekDate.value.weekday + 10) / 7).floor();
  }
  String get weekYear => currentWeekDate.value.year.toString();
  String get weekRange {
    final start = currentWeekDate.value.subtract(Duration(days: currentWeekDate.value.weekday - 1));
    final end = start.add(const Duration(days: 6));
    return '${DateFormat('d/M').format(start)} to ${DateFormat('d/M').format(end)}';
  }

  // Monthly
  final currentMonthDate = DateTime.now().obs;
  String get monthName => DateFormat('MMM yy').format(currentMonthDate.value).toUpperCase();
  String get monthDisplay => DateFormat('MMMM yyyy').format(currentMonthDate.value);

  int get overallScore {
    final total = career.value + finance.value + health.value + social.value + love.value;
    return (total / 5).round();
  }

  List<Map<String, dynamic>> get dimensions => [
    {'key': 'career', 'label': 'Career', 'score': career.value},
    {'key': 'finance', 'label': 'Finance', 'score': finance.value},
    {'key': 'health', 'label': 'Health', 'score': health.value},
    {'key': 'social', 'label': 'Social', 'score': social.value},
    {'key': 'love', 'label': 'Love', 'score': love.value},
  ];

  @override
  void onInit() {
    super.onInit();
    fetchDaily();
  }

  void _parseScores(Map<String, dynamic> data) {
    career.value = _toInt(data['career']);
    finance.value = _toInt(data['finance']);
    health.value = _toInt(data['health']);
    social.value = _toInt(data['social']);
    love.value = _toInt(data['love']);
    hasNext.value = data['next'] == true;
    hasPrevious.value = data['previous'] == true;
  }

  int _toInt(dynamic v) => (v is num) ? v.toInt() : 0;

  // ───── Daily ─────
  Future<void> fetchDaily() async {
    try {
      isLoading.value = true;
      final rId = await UserData.getRId();
      final data = {'R_ID': rId, 'date': apiDate};
      final result = await _repo.getDailyData(data);
      isLoading.value = false;

      if (result['status'] == true) {
        _parseScores(result);
      }
    } catch (e) {
      isLoading.value = false;
      debugPrint('Daily error: $e');
    }
  }

  void changeDay(int direction) {
    currentDate.value = currentDate.value.add(Duration(days: direction));
    fetchDaily();
  }

  // ───── Weekly ─────
  Future<void> fetchWeekly() async {
    try {
      isLoading.value = true;
      final rId = await UserData.getRId();
      final data = {'R_ID': rId, 'weeknumber': weekNumber.toString(), 'year': weekYear};
      final result = await _repo.getWeeklyData(data);
      isLoading.value = false;

      if (result['status'] == true) {
        _parseScores(result);
      }
    } catch (e) {
      isLoading.value = false;
      debugPrint('Weekly error: $e');
    }
  }

  void changeWeek(int direction) {
    currentWeekDate.value = currentWeekDate.value.add(Duration(days: 7 * direction));
    fetchWeekly();
  }

  // ───── Monthly ─────
  Future<void> fetchMonthly() async {
    try {
      isLoading.value = true;
      final rId = await UserData.getRId();
      final data = {'R_ID': rId, 'month': monthName};
      final result = await _repo.getMonthlyData(data);
      isLoading.value = false;

      if (result['status'] == true) {
        _parseScores(result);
      }
    } catch (e) {
      isLoading.value = false;
      debugPrint('Monthly error: $e');
    }
  }

  void changeMonth(int direction) {
    final d = currentMonthDate.value;
    if (direction > 0) {
      currentMonthDate.value = DateTime(d.year, d.month + 1);
    } else {
      currentMonthDate.value = DateTime(d.year, d.month - 1);
    }
    fetchMonthly();
  }

  void switchTab(int index) {
    currentTab.value = index;
    switch (index) {
      case 0: fetchDaily(); break;
      case 1: fetchWeekly(); break;
      case 2: fetchMonthly(); break;
    }
  }

  void changePeriod(String period) {
    selectedPeriod.value = period;
    switch (period) {
      case 'daily': switchTab(0); break;
      case 'weekly': switchTab(1); break;
      case 'monthly': switchTab(2); break;
    }
  }
}
