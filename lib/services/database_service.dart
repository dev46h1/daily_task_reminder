import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/client.dart';
import '../models/measurement.dart';
import '../models/order.dart';
import '../models/payment.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('threadcraft.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Clients table
    await db.execute('''
      CREATE TABLE clients (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phoneNumber TEXT NOT NULL UNIQUE,
        secondaryPhone TEXT,
        address TEXT,
        email TEXT,
        notes TEXT,
        registrationDate TEXT NOT NULL,
        lastOrderDate TEXT,
        totalOrders INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Measurements table
    await db.execute('''
      CREATE TABLE measurements (
        id TEXT PRIMARY KEY,
        clientId TEXT NOT NULL,
        garmentType TEXT NOT NULL,
        measurements TEXT NOT NULL,
        unit TEXT DEFAULT 'inches',
        notes TEXT,
        version INTEGER DEFAULT 1,
        isActive INTEGER DEFAULT 1,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (clientId) REFERENCES clients (id) ON DELETE CASCADE
      )
    ''');

    // Orders table
    await db.execute('''
      CREATE TABLE orders (
        id TEXT PRIMARY KEY,
        clientId TEXT NOT NULL,
        clientName TEXT NOT NULL,
        clientPhone TEXT NOT NULL,
        orderDate TEXT NOT NULL,
        deliveryDate TEXT NOT NULL,
        priority TEXT DEFAULT 'normal',
        garmentType TEXT NOT NULL,
        quantity INTEGER DEFAULT 1,
        fabricDetails TEXT NOT NULL,
        designDetails TEXT NOT NULL,
        measurementId TEXT,
        measurementSnapshot TEXT,
        specialInstructions TEXT,
        status TEXT DEFAULT 'placed',
        statusHistory TEXT,
        pricing TEXT NOT NULL,
        payments TEXT,
        totalPaid REAL DEFAULT 0.0,
        balanceDue REAL DEFAULT 0.0,
        paymentStatus TEXT DEFAULT 'not_paid',
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        completedAt TEXT,
        deliveredAt TEXT,
        FOREIGN KEY (clientId) REFERENCES clients (id) ON DELETE CASCADE
      )
    ''');

    // Payments table
    await db.execute('''
      CREATE TABLE payments (
        id TEXT PRIMARY KEY,
        orderId TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        method TEXT NOT NULL,
        type TEXT NOT NULL,
        receiptNumber TEXT,
        notes TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (orderId) REFERENCES orders (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for faster queries
    await db.execute('CREATE INDEX idx_clients_phone ON clients(phoneNumber)');
    await db.execute('CREATE INDEX idx_clients_name ON clients(name)');
    await db.execute('CREATE INDEX idx_measurements_client ON measurements(clientId)');
    await db.execute('CREATE INDEX idx_orders_client ON orders(clientId)');
    await db.execute('CREATE INDEX idx_orders_status ON orders(status)');
    await db.execute('CREATE INDEX idx_orders_delivery ON orders(deliveryDate)');
    await db.execute('CREATE INDEX idx_payments_order ON payments(orderId)');
  }

  // Client CRUD operations
  Future<String> createClient(Client client) async {
    final db = await database;
    await db.insert('clients', client.toMap());
    return client.id;
  }

  Future<Client?> getClient(String id) async {
    final db = await database;
    final maps = await db.query(
      'clients',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Client.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Client>> getAllClients() async {
    final db = await database;
    final maps = await db.query('clients', orderBy: 'name ASC');
    return maps.map((map) => Client.fromMap(map)).toList();
  }

  Future<List<Client>> searchClients(String query) async {
    final db = await database;
    final maps = await db.query(
      'clients',
      where: 'name LIKE ? OR phoneNumber LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
    return maps.map((map) => Client.fromMap(map)).toList();
  }

  Future<int> updateClient(Client client) async {
    final db = await database;
    return await db.update(
      'clients',
      client.toMap(),
      where: 'id = ?',
      whereArgs: [client.id],
    );
  }

  Future<int> deleteClient(String id) async {
    final db = await database;
    return await db.delete(
      'clients',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Measurement CRUD operations
  Future<String> createMeasurement(Measurement measurement) async {
    final db = await database;
    
    // Deactivate previous measurements of same type
    await db.update(
      'measurements',
      {'isActive': 0},
      where: 'clientId = ? AND garmentType = ?',
      whereArgs: [measurement.clientId, measurement.garmentType],
    );
    
    await db.insert('measurements', measurement.toMap());
    return measurement.id;
  }

  Future<List<Measurement>> getClientMeasurements(String clientId) async {
    final db = await database;
    final maps = await db.query(
      'measurements',
      where: 'clientId = ? AND isActive = 1',
      whereArgs: [clientId],
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => Measurement.fromMap(map)).toList();
  }

  Future<Measurement?> getMeasurement(String id) async {
    final db = await database;
    final maps = await db.query(
      'measurements',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Measurement.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateMeasurement(Measurement measurement) async {
    final db = await database;
    return await db.update(
      'measurements',
      measurement.toMap(),
      where: 'id = ?',
      whereArgs: [measurement.id],
    );
  }

  // Order CRUD operations
  Future<String> createOrder(Order order) async {
    final db = await database;
    await db.insert('orders', order.toMap());
    
    // Update client's last order date and total orders
    await db.execute('''
      UPDATE clients 
      SET lastOrderDate = ?, totalOrders = totalOrders + 1, updatedAt = ?
      WHERE id = ?
    ''', [order.orderDate.toIso8601String(), DateTime.now().toIso8601String(), order.clientId]);
    
    return order.id;
  }

  Future<Order?> getOrder(String id) async {
    final db = await database;
    final maps = await db.query(
      'orders',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Order.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Order>> getAllOrders() async {
    final db = await database;
    final maps = await db.query('orders', orderBy: 'orderDate DESC');
    return maps.map((map) => Order.fromMap(map)).toList();
  }

  Future<List<Order>> getClientOrders(String clientId) async {
    final db = await database;
    final maps = await db.query(
      'orders',
      where: 'clientId = ?',
      whereArgs: [clientId],
      orderBy: 'orderDate DESC',
    );
    return maps.map((map) => Order.fromMap(map)).toList();
  }

  Future<List<Order>> getOrdersByStatus(String status) async {
    final db = await database;
    final maps = await db.query(
      'orders',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'deliveryDate ASC',
    );
    return maps.map((map) => Order.fromMap(map)).toList();
  }

  Future<List<Order>> getOrdersByDateRange(DateTime start, DateTime end) async {
    final db = await database;
    final maps = await db.query(
      'orders',
      where: 'orderDate >= ? AND orderDate <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'orderDate DESC',
    );
    return maps.map((map) => Order.fromMap(map)).toList();
  }

  Future<int> updateOrder(Order order) async {
    final db = await database;
    return await db.update(
      'orders',
      order.toMap(),
      where: 'id = ?',
      whereArgs: [order.id],
    );
  }

  Future<int> deleteOrder(String id) async {
    final db = await database;
    return await db.delete(
      'orders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Payment CRUD operations
  Future<String> createPayment(Payment payment) async {
    final db = await database;
    await db.insert('payments', payment.toMap());
    
    // Update order's payment info
    final order = await getOrder(payment.orderId);
    if (order != null) {
      final newTotalPaid = order.totalPaid + payment.amount;
      final newBalanceDue = order.pricing.total - newTotalPaid;
      final newPaymentStatus = newBalanceDue <= 0 ? 'fully_paid' : 
                               newTotalPaid > 0 ? 'partially_paid' : 'not_paid';
      
      await db.update(
        'orders',
        {
          'totalPaid': newTotalPaid,
          'balanceDue': newBalanceDue,
          'paymentStatus': newPaymentStatus,
          'updatedAt': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [payment.orderId],
      );
    }
    
    return payment.id;
  }

  Future<List<Payment>> getOrderPayments(String orderId) async {
    final db = await database;
    final maps = await db.query(
      'payments',
      where: 'orderId = ?',
      whereArgs: [orderId],
      orderBy: 'date DESC',
    );
    return maps.map((map) => Payment.fromMap(map)).toList();
  }

  // Dashboard statistics
  Future<Map<String, dynamic>> getDashboardStats() async {
    final db = await database;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekFromNow = today.add(const Duration(days: 7));
    
    // Orders today
    final ordersToday = await db.rawQuery('''
      SELECT COUNT(*) as count FROM orders 
      WHERE date(orderDate) = date(?)
    ''', [today.toIso8601String()]);
    
    // Orders this week
    final ordersThisWeek = await db.rawQuery('''
      SELECT COUNT(*) as count FROM orders 
      WHERE orderDate >= ? AND orderDate < ?
    ''', [today.toIso8601String(), weekFromNow.toIso8601String()]);
    
    // Pending orders
    final pendingOrders = await db.rawQuery('''
      SELECT COUNT(*) as count FROM orders 
      WHERE status NOT IN ('delivered', 'cancelled')
    ''');
    
    // Overdue orders
    final overdueOrders = await db.rawQuery('''
      SELECT COUNT(*) as count FROM orders 
      WHERE deliveryDate < ? AND status NOT IN ('delivered', 'cancelled')
    ''', [today.toIso8601String()]);
    
    // Revenue this month
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final revenueThisMonth = await db.rawQuery('''
      SELECT SUM(totalPaid) as total FROM orders 
      WHERE orderDate >= ?
    ''', [firstDayOfMonth.toIso8601String()]);
    
    // Outstanding payments
    final outstandingPayments = await db.rawQuery('''
      SELECT SUM(balanceDue) as total FROM orders 
      WHERE paymentStatus != 'fully_paid' AND status != 'cancelled'
    ''');
    
    return {
      'ordersToday': ordersToday.first['count'] ?? 0,
      'ordersThisWeek': ordersThisWeek.first['count'] ?? 0,
      'pendingOrders': pendingOrders.first['count'] ?? 0,
      'overdueOrders': overdueOrders.first['count'] ?? 0,
      'revenueThisMonth': revenueThisMonth.first['total'] ?? 0.0,
      'outstandingPayments': outstandingPayments.first['total'] ?? 0.0,
    };
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
