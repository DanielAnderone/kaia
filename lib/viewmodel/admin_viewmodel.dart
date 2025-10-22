import 'package:flutter/material.dart';
import '../model/admin_stats.dart';
import '../model/recent_activity.dart';
import '../service/admin_service.dart';

class AdminViewModel extends ChangeNotifier {
  final AdminService _service = AdminService();

  bool isLoading = true;
  List<AdminStats> stats = [];
  List<RecentActivity> recentActivities = [];

  Future<void> loadDashboardData() async {
    isLoading = true;
    notifyListeners();

    stats = await _service.fetchStats();
    recentActivities = await _service.fetchRecentActivity();

    isLoading = false;
    notifyListeners();
  }
}
