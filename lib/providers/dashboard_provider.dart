import 'package:flutter/foundation.dart';
import '../services/database_service.dart';

class DashboardProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  
  Map<String, dynamic> _stats = {};
  bool _isLoading = false;

  Map<String, dynamic> get stats => _stats;
  bool get isLoading => _isLoading;

  int get ordersToday => _stats['ordersToday'] ?? 0;
  int get ordersThisWeek => _stats['ordersThisWeek'] ?? 0;
  int get pendingOrders => _stats['pendingOrders'] ?? 0;
  int get overdueOrders => _stats['overdueOrders'] ?? 0;
  double get revenueThisMonth => (_stats['revenueThisMonth'] ?? 0.0).toDouble();
  double get outstandingPayments => (_stats['outstandingPayments'] ?? 0.0).toDouble();

  Future<void> loadDashboardStats() async {
    _isLoading = true;
    notifyListeners();

    try {
      _stats = await _db.getDashboardStats();
    } catch (e) {
      debugPrint('Error loading dashboard stats: $e');
      _stats = {
        'ordersToday': 0,
        'ordersThisWeek': 0,
        'pendingOrders': 0,
        'overdueOrders': 0,
        'revenueThisMonth': 0.0,
        'outstandingPayments': 0.0,
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await loadDashboardStats();
  }
}
