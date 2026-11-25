import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  const Review({
    required this.id,
    required this.offerId,
    required this.reviewerId,
    required this.reviewerName,
    required this.reviewedUserId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  final String id;
  final String offerId;
  final String reviewerId;
  final String reviewerName;
  final String reviewedUserId;
  final int rating; // 1-5
  final String comment;
  final DateTime createdAt;

  factory Review.fromMap(Map<String, dynamic> map, String id) {
    return Review(
      id: id,
      offerId: (map['offerId'] ?? '') as String,
      reviewerId: (map['reviewerId'] ?? '') as String,
      reviewerName: (map['reviewerName'] ?? '') as String,
      reviewedUserId: (map['reviewedUserId'] ?? '') as String,
      rating: ((map['rating'] ?? 0) as num).toInt(),
      comment: (map['comment'] ?? '') as String,
      createdAt: _toDate(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'offerId': offerId,
      'reviewerId': reviewerId,
      'reviewerName': reviewerName,
      'reviewedUserId': reviewedUserId,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static DateTime _toDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }
}
