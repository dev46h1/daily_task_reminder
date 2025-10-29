import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String sessionId;
  final String reviewerId;
  final String reviewerName;
  final String revieweeId;
  final String revieweeName;
  final bool isHelperReview; // true if reviewing helper, false if reviewing seeker
  final double overallRating;
  final double? qualityRating;
  final double? professionalismRating;
  final double? communicationRating;
  final double? timelinessRating;
  final double? respectRating;
  final double? compensationRating;
  final String? writtenReview;
  final bool wouldRecommend;
  final DateTime createdAt;
  final String? response;
  final DateTime? responseAt;

  ReviewModel({
    required this.id,
    required this.sessionId,
    required this.reviewerId,
    required this.reviewerName,
    required this.revieweeId,
    required this.revieweeName,
    required this.isHelperReview,
    required this.overallRating,
    this.qualityRating,
    this.professionalismRating,
    this.communicationRating,
    this.timelinessRating,
    this.respectRating,
    this.compensationRating,
    this.writtenReview,
    required this.wouldRecommend,
    DateTime? createdAt,
    this.response,
    this.responseAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sessionId': sessionId,
      'reviewerId': reviewerId,
      'reviewerName': reviewerName,
      'revieweeId': revieweeId,
      'revieweeName': revieweeName,
      'isHelperReview': isHelperReview,
      'overallRating': overallRating,
      'qualityRating': qualityRating,
      'professionalismRating': professionalismRating,
      'communicationRating': communicationRating,
      'timelinessRating': timelinessRating,
      'respectRating': respectRating,
      'compensationRating': compensationRating,
      'writtenReview': writtenReview,
      'wouldRecommend': wouldRecommend,
      'createdAt': Timestamp.fromDate(createdAt),
      'response': response,
      'responseAt': responseAt != null ? Timestamp.fromDate(responseAt!) : null,
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['id'] ?? '',
      sessionId: map['sessionId'] ?? '',
      reviewerId: map['reviewerId'] ?? '',
      reviewerName: map['reviewerName'] ?? '',
      revieweeId: map['revieweeId'] ?? '',
      revieweeName: map['revieweeName'] ?? '',
      isHelperReview: map['isHelperReview'] ?? true,
      overallRating: (map['overallRating'] ?? 0.0).toDouble(),
      qualityRating: map['qualityRating']?.toDouble(),
      professionalismRating: map['professionalismRating']?.toDouble(),
      communicationRating: map['communicationRating']?.toDouble(),
      timelinessRating: map['timelinessRating']?.toDouble(),
      respectRating: map['respectRating']?.toDouble(),
      compensationRating: map['compensationRating']?.toDouble(),
      writtenReview: map['writtenReview'],
      wouldRecommend: map['wouldRecommend'] ?? true,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      response: map['response'],
      responseAt: map['responseAt'] != null
          ? (map['responseAt'] as Timestamp).toDate()
          : null,
    );
  }

  ReviewModel copyWith({
    String? id,
    String? sessionId,
    String? reviewerId,
    String? reviewerName,
    String? revieweeId,
    String? revieweeName,
    bool? isHelperReview,
    double? overallRating,
    double? qualityRating,
    double? professionalismRating,
    double? communicationRating,
    double? timelinessRating,
    double? respectRating,
    double? compensationRating,
    String? writtenReview,
    bool? wouldRecommend,
    DateTime? createdAt,
    String? response,
    DateTime? responseAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      reviewerId: reviewerId ?? this.reviewerId,
      reviewerName: reviewerName ?? this.reviewerName,
      revieweeId: revieweeId ?? this.revieweeId,
      revieweeName: revieweeName ?? this.revieweeName,
      isHelperReview: isHelperReview ?? this.isHelperReview,
      overallRating: overallRating ?? this.overallRating,
      qualityRating: qualityRating ?? this.qualityRating,
      professionalismRating: professionalismRating ?? this.professionalismRating,
      communicationRating: communicationRating ?? this.communicationRating,
      timelinessRating: timelinessRating ?? this.timelinessRating,
      respectRating: respectRating ?? this.respectRating,
      compensationRating: compensationRating ?? this.compensationRating,
      writtenReview: writtenReview ?? this.writtenReview,
      wouldRecommend: wouldRecommend ?? this.wouldRecommend,
      createdAt: createdAt ?? this.createdAt,
      response: response ?? this.response,
      responseAt: responseAt ?? this.responseAt,
    );
  }
}
