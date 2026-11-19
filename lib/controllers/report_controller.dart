import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/network/api_repository.dart';
import '../core/storage/user_data.dart';

/// Holds the member/report list from GetReportList_Ach.
class ReportController extends GetxController {
  final ApiRepository _repo = ApiRepository();

  final isLoading = false.obs;
  final reportList = <Map<String, dynamic>>[].obs;

  // Currently selected member
  final selectedRId = ''.obs;
  final selectedName = ''.obs;
  final selectedDuration = ''.obs;
  final selectedStartMonth = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadReports();
  }

  Future<void> loadReports() async {
    try {
      isLoading.value = true;
      final userId = await UserData.getUserId();
      final appId = await UserData.getAppId();
      final result = await _repo.getReportList(userId, appId);
      isLoading.value = false;

      if (result['status'] == true && result['reports'] != null) {
        reportList.value = List<Map<String, dynamic>>.from(result['reports']);

        // Auto-select first active member
        if (reportList.isNotEmpty) {
          selectMember(0);
        }
      }
    } catch (e) {
      isLoading.value = false;
      debugPrint('Report list error: $e');
    }
  }

  void selectMember(int index) {
    final r = reportList[index];
    selectedRId.value = r['R_ID'] ?? '';
    selectedName.value = r['Name'] ?? '';
    selectedDuration.value = r['Duration'] ?? '';
    selectedStartMonth.value = r['Starting_Month'] ?? '';

    UserData.setRId(selectedRId.value);
    UserData.setUserName(selectedName.value);
    UserData.setDuration(selectedDuration.value);
    UserData.setStartMonth(selectedStartMonth.value);
  }

  bool get hasReports => reportList.isNotEmpty;
}
