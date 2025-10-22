import '../model/admin_stats.dart';
import '../model/recent_activity.dart';

class AdminService {
  Future<List<AdminStats>> fetchStats() async {
    // Simula delay de rede
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      AdminStats(title: "Total Investors", value: "1,234", icon: "groups"),
      AdminStats(title: "Total Invested", value: "\$5,678,901", icon: "account_balance_wallet"),
      AdminStats(title: "Distributed Profit", value: "\$1,234,567", icon: "paid"),
      AdminStats(title: "Active Projects", value: "56", icon: "compost"),
    ];
  }

  Future<List<RecentActivity>> fetchRecentActivity() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      RecentActivity(icon: "person_add", description: "New user registered: John Doe", timeAgo: "2 hours ago"),
      RecentActivity(icon: "attach_money", description: "Jane Smith invested \$5,000 in Farm A", timeAgo: "5 hours ago"),
      RecentActivity(icon: "notifications", description: "System update scheduled for tonight", timeAgo: "1 day ago"),
      RecentActivity(icon: "folder_open", description: "New project 'Hatchery C' is now fundraising", timeAgo: "3 days ago"),
    ];
  }
}
