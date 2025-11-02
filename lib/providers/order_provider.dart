import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../models/payment.dart';
import '../services/database_service.dart';

class OrderProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  List<Order> _orders = [];
  List<Order> _filteredOrders = [];
  bool _isLoading = false;
  String? _statusFilter;
  DateTime? _startDate;
  DateTime? _endDate;

  List<Order> get orders => _filteredOrders;
  bool get isLoading => _isLoading;
  String? get statusFilter => _statusFilter;

  Future<void> loadOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      _orders = await _db.getAllOrders();
      _applyFilters();
    } catch (e) {
      debugPrint('Error loading orders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Order?> getOrder(String id) async {
    try {
      return await _db.getOrder(id);
    } catch (e) {
      debugPrint('Error getting order: $e');
      return null;
    }
  }

  Future<List<Order>> getClientOrders(String clientId) async {
    try {
      return await _db.getClientOrders(clientId);
    } catch (e) {
      debugPrint('Error getting client orders: $e');
      return [];
    }
  }

  Future<bool> createOrder(Order order) async {
    try {
      await _db.createOrder(order);
      await loadOrders();
      return true;
    } catch (e) {
      debugPrint('Error creating order: $e');
      return false;
    }
  }

  Future<bool> updateOrder(Order order) async {
    try {
      final updatedOrder = order.copyWith(updatedAt: DateTime.now());
      await _db.updateOrder(updatedOrder);
      await loadOrders();
      return true;
    } catch (e) {
      debugPrint('Error updating order: $e');
      return false;
    }
  }

  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    try {
      final order = await _db.getOrder(orderId);
      if (order == null) return false;

      final updatedOrder = order.copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
        completedAt: newStatus == OrderStatus.completed ? DateTime.now() : order.completedAt,
        deliveredAt: newStatus == OrderStatus.delivered ? DateTime.now() : order.deliveredAt,
      );

      await _db.updateOrder(updatedOrder);
      await loadOrders();
      return true;
    } catch (e) {
      debugPrint('Error updating order status: $e');
      return false;
    }
  }

  Future<bool> deleteOrder(String id) async {
    try {
      await _db.deleteOrder(id);
      await loadOrders();
      return true;
    } catch (e) {
      debugPrint('Error deleting order: $e');
      return false;
    }
  }

  Future<List<Payment>> getOrderPayments(String orderId) async {
    try {
      return await _db.getOrderPayments(orderId);
    } catch (e) {
      debugPrint('Error getting order payments: $e');
      return [];
    }
  }

  Future<bool> addPayment(Payment payment) async {
    try {
      await _db.createPayment(payment);
      await loadOrders();
      return true;
    } catch (e) {
      debugPrint('Error adding payment: $e');
      return false;
    }
  }

  void filterByStatus(String? status) {
    _statusFilter = status;
    _applyFilters();
    notifyListeners();
  }

  void filterByDateRange(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _statusFilter = null;
    _startDate = null;
    _endDate = null;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredOrders = _orders;

    if (_statusFilter != null) {
      _filteredOrders = _filteredOrders
          .where((order) => order.status == _statusFilter)
          .toList();
    }

    if (_startDate != null && _endDate != null) {
      _filteredOrders = _filteredOrders.where((order) {
        return order.orderDate.isAfter(_startDate!) &&
               order.orderDate.isBefore(_endDate!.add(const Duration(days: 1)));
      }).toList();
    }
  }

  List<Order> getUpcomingDeliveries({int days = 7}) {
    final now = DateTime.now();
    final futureDate = now.add(Duration(days: days));
    
    return _orders.where((order) {
      return order.deliveryDate.isAfter(now) &&
             order.deliveryDate.isBefore(futureDate) &&
             order.status != OrderStatus.delivered &&
             order.status != OrderStatus.cancelled;
    }).toList()
      ..sort((a, b) => a.deliveryDate.compareTo(b.deliveryDate));
  }

  List<Order> getOverdueOrders() {
    final now = DateTime.now();
    
    return _orders.where((order) {
      return order.deliveryDate.isBefore(now) &&
             order.status != OrderStatus.delivered &&
             order.status != OrderStatus.cancelled;
    }).toList()
      ..sort((a, b) => a.deliveryDate.compareTo(b.deliveryDate));
  }

  List<Order> getTodayOrders() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    
    return _orders.where((order) {
      return order.orderDate.isAfter(today) &&
             order.orderDate.isBefore(tomorrow);
    }).toList();
  }
}
