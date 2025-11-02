import 'package:flutter/foundation.dart';
import '../models/measurement.dart';
import '../services/database_service.dart';

class MeasurementProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  Map<String, List<Measurement>> _clientMeasurements = {};
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<List<Measurement>> getClientMeasurements(String clientId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final measurements = await _db.getClientMeasurements(clientId);
      _clientMeasurements[clientId] = measurements;
      return measurements;
    } catch (e) {
      debugPrint('Error loading measurements: $e');
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Measurement?> getMeasurement(String id) async {
    try {
      return await _db.getMeasurement(id);
    } catch (e) {
      debugPrint('Error getting measurement: $e');
      return null;
    }
  }

  Future<bool> addMeasurement({
    required String clientId,
    required String garmentType,
    required Map<String, double> measurements,
    String unit = 'inches',
    String? notes,
  }) async {
    try {
      final measurement = Measurement(
        id: 'MEAS-${DateTime.now().millisecondsSinceEpoch}',
        clientId: clientId,
        garmentType: garmentType,
        measurements: measurements,
        unit: unit,
        notes: notes,
        createdAt: DateTime.now(),
      );

      await _db.createMeasurement(measurement);
      await getClientMeasurements(clientId);
      return true;
    } catch (e) {
      debugPrint('Error adding measurement: $e');
      return false;
    }
  }

  Future<bool> updateMeasurement(Measurement measurement) async {
    try {
      await _db.updateMeasurement(measurement);
      await getClientMeasurements(measurement.clientId);
      return true;
    } catch (e) {
      debugPrint('Error updating measurement: $e');
      return false;
    }
  }

  Measurement? getActiveMeasurement(String clientId, String garmentType) {
    final measurements = _clientMeasurements[clientId];
    if (measurements == null) return null;

    try {
      return measurements.firstWhere(
        (m) => m.garmentType == garmentType && m.isActive,
      );
    } catch (e) {
      return null;
    }
  }

  // Get measurement fields for a specific garment type
  static Map<String, String> getMeasurementFields(String garmentType) {
    switch (garmentType) {
      case GarmentType.shirt:
      case GarmentType.blouse:
        return {
          'length': 'Length',
          'shoulder': 'Shoulder',
          'sleeveLength': 'Sleeve Length',
          'chest': 'Chest/Bust',
          'waist': 'Waist',
          'hip': 'Hip',
          'armhole': 'Armhole',
          'neck': 'Neck',
          'frontNeckDepth': 'Front Neck Depth',
          'backNeckDepth': 'Back Neck Depth',
        };
      
      case GarmentType.churidar:
      case GarmentType.salwar:
        return {
          'topLength': 'Top Length',
          'shoulder': 'Shoulder',
          'sleeveLength': 'Sleeve Length',
          'chest': 'Chest/Bust',
          'waist': 'Waist',
          'hip': 'Hip',
          'bottomLength': 'Bottom Length',
          'bottomWaist': 'Bottom Waist',
          'thigh': 'Thigh',
          'bottomOpening': 'Bottom Opening',
        };
      
      case GarmentType.pants:
        return {
          'length': 'Length',
          'waist': 'Waist',
          'hip': 'Hip',
          'thigh': 'Thigh',
          'knee': 'Knee',
          'bottomOpening': 'Bottom Opening',
          'rise': 'Rise',
        };
      
      case GarmentType.skirt:
        return {
          'length': 'Length',
          'waist': 'Waist',
          'hip': 'Hip',
          'bottomWidth': 'Bottom Width',
        };
      
      default:
        return {
          'length': 'Length',
          'shoulder': 'Shoulder',
          'chest': 'Chest',
          'waist': 'Waist',
          'hip': 'Hip',
        };
    }
  }
}
