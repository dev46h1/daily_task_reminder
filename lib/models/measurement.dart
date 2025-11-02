class Measurement {
  final String id;
  final String clientId;
  final String garmentType;
  final Map<String, double> measurements;
  final String unit; // "inches" or "cm"
  final String? notes;
  final int version;
  final bool isActive;
  final DateTime createdAt;

  Measurement({
    required this.id,
    required this.clientId,
    required this.garmentType,
    required this.measurements,
    this.unit = 'inches',
    this.notes,
    this.version = 1,
    this.isActive = true,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clientId': clientId,
      'garmentType': garmentType,
      'measurements': _measurementsToString(measurements),
      'unit': unit,
      'notes': notes,
      'version': version,
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Measurement.fromMap(Map<String, dynamic> map) {
    return Measurement(
      id: map['id'],
      clientId: map['clientId'],
      garmentType: map['garmentType'],
      measurements: _measurementsFromString(map['measurements']),
      unit: map['unit'] ?? 'inches',
      notes: map['notes'],
      version: map['version'] ?? 1,
      isActive: map['isActive'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  static String _measurementsToString(Map<String, double> measurements) {
    return measurements.entries
        .map((e) => '${e.key}:${e.value}')
        .join(',');
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

  Measurement copyWith({
    String? id,
    String? clientId,
    String? garmentType,
    Map<String, double>? measurements,
    String? unit,
    String? notes,
    int? version,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Measurement(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      garmentType: garmentType ?? this.garmentType,
      measurements: measurements ?? this.measurements,
      unit: unit ?? this.unit,
      notes: notes ?? this.notes,
      version: version ?? this.version,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// Garment type constants
class GarmentType {
  static const String shirt = 'shirt';
  static const String blouse = 'blouse';
  static const String churidar = 'churidar';
  static const String salwar = 'salwar';
  static const String pants = 'pants';
  static const String skirt = 'skirt';
  static const String lehenga = 'lehenga';
  static const String sareeBlouse = 'saree_blouse';
  static const String kidsWear = 'kids_wear';
  static const String custom = 'custom';

  static List<String> get all => [
        shirt,
        blouse,
        churidar,
        salwar,
        pants,
        skirt,
        lehenga,
        sareeBlouse,
        kidsWear,
        custom,
      ];

  static String getDisplayName(String type) {
    switch (type) {
      case shirt:
        return 'Shirt';
      case blouse:
        return 'Blouse';
      case churidar:
        return 'Churidar Set';
      case salwar:
        return 'Salwar Set';
      case pants:
        return 'Pants';
      case skirt:
        return 'Skirt';
      case lehenga:
        return 'Lehenga';
      case sareeBlouse:
        return 'Saree Blouse';
      case kidsWear:
        return 'Kids Wear';
      case custom:
        return 'Custom';
      default:
        return type;
    }
  }
}
