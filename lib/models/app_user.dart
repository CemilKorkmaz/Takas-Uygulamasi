import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.photoUrl,
    required this.bio,
    required this.city,
    required this.createdAt,
    this.ratingAverage = 0,
    this.ratingCount = 0,
  });

  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String? bio;
  final String? city;
  final DateTime createdAt;
  final double ratingAverage;
  final int ratingCount;

  factory AppUser.fromMap(Map<String, dynamic> map, String id) {
    return AppUser(
      uid: id,
      email: (map['email'] ?? '') as String,
      displayName: (map['displayName'] ?? '') as String,
      photoUrl: map['photoUrl'] as String?,
      bio: map['bio'] as String?,
      city: map['city'] as String?,
      createdAt: _toDate(map['createdAt']),
      ratingAverage: ((map['ratingAverage'] ?? 0) as num).toDouble(),
      ratingCount: ((map['ratingCount'] ?? 0) as num).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'bio': bio,
      'city': city,
      'createdAt': Timestamp.fromDate(createdAt),
      'ratingAverage': ratingAverage,
      'ratingCount': ratingCount,
    };
  }

  AppUser copyWith({
    String? displayName,
    String? photoUrl,
    String? bio,
    String? city,
    double? ratingAverage,
    int? ratingCount,
  }) {
    return AppUser(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      city: city ?? this.city,
      createdAt: createdAt,
      ratingAverage: ratingAverage ?? this.ratingAverage,
      ratingCount: ratingCount ?? this.ratingCount,
    );
  }

  static DateTime _toDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }
}
