import 'payment.dart';

class Order {
  final String id;
  final String clientId;
  final String clientName;
  final String clientPhone;
  final DateTime orderDate;
  final DateTime deliveryDate;
  final String priority; // "normal" or "urgent"
  final String garmentType;
  final int quantity;
  final FabricDetails fabricDetails;
  final DesignDetails designDetails;
  final String? measurementId;
  final Map<String, double>? measurementSnapshot;
  final String? specialInstructions;
  final String status;
  final List<StatusHistory> statusHistory;
  final Pricing pricing;
  final List<Payment> payments;
  final double totalPaid;
  final double balanceDue;
  final String paymentStatus; // "not_paid", "partially_paid", "fully_paid"
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final DateTime? deliveredAt;

  Order({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.clientPhone,
    required this.orderDate,
    required this.deliveryDate,
    this.priority = 'normal',
    required this.garmentType,
    this.quantity = 1,
    required this.fabricDetails,
    required this.designDetails,
    this.measurementId,
    this.measurementSnapshot,
    this.specialInstructions,
    this.status = OrderStatus.placed,
    this.statusHistory = const [],
    required this.pricing,
    this.payments = const [],
    this.totalPaid = 0.0,
    this.balanceDue = 0.0,
    this.paymentStatus = 'not_paid',
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
    this.deliveredAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clientId': clientId,
      'clientName': clientName,
      'clientPhone': clientPhone,
      'orderDate': orderDate.toIso8601String(),
      'deliveryDate': deliveryDate.toIso8601String(),
      'priority': priority,
      'garmentType': garmentType,
      'quantity': quantity,
      'fabricDetails': fabricDetails.toJson(),
      'designDetails': designDetails.toJson(),
      'measurementId': measurementId,
      'measurementSnapshot': measurementSnapshot != null
          ? _measurementsToString(measurementSnapshot!)
          : null,
      'specialInstructions': specialInstructions,
      'status': status,
      'statusHistory': statusHistory.map((s) => s.toJson()).toList().toString(),
      'pricing': pricing.toJson(),
      'payments': payments.map((p) => p.toMap()).toList().toString(),
      'totalPaid': totalPaid,
      'balanceDue': balanceDue,
      'paymentStatus': paymentStatus,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      clientId: map['clientId'],
      clientName: map['clientName'],
      clientPhone: map['clientPhone'],
      orderDate: DateTime.parse(map['orderDate']),
      deliveryDate: DateTime.parse(map['deliveryDate']),
      priority: map['priority'] ?? 'normal',
      garmentType: map['garmentType'],
      quantity: map['quantity'] ?? 1,
      fabricDetails: FabricDetails.fromJson(map['fabricDetails']),
      designDetails: DesignDetails.fromJson(map['designDetails']),
      measurementId: map['measurementId'],
      measurementSnapshot: map['measurementSnapshot'] != null
          ? _measurementsFromString(map['measurementSnapshot'])
          : null,
      specialInstructions: map['specialInstructions'],
      status: map['status'] ?? OrderStatus.placed,
      statusHistory: [], // Simplified for MVP
      pricing: Pricing.fromJson(map['pricing']),
      payments: [], // Will be loaded separately
      totalPaid: map['totalPaid']?.toDouble() ?? 0.0,
      balanceDue: map['balanceDue']?.toDouble() ?? 0.0,
      paymentStatus: map['paymentStatus'] ?? 'not_paid',
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'])
          : null,
      deliveredAt: map['deliveredAt'] != null
          ? DateTime.parse(map['deliveredAt'])
          : null,
    );
  }

  static String _measurementsToString(Map<String, double> measurements) {
    return measurements.entries.map((e) => '${e.key}:${e.value}').join(',');
  }

  static Map<String, double> _measurementsFromString(String measurementsStr) {
    if (measurementsStr.isEmpty) return {};
    final Map<String, double> result = {};
    final pairs = measurementsStr.split(',');
    for (final pair in pairs) {
      final parts = pair.split(':');
      if (parts.length == 2) {
        result[parts[0]] = double.tryParse(parts[1]) ?? 0.0;
      }
    }
    return result;
  }

  Order copyWith({
    String? id,
    String? clientId,
    String? clientName,
    String? clientPhone,
    DateTime? orderDate,
    DateTime? deliveryDate,
    String? priority,
    String? garmentType,
    int? quantity,
    FabricDetails? fabricDetails,
    DesignDetails? designDetails,
    String? measurementId,
    Map<String, double>? measurementSnapshot,
    String? specialInstructions,
    String? status,
    List<StatusHistory>? statusHistory,
    Pricing? pricing,
    List<Payment>? payments,
    double? totalPaid,
    double? balanceDue,
    String? paymentStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    DateTime? deliveredAt,
  }) {
    return Order(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      clientPhone: clientPhone ?? this.clientPhone,
      orderDate: orderDate ?? this.orderDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      priority: priority ?? this.priority,
      garmentType: garmentType ?? this.garmentType,
      quantity: quantity ?? this.quantity,
      fabricDetails: fabricDetails ?? this.fabricDetails,
      designDetails: designDetails ?? this.designDetails,
      measurementId: measurementId ?? this.measurementId,
      measurementSnapshot: measurementSnapshot ?? this.measurementSnapshot,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      status: status ?? this.status,
      statusHistory: statusHistory ?? this.statusHistory,
      pricing: pricing ?? this.pricing,
      payments: payments ?? this.payments,
      totalPaid: totalPaid ?? this.totalPaid,
      balanceDue: balanceDue ?? this.balanceDue,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
    );
  }
}

class FabricDetails {
  final String type;
  final String providedBy; // "client" or "tailor"
  final String? measurements;
  final String? notes;

  FabricDetails({
    required this.type,
    required this.providedBy,
    this.measurements,
    this.notes,
  });

  String toJson() {
    return '$type|$providedBy|${measurements ?? ''}|${notes ?? ''}';
  }

  factory FabricDetails.fromJson(String json) {
    final parts = json.split('|');
    return FabricDetails(
      type: parts[0],
      providedBy: parts.length > 1 ? parts[1] : 'client',
      measurements: parts.length > 2 && parts[2].isNotEmpty ? parts[2] : null,
      notes: parts.length > 3 && parts[3].isNotEmpty ? parts[3] : null,
    );
  }
}

class DesignDetails {
  final String? description;
  final String? referenceNumber;
  final String? imageUrl;

  DesignDetails({
    this.description,
    this.referenceNumber,
    this.imageUrl,
  });

  String toJson() {
    return '${description ?? ''}|${referenceNumber ?? ''}|${imageUrl ?? ''}';
  }

  factory DesignDetails.fromJson(String json) {
    final parts = json.split('|');
    return DesignDetails(
      description: parts.isNotEmpty && parts[0].isNotEmpty ? parts[0] : null,
      referenceNumber: parts.length > 1 && parts[1].isNotEmpty ? parts[1] : null,
      imageUrl: parts.length > 2 && parts[2].isNotEmpty ? parts[2] : null,
    );
  }
}

class Pricing {
  final double baseCharge;
  final List<CustomizationCharge> customizations;
  final double materialCharges;
  final double urgentCharges;
  final double subtotal;
  final Discount? discount;
  final double total;

  Pricing({
    required this.baseCharge,
    this.customizations = const [],
    this.materialCharges = 0.0,
    this.urgentCharges = 0.0,
    required this.subtotal,
    this.discount,
    required this.total,
  });

  String toJson() {
    final customStr = customizations.map((c) => '${c.description}:${c.amount}').join(';');
    final discountStr = discount != null ? '${discount!.amount}:${discount!.reason}' : '';
    return '$baseCharge|$customStr|$materialCharges|$urgentCharges|$subtotal|$discountStr|$total';
  }

  factory Pricing.fromJson(String json) {
    final parts = json.split('|');
    
    List<CustomizationCharge> customizations = [];
    if (parts.length > 1 && parts[1].isNotEmpty) {
      final customParts = parts[1].split(';');
      for (final custom in customParts) {
        final customData = custom.split(':');
        if (customData.length == 2) {
          customizations.add(CustomizationCharge(
            description: customData[0],
            amount: double.tryParse(customData[1]) ?? 0.0,
          ));
        }
      }
    }

    Discount? discount;
    if (parts.length > 5 && parts[5].isNotEmpty) {
      final discountParts = parts[5].split(':');
      if (discountParts.length == 2) {
        discount = Discount(
          amount: double.tryParse(discountParts[0]) ?? 0.0,
          reason: discountParts[1],
        );
      }
    }

    return Pricing(
      baseCharge: double.tryParse(parts[0]) ?? 0.0,
      customizations: customizations,
      materialCharges: parts.length > 2 ? (double.tryParse(parts[2]) ?? 0.0) : 0.0,
      urgentCharges: parts.length > 3 ? (double.tryParse(parts[3]) ?? 0.0) : 0.0,
      subtotal: parts.length > 4 ? (double.tryParse(parts[4]) ?? 0.0) : 0.0,
      discount: discount,
      total: parts.length > 6 ? (double.tryParse(parts[6]) ?? 0.0) : 0.0,
    );
  }
}

class CustomizationCharge {
  final String description;
  final double amount;

  CustomizationCharge({
    required this.description,
    required this.amount,
  });
}

class Discount {
  final double amount;
  final String reason;

  Discount({
    required this.amount,
    required this.reason,
  });
}

class StatusHistory {
  final String status;
  final DateTime timestamp;
  final String? notes;

  StatusHistory({
    required this.status,
    required this.timestamp,
    this.notes,
  });

  String toJson() {
    return '$status|${timestamp.toIso8601String()}|${notes ?? ''}';
  }

  factory StatusHistory.fromJson(String json) {
    final parts = json.split('|');
    return StatusHistory(
      status: parts[0],
      timestamp: DateTime.parse(parts[1]),
      notes: parts.length > 2 && parts[2].isNotEmpty ? parts[2] : null,
    );
  }
}

class OrderStatus {
  static const String placed = 'placed';
  static const String fabricReceived = 'fabric_received';
  static const String cutting = 'cutting';
  static const String stitching = 'stitching';
  static const String trial = 'trial';
  static const String alterations = 'alterations';
  static const String completed = 'completed';
  static const String ready = 'ready';
  static const String delivered = 'delivered';
  static const String cancelled = 'cancelled';

  static List<String> get all => [
        placed,
        fabricReceived,
        cutting,
        stitching,
        trial,
        alterations,
        completed,
        ready,
        delivered,
        cancelled,
      ];

  static String getDisplayName(String status) {
    switch (status) {
      case placed:
        return 'Order Placed';
      case fabricReceived:
        return 'Fabric Received';
      case cutting:
        return 'Cutting Done';
      case stitching:
        return 'Stitching in Progress';
      case trial:
        return 'Trial Pending';
      case alterations:
        return 'Alterations Required';
      case completed:
        return 'Completed';
      case ready:
        return 'Ready for Pickup';
      case delivered:
        return 'Delivered';
      case cancelled:
        return 'Cancelled';
      default:
        return status;
    }
  }
}
