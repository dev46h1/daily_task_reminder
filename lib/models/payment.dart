class Payment {
  final String id;
  final String orderId;
  final double amount;
  final DateTime date;
  final String method; // "cash", "upi", "card", etc.
  final String type; // "advance" or "final"
  final String? receiptNumber;
  final String? notes;
  final DateTime createdAt;

  Payment({
    required this.id,
    required this.orderId,
    required this.amount,
    required this.date,
    required this.method,
    required this.type,
    this.receiptNumber,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'amount': amount,
      'date': date.toIso8601String(),
      'method': method,
      'type': type,
      'receiptNumber': receiptNumber,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'],
      orderId: map['orderId'],
      amount: map['amount']?.toDouble() ?? 0.0,
      date: DateTime.parse(map['date']),
      method: map['method'],
      type: map['type'],
      receiptNumber: map['receiptNumber'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Payment copyWith({
    String? id,
    String? orderId,
    double? amount,
    DateTime? date,
    String? method,
    String? type,
    String? receiptNumber,
    String? notes,
    DateTime? createdAt,
  }) {
    return Payment(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      method: method ?? this.method,
      type: type ?? this.type,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class PaymentMethod {
  static const String cash = 'cash';
  static const String upi = 'upi';
  static const String card = 'card';
  static const String bankTransfer = 'bank_transfer';
  static const String other = 'other';

  static List<String> get all => [cash, upi, card, bankTransfer, other];

  static String getDisplayName(String method) {
    switch (method) {
      case cash:
        return 'Cash';
      case upi:
        return 'UPI';
      case card:
        return 'Card';
      case bankTransfer:
        return 'Bank Transfer';
      case other:
        return 'Other';
      default:
        return method;
    }
  }
}
