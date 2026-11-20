import 'package:get/get.dart';
import '../core/network/api_client.dart';
import '../core/network/api_repository.dart';
import '../core/storage/user_data.dart';
import '../models/load_result.dart';
import '../models/planner_report.dart';

/// Reports the consultant has mapped to this client's mobile number
/// (GetReportList_Ach). Several entries may share the number — each is a
/// separate person/report, distinguished by name and dates.
class ReportController extends GetxController {
  final ApiRepository _repo = ApiRepository();

  final status = LoadStatus.loading.obs;
  final message = ''.obs;
  final reports = <PlannerReport>[].obs;
  final selected = Rxn<PlannerReport>();

  bool get hasReports => reports.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    status.value = LoadStatus.loading;
    try {
      final userId = await UserData.getUserId();
      final appId = await UserData.getAppId();
      final r = await _repo.getReportList(userId, appId);

      final raw = r['reports'];
      final list = <PlannerReport>[];
      if (raw is List) {
        for (final item in raw) {
          if (item is Map) {
            final p = PlannerReport.tryParse(Map<String, dynamic>.from(item));
            if (p != null) list.add(p);
          }
        }
      }
      // Active first, then the one covering today, then newest start.
      list.sort((a, b) {
        if (a.isActive != b.isActive) return a.isActive ? -1 : 1;
        if (a.coversToday != b.coversToday) return a.coversToday ? -1 : 1;
        return b.start.compareTo(a.start);
      });
      reports.assignAll(list);

      if (list.isEmpty) {
        final msg = '${r['message'] ?? r['msg'] ?? ''}'.trim();
        message.value = msg;
        status.value = LoadStatus.ok;
        selected.value = null;
        return;
      }

      final savedId = await UserData.getRId();
      PlannerReport? keep;
      for (final x in list) {
        if (x.rId == savedId) keep = x;
      }
      await select(keep ?? list.first);
      status.value = LoadStatus.ok;
    } catch (e) {
      message.value = friendlyError(e);
      status.value = LoadStatus.error;
    }
  }

  Future<void> select(PlannerReport r) async {
    selected.value = r;
    await UserData.setRId(r.rId);
    await UserData.setUserName(r.name);
    await UserData.setDuration('${r.months}');
  }
}
