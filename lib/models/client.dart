class Client {
  final String id;
  final String name;
  final String phoneNumber;
  final String? secondaryPhone;
  final String? address;
  final String? email;
  final String? notes;
  final DateTime registrationDate;
  final DateTime? lastOrderDate;
  final int totalOrders;
  final DateTime createdAt;
  final DateTime updatedAt;

  Client({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.secondaryPhone,
    this.address,
    this.email,
    this.notes,
    required this.registrationDate,
    this.lastOrderDate,
    this.totalOrders = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'secondaryPhone': secondaryPhone,
      'address': address,
      'email': email,
      'notes': notes,
      'registrationDate': registrationDate.toIso8601String(),
      'lastOrderDate': lastOrderDate?.toIso8601String(),
      'totalOrders': totalOrders,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'],
      name: map['name'],
      phoneNumber: map['phoneNumber'],
      secondaryPhone: map['secondaryPhone'],
      address: map['address'],
      email: map['email'],
      notes: map['notes'],
      registrationDate: DateTime.parse(map['registrationDate']),
      lastOrderDate: map['lastOrderDate'] != null
          ? DateTime.parse(map['lastOrderDate'])
          : null,
      totalOrders: map['totalOrders'] ?? 0,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  Client copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? secondaryPhone,
    String? address,
    String? email,
    String? notes,
    DateTime? registrationDate,
    DateTime? lastOrderDate,
    int? totalOrders,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      secondaryPhone: secondaryPhone ?? this.secondaryPhone,
      address: address ?? this.address,
      email: email ?? this.email,
      notes: notes ?? this.notes,
      registrationDate: registrationDate ?? this.registrationDate,
      lastOrderDate: lastOrderDate ?? this.lastOrderDate,
      totalOrders: totalOrders ?? this.totalOrders,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
