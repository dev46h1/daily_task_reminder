import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/dashboard_provider.dart';
import '../providers/order_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/status_badge.dart';
import '../models/order.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    await Provider.of<DashboardProvider>(context, listen: false).loadDashboardStats();
    await Provider.of<OrderProvider>(context, listen: false).loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: Consumer2<DashboardProvider, OrderProvider>(
          builder: (context, dashboardProvider, orderProvider, child) {
            if (dashboardProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final upcomingDeliveries = orderProvider.getUpcomingDeliveries();
            final overdueOrders = orderProvider.getOverdueOrders();
            final todayOrders = orderProvider.getTodayOrders();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.3,
                    children: [
                      StatCard(
                        title: 'Orders Today',
                        value: '${dashboardProvider.ordersToday}',
                        icon: Icons.today,
                        color: Colors.blue,
                      ),
                      StatCard(
                        title: 'Pending Orders',
                        value: '${dashboardProvider.pendingOrders}',
                        icon: Icons.pending_actions,
                        color: Colors.orange,
                      ),
                      StatCard(
                        title: 'Overdue',
                        value: '${dashboardProvider.overdueOrders}',
                        icon: Icons.warning,
                        color: Colors.red,
                      ),
                      StatCard(
                        title: 'Revenue (Month)',
                        value: '₹${dashboardProvider.revenueThisMonth.toStringAsFixed(0)}',
                        icon: Icons.currency_rupee,
                        color: Colors.green,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),

                  // Overdue Orders
                  if (overdueOrders.isNotEmpty) ...[
                    _buildSectionHeader('Overdue Orders', Colors.red),
                    const SizedBox(height: 12),
                    ...overdueOrders.take(5).map((order) => _buildOrderCard(order, context)),
                    const SizedBox(height: 24),
                  ],

                  // Today's Orders
                  if (todayOrders.isNotEmpty) ...[
                    _buildSectionHeader('Today\'s Orders', Colors.blue),
                    const SizedBox(height: 12),
                    ...todayOrders.map((order) => _buildOrderCard(order, context)),
                    const SizedBox(height: 24),
                  ],

                  // Upcoming Deliveries
                  _buildSectionHeader('Upcoming Deliveries (7 Days)', Colors.green),
                  const SizedBox(height: 12),
                  if (upcomingDeliveries.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: Text('No upcoming deliveries'),
                        ),
                      ),
                    )
                  else
                    ...upcomingDeliveries.take(10).map((order) => _buildOrderCard(order, context)),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/orders/new');
        },
        icon: const Icon(Icons.add),
        label: const Text('New Order'),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(Order order, BuildContext context) {
    final daysUntilDelivery = order.deliveryDate.difference(DateTime.now()).inDays;
    final isOverdue = daysUntilDelivery < 0;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/orders/details', arguments: order.id);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.clientName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.garmentType.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(status: order.status, isSmall: true),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: isOverdue ? Colors.red : Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Delivery: ${DateFormat('MMM dd, yyyy').format(order.deliveryDate)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: isOverdue ? Colors.red : Colors.grey[600],
                      fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (isOverdue) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${daysUntilDelivery.abs()} days overdue',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order: ${order.id}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '₹${order.pricing.total.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
