import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { seeker, helper, both }

enum VerificationLevel { basic, enhanced, backgroundCheck }

class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String? profilePhotoUrl;
  final String? bio;
  final DateTime dateOfBirth;
  final String city;
  final String area;
  final List<String> languages;
  final List<String> skills;
  final UserRole role;
  final bool isHelper;
  final bool isVerified;
  final VerificationLevel verificationLevel;
  final double rating;
  final int totalHelpsGiven;
  final int totalHelpsReceived;
  final int totalReviews;
  final List<String> categories;
  final bool isAvailable;
  final double serviceRadius; // in kilometers
  final DateTime createdAt;
  final DateTime? lastActive;
  final List<String> badges;
  final String? helperLevel;
  final bool isBlocked;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.profilePhotoUrl,
    this.bio,
    required this.dateOfBirth,
    required this.city,
    required this.area,
    this.languages = const ['English'],
    this.skills = const [],
    this.role = UserRole.seeker,
    this.isHelper = false,
    this.isVerified = false,
    this.verificationLevel = VerificationLevel.basic,
    this.rating = 0.0,
    this.totalHelpsGiven = 0,
    this.totalHelpsReceived = 0,
    this.totalReviews = 0,
    this.categories = const [],
    this.isAvailable = false,
    this.serviceRadius = 10.0,
    DateTime? createdAt,
    this.lastActive,
    this.badges = const [],
    this.helperLevel,
    this.isBlocked = false,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'profilePhotoUrl': profilePhotoUrl,
      'bio': bio,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'city': city,
      'area': area,
      'languages': languages,
      'skills': skills,
      'role': role.toString().split('.').last,
      'isHelper': isHelper,
      'isVerified': isVerified,
      'verificationLevel': verificationLevel.toString().split('.').last,
      'rating': rating,
      'totalHelpsGiven': totalHelpsGiven,
      'totalHelpsReceived': totalHelpsReceived,
      'totalReviews': totalReviews,
      'categories': categories,
      'isAvailable': isAvailable,
      'serviceRadius': serviceRadius,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActive': lastActive != null ? Timestamp.fromDate(lastActive!) : null,
      'badges': badges,
      'helperLevel': helperLevel,
      'isBlocked': isBlocked,
    };
  }

  // Create from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      profilePhotoUrl: map['profilePhotoUrl'],
      bio: map['bio'],
      dateOfBirth: (map['dateOfBirth'] as Timestamp).toDate(),
      city: map['city'] ?? '',
      area: map['area'] ?? '',
      languages: List<String>.from(map['languages'] ?? ['English']),
      skills: List<String>.from(map['skills'] ?? []),
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == map['role'],
        orElse: () => UserRole.seeker,
      ),
      isHelper: map['isHelper'] ?? false,
      isVerified: map['isVerified'] ?? false,
      verificationLevel: VerificationLevel.values.firstWhere(
        (e) => e.toString().split('.').last == map['verificationLevel'],
        orElse: () => VerificationLevel.basic,
      ),
      rating: (map['rating'] ?? 0.0).toDouble(),
      totalHelpsGiven: map['totalHelpsGiven'] ?? 0,
      totalHelpsReceived: map['totalHelpsReceived'] ?? 0,
      totalReviews: map['totalReviews'] ?? 0,
      categories: List<String>.from(map['categories'] ?? []),
      isAvailable: map['isAvailable'] ?? false,
      serviceRadius: (map['serviceRadius'] ?? 10.0).toDouble(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      lastActive: map['lastActive'] != null
          ? (map['lastActive'] as Timestamp).toDate()
          : null,
      badges: List<String>.from(map['badges'] ?? []),
      helperLevel: map['helperLevel'],
      isBlocked: map['isBlocked'] ?? false,
    );
  }

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? profilePhotoUrl,
    String? bio,
    DateTime? dateOfBirth,
    String? city,
    String? area,
    List<String>? languages,
    List<String>? skills,
    UserRole? role,
    bool? isHelper,
    bool? isVerified,
    VerificationLevel? verificationLevel,
    double? rating,
    int? totalHelpsGiven,
    int? totalHelpsReceived,
    int? totalReviews,
    List<String>? categories,
    bool? isAvailable,
    double? serviceRadius,
    DateTime? createdAt,
    DateTime? lastActive,
    List<String>? badges,
    String? helperLevel,
    bool? isBlocked,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      bio: bio ?? this.bio,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      city: city ?? this.city,
      area: area ?? this.area,
      languages: languages ?? this.languages,
      skills: skills ?? this.skills,
      role: role ?? this.role,
      isHelper: isHelper ?? this.isHelper,
      isVerified: isVerified ?? this.isVerified,
      verificationLevel: verificationLevel ?? this.verificationLevel,
      rating: rating ?? this.rating,
      totalHelpsGiven: totalHelpsGiven ?? this.totalHelpsGiven,
      totalHelpsReceived: totalHelpsReceived ?? this.totalHelpsReceived,
      totalReviews: totalReviews ?? this.totalReviews,
      categories: categories ?? this.categories,
      isAvailable: isAvailable ?? this.isAvailable,
      serviceRadius: serviceRadius ?? this.serviceRadius,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
      badges: badges ?? this.badges,
      helperLevel: helperLevel ?? this.helperLevel,
      isBlocked: isBlocked ?? this.isBlocked,
    );
  }

  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  String getHelperLevel() {
    if (totalHelpsGiven >= 500) return 'Master Helper';
    if (totalHelpsGiven >= 150) return 'Expert Helper';
    if (totalHelpsGiven >= 50) return 'Experienced Helper';
    if (totalHelpsGiven >= 10) return 'Regular Helper';
    return 'New Helper';
  }
}
