import 'package:cloud_firestore/cloud_firestore.dart';

enum SessionStatus {
  scheduled,
  helperEnRoute,
  inProgress,
  completed,
  cancelled,
  disputed
}

class SessionModel {
  final String id;
  final String requestId;
  final String seekerId;
  final String helperId;
  final String seekerName;
  final String helperName;
  final SessionStatus status;
  final DateTime scheduledTime;
  final DateTime? startTime;
  final DateTime? endTime;
  final int? actualDuration; // in minutes
  final String location;
  final double latitude;
  final double longitude;
  final bool locationSharingEnabled;
  final List<String> checkIns;
  final bool emergencyTriggered;
  final String? emergencyNote;
  final double? tipAmount;
  final bool tipPaid;
  final DateTime? tipPaidAt;
  final String? cancellationReason;
  final DateTime createdAt;

  SessionModel({
    required this.id,
    required this.requestId,
    required this.seekerId,
    required this.helperId,
    required this.seekerName,
    required this.helperName,
    this.status = SessionStatus.scheduled,
    required this.scheduledTime,
    this.startTime,
    this.endTime,
    this.actualDuration,
    required this.location,
    required this.latitude,
    required this.longitude,
    this.locationSharingEnabled = false,
    this.checkIns = const [],
    this.emergencyTriggered = false,
    this.emergencyNote,
    this.tipAmount,
    this.tipPaid = false,
    this.tipPaidAt,
    this.cancellationReason,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'requestId': requestId,
      'seekerId': seekerId,
      'helperId': helperId,
      'seekerName': seekerName,
      'helperName': helperName,
      'status': status.toString().split('.').last,
      'scheduledTime': Timestamp.fromDate(scheduledTime),
      'startTime': startTime != null ? Timestamp.fromDate(startTime!) : null,
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'actualDuration': actualDuration,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'locationSharingEnabled': locationSharingEnabled,
      'checkIns': checkIns,
      'emergencyTriggered': emergencyTriggered,
      'emergencyNote': emergencyNote,
      'tipAmount': tipAmount,
      'tipPaid': tipPaid,
      'tipPaidAt': tipPaidAt != null ? Timestamp.fromDate(tipPaidAt!) : null,
      'cancellationReason': cancellationReason,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory SessionModel.fromMap(Map<String, dynamic> map) {
    return SessionModel(
      id: map['id'] ?? '',
      requestId: map['requestId'] ?? '',
      seekerId: map['seekerId'] ?? '',
      helperId: map['helperId'] ?? '',
      seekerName: map['seekerName'] ?? '',
      helperName: map['helperName'] ?? '',
      status: SessionStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => SessionStatus.scheduled,
      ),
      scheduledTime: (map['scheduledTime'] as Timestamp).toDate(),
      startTime: map['startTime'] != null
          ? (map['startTime'] as Timestamp).toDate()
          : null,
      endTime:
          map['endTime'] != null ? (map['endTime'] as Timestamp).toDate() : null,
      actualDuration: map['actualDuration'],
      location: map['location'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      locationSharingEnabled: map['locationSharingEnabled'] ?? false,
      checkIns: List<String>.from(map['checkIns'] ?? []),
      emergencyTriggered: map['emergencyTriggered'] ?? false,
      emergencyNote: map['emergencyNote'],
      tipAmount: map['tipAmount']?.toDouble(),
      tipPaid: map['tipPaid'] ?? false,
      tipPaidAt: map['tipPaidAt'] != null
          ? (map['tipPaidAt'] as Timestamp).toDate()
          : null,
      cancellationReason: map['cancellationReason'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  SessionModel copyWith({
    String? id,
    String? requestId,
    String? seekerId,
    String? helperId,
    String? seekerName,
    String? helperName,
    SessionStatus? status,
    DateTime? scheduledTime,
    DateTime? startTime,
    DateTime? endTime,
    int? actualDuration,
    String? location,
    double? latitude,
    double? longitude,
    bool? locationSharingEnabled,
    List<String>? checkIns,
    bool? emergencyTriggered,
    String? emergencyNote,
    double? tipAmount,
    bool? tipPaid,
    DateTime? tipPaidAt,
    String? cancellationReason,
    DateTime? createdAt,
  }) {
    return SessionModel(
      id: id ?? this.id,
      requestId: requestId ?? this.requestId,
      seekerId: seekerId ?? this.seekerId,
      helperId: helperId ?? this.helperId,
      seekerName: seekerName ?? this.seekerName,
      helperName: helperName ?? this.helperName,
      status: status ?? this.status,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      actualDuration: actualDuration ?? this.actualDuration,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationSharingEnabled: locationSharingEnabled ?? this.locationSharingEnabled,
      checkIns: checkIns ?? this.checkIns,
      emergencyTriggered: emergencyTriggered ?? this.emergencyTriggered,
      emergencyNote: emergencyNote ?? this.emergencyNote,
      tipAmount: tipAmount ?? this.tipAmount,
      tipPaid: tipPaid ?? this.tipPaid,
      tipPaidAt: tipPaidAt ?? this.tipPaidAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
