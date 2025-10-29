import 'package:cloud_firestore/cloud_firestore.dart';

enum HelpCategory {
  movingLifting,
  homeRepairs,
  cleaningOrganizing,
  gardeningOutdoor,
  assemblyInstallation,
  shoppingAssistance,
  fashionStyling,
  homeDecor,
  productSelection,
  eventPlanning,
  companionship,
  listeningTalking,
  griefSupport,
  relationshipAdvice,
  lonelinessSupport,
  minorRepairs,
  technologyHelp,
  cookingMealPrep,
  petCare,
  tutoringLearning,
  groceryShopping,
  documentWork,
  transportation,
  appointmentAccompaniment,
  generalErrands,
  other
}

enum UrgencyLevel { normal, urgent, emergency }

enum RequestStatus {
  pending,
  interested, // helpers have shown interest
  assigned,
  inProgress,
  completed,
  cancelled,
  expired
}

class HelpRequestModel {
  final String id;
  final String seekerId;
  final String seekerName;
  final String? seekerPhotoUrl;
  final HelpCategory category;
  final String title;
  final String description;
  final String location;
  final String address;
  final double latitude;
  final double longitude;
  final DateTime preferredDate;
  final String preferredTime;
  final int estimatedDuration; // in minutes
  final double? suggestedTip;
  final bool isIOYRequest; // "I Owe You One"
  final List<String> photoUrls;
  final UrgencyLevel urgency;
  final RequestStatus status;
  final List<String> interestedHelpers;
  final String? assignedHelperId;
  final String? assignedHelperName;
  final DateTime createdAt;
  final DateTime? assignedAt;
  final DateTime? completedAt;
  final bool isGroupRequest;
  final int helpersNeeded;
  final List<String> tags;

  HelpRequestModel({
    required this.id,
    required this.seekerId,
    required this.seekerName,
    this.seekerPhotoUrl,
    required this.category,
    required this.title,
    required this.description,
    required this.location,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.preferredDate,
    required this.preferredTime,
    required this.estimatedDuration,
    this.suggestedTip,
    this.isIOYRequest = false,
    this.photoUrls = const [],
    this.urgency = UrgencyLevel.normal,
    this.status = RequestStatus.pending,
    this.interestedHelpers = const [],
    this.assignedHelperId,
    this.assignedHelperName,
    DateTime? createdAt,
    this.assignedAt,
    this.completedAt,
    this.isGroupRequest = false,
    this.helpersNeeded = 1,
    this.tags = const [],
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'seekerId': seekerId,
      'seekerName': seekerName,
      'seekerPhotoUrl': seekerPhotoUrl,
      'category': category.toString().split('.').last,
      'title': title,
      'description': description,
      'location': location,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'preferredDate': Timestamp.fromDate(preferredDate),
      'preferredTime': preferredTime,
      'estimatedDuration': estimatedDuration,
      'suggestedTip': suggestedTip,
      'isIOYRequest': isIOYRequest,
      'photoUrls': photoUrls,
      'urgency': urgency.toString().split('.').last,
      'status': status.toString().split('.').last,
      'interestedHelpers': interestedHelpers,
      'assignedHelperId': assignedHelperId,
      'assignedHelperName': assignedHelperName,
      'createdAt': Timestamp.fromDate(createdAt),
      'assignedAt': assignedAt != null ? Timestamp.fromDate(assignedAt!) : null,
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'isGroupRequest': isGroupRequest,
      'helpersNeeded': helpersNeeded,
      'tags': tags,
    };
  }

  factory HelpRequestModel.fromMap(Map<String, dynamic> map) {
    return HelpRequestModel(
      id: map['id'] ?? '',
      seekerId: map['seekerId'] ?? '',
      seekerName: map['seekerName'] ?? '',
      seekerPhotoUrl: map['seekerPhotoUrl'],
      category: HelpCategory.values.firstWhere(
        (e) => e.toString().split('.').last == map['category'],
        orElse: () => HelpCategory.other,
      ),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      address: map['address'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      preferredDate: (map['preferredDate'] as Timestamp).toDate(),
      preferredTime: map['preferredTime'] ?? '',
      estimatedDuration: map['estimatedDuration'] ?? 60,
      suggestedTip: map['suggestedTip']?.toDouble(),
      isIOYRequest: map['isIOYRequest'] ?? false,
      photoUrls: List<String>.from(map['photoUrls'] ?? []),
      urgency: UrgencyLevel.values.firstWhere(
        (e) => e.toString().split('.').last == map['urgency'],
        orElse: () => UrgencyLevel.normal,
      ),
      status: RequestStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => RequestStatus.pending,
      ),
      interestedHelpers: List<String>.from(map['interestedHelpers'] ?? []),
      assignedHelperId: map['assignedHelperId'],
      assignedHelperName: map['assignedHelperName'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      assignedAt: map['assignedAt'] != null
          ? (map['assignedAt'] as Timestamp).toDate()
          : null,
      completedAt: map['completedAt'] != null
          ? (map['completedAt'] as Timestamp).toDate()
          : null,
      isGroupRequest: map['isGroupRequest'] ?? false,
      helpersNeeded: map['helpersNeeded'] ?? 1,
      tags: List<String>.from(map['tags'] ?? []),
    );
  }

  HelpRequestModel copyWith({
    String? id,
    String? seekerId,
    String? seekerName,
    String? seekerPhotoUrl,
    HelpCategory? category,
    String? title,
    String? description,
    String? location,
    String? address,
    double? latitude,
    double? longitude,
    DateTime? preferredDate,
    String? preferredTime,
    int? estimatedDuration,
    double? suggestedTip,
    bool? isIOYRequest,
    List<String>? photoUrls,
    UrgencyLevel? urgency,
    RequestStatus? status,
    List<String>? interestedHelpers,
    String? assignedHelperId,
    String? assignedHelperName,
    DateTime? createdAt,
    DateTime? assignedAt,
    DateTime? completedAt,
    bool? isGroupRequest,
    int? helpersNeeded,
    List<String>? tags,
  }) {
    return HelpRequestModel(
      id: id ?? this.id,
      seekerId: seekerId ?? this.seekerId,
      seekerName: seekerName ?? this.seekerName,
      seekerPhotoUrl: seekerPhotoUrl ?? this.seekerPhotoUrl,
      category: category ?? this.category,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      preferredDate: preferredDate ?? this.preferredDate,
      preferredTime: preferredTime ?? this.preferredTime,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      suggestedTip: suggestedTip ?? this.suggestedTip,
      isIOYRequest: isIOYRequest ?? this.isIOYRequest,
      photoUrls: photoUrls ?? this.photoUrls,
      urgency: urgency ?? this.urgency,
      status: status ?? this.status,
      interestedHelpers: interestedHelpers ?? this.interestedHelpers,
      assignedHelperId: assignedHelperId ?? this.assignedHelperId,
      assignedHelperName: assignedHelperName ?? this.assignedHelperName,
      createdAt: createdAt ?? this.createdAt,
      assignedAt: assignedAt ?? this.assignedAt,
      completedAt: completedAt ?? this.completedAt,
      isGroupRequest: isGroupRequest ?? this.isGroupRequest,
      helpersNeeded: helpersNeeded ?? this.helpersNeeded,
      tags: tags ?? this.tags,
    );
  }

  String getCategoryDisplayName() {
    switch (category) {
      case HelpCategory.movingLifting:
        return 'Moving & Lifting';
      case HelpCategory.homeRepairs:
        return 'Home Repairs';
      case HelpCategory.cleaningOrganizing:
        return 'Cleaning & Organizing';
      case HelpCategory.gardeningOutdoor:
        return 'Gardening & Outdoor';
      case HelpCategory.assemblyInstallation:
        return 'Assembly & Installation';
      case HelpCategory.shoppingAssistance:
        return 'Shopping Assistance';
      case HelpCategory.fashionStyling:
        return 'Fashion & Styling';
      case HelpCategory.homeDecor:
        return 'Home Décor';
      case HelpCategory.productSelection:
        return 'Product Selection';
      case HelpCategory.eventPlanning:
        return 'Event Planning';
      case HelpCategory.companionship:
        return 'Companionship';
      case HelpCategory.listeningTalking:
        return 'Listening & Talking';
      case HelpCategory.griefSupport:
        return 'Grief Support';
      case HelpCategory.relationshipAdvice:
        return 'Relationship Advice';
      case HelpCategory.lonelinessSupport:
        return 'Loneliness Support';
      case HelpCategory.minorRepairs:
        return 'Minor Repairs';
      case HelpCategory.technologyHelp:
        return 'Technology Help';
      case HelpCategory.cookingMealPrep:
        return 'Cooking & Meal Prep';
      case HelpCategory.petCare:
        return 'Pet Care';
      case HelpCategory.tutoringLearning:
        return 'Tutoring & Learning';
      case HelpCategory.groceryShopping:
        return 'Grocery Shopping';
      case HelpCategory.documentWork:
        return 'Document Work';
      case HelpCategory.transportation:
        return 'Transportation';
      case HelpCategory.appointmentAccompaniment:
        return 'Appointment Accompaniment';
      case HelpCategory.generalErrands:
        return 'General Errands';
      case HelpCategory.other:
        return 'Other';
    }
  }
}
