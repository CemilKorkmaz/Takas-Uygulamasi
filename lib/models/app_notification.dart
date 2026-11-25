import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  offerReceived,
  offerAccepted,
  offerRejected,
  trackingUpdated,
  reviewReceived,
  system,
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
    this.relatedOfferId,
    this.relatedItemId,
  });

  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final String? relatedOfferId;
  final String? relatedItemId;

  factory AppNotification.fromMap(Map<String, dynamic> map, String id) {
    return AppNotification(
      id: id,
      userId: (map['userId'] ?? '') as String,
      type: NotificationType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => NotificationType.system,
      ),
      title: (map['title'] ?? '') as String,
      body: (map['body'] ?? '') as String,
      createdAt: _toDate(map['createdAt']),
      isRead: (map['isRead'] ?? false) as bool,
      relatedOfferId: map['relatedOfferId'] as String?,
      relatedItemId: map['relatedItemId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type.name,
      'title': title,
      'body': body,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
      'relatedOfferId': relatedOfferId,
      'relatedItemId': relatedItemId,
    };
  }

  static DateTime _toDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }
}
