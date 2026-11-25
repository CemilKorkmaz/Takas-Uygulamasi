import 'package:cloud_firestore/cloud_firestore.dart';

enum SwapOfferStatus {
  pending('pending', 'Beklemede'),
  accepted('accepted', 'Kabul Edildi'),
  rejected('rejected', 'Reddedildi'),
  cancelled('cancelled', 'İptal Edildi'),
  completed('completed', 'Tamamlandı');

  const SwapOfferStatus(this.value, this.label);
  final String value;
  final String label;

  static SwapOfferStatus fromValue(String? value) {
    return SwapOfferStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => SwapOfferStatus.pending,
    );
  }
}

class SwapOffer {
  const SwapOffer({
    required this.id,
    required this.requesterId,
    required this.requesterName,
    required this.ownerId,
    required this.ownerName,
    required this.requestedItemId,
    required this.requestedItemTitle,
    required this.requestedItemImage,
    required this.offeredItemId,
    required this.offeredItemTitle,
    required this.offeredItemImage,
    required this.status,
    required this.createdAt,
    this.message,
    this.respondedAt,
    this.shippingDeadline,
    this.requesterTrackingNumber,
    this.ownerTrackingNumber,
    this.requesterShippedAt,
    this.ownerShippedAt,
    this.requesterReviewed = false,
    this.ownerReviewed = false,
  });

  final String id;
  final String requesterId;
  final String requesterName;
  final String ownerId;
  final String ownerName;
  final String requestedItemId;
  final String requestedItemTitle;
  final String? requestedItemImage;
  final String offeredItemId;
  final String offeredItemTitle;
  final String? offeredItemImage;
  final SwapOfferStatus status;
  final DateTime createdAt;
  final String? message;
  final DateTime? respondedAt;
  final DateTime? shippingDeadline;
  final String? requesterTrackingNumber;
  final String? ownerTrackingNumber;
  final DateTime? requesterShippedAt;
  final DateTime? ownerShippedAt;
  final bool requesterReviewed;
  final bool ownerReviewed;

  bool involves(String uid) => requesterId == uid || ownerId == uid;
  bool isRequester(String uid) => requesterId == uid;

  factory SwapOffer.fromMap(Map<String, dynamic> map, String id) {
    return SwapOffer(
      id: id,
      requesterId: (map['requesterId'] ?? '') as String,
      requesterName: (map['requesterName'] ?? '') as String,
      ownerId: (map['ownerId'] ?? '') as String,
      ownerName: (map['ownerName'] ?? '') as String,
      requestedItemId: (map['requestedItemId'] ?? '') as String,
      requestedItemTitle: (map['requestedItemTitle'] ?? '') as String,
      requestedItemImage: map['requestedItemImage'] as String?,
      offeredItemId: (map['offeredItemId'] ?? '') as String,
      offeredItemTitle: (map['offeredItemTitle'] ?? '') as String,
      offeredItemImage: map['offeredItemImage'] as String?,
      status: SwapOfferStatus.fromValue(map['status'] as String?),
      createdAt: _toDate(map['createdAt']) ?? DateTime.now(),
      message: map['message'] as String?,
      respondedAt: _toDate(map['respondedAt']),
      shippingDeadline: _toDate(map['shippingDeadline']),
      requesterTrackingNumber: map['requesterTrackingNumber'] as String?,
      ownerTrackingNumber: map['ownerTrackingNumber'] as String?,
      requesterShippedAt: _toDate(map['requesterShippedAt']),
      ownerShippedAt: _toDate(map['ownerShippedAt']),
      requesterReviewed: (map['requesterReviewed'] ?? false) as bool,
      ownerReviewed: (map['ownerReviewed'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'requesterId': requesterId,
      'requesterName': requesterName,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'requestedItemId': requestedItemId,
      'requestedItemTitle': requestedItemTitle,
      'requestedItemImage': requestedItemImage,
      'offeredItemId': offeredItemId,
      'offeredItemTitle': offeredItemTitle,
      'offeredItemImage': offeredItemImage,
      'status': status.value,
      'createdAt': Timestamp.fromDate(createdAt),
      'message': message,
      'respondedAt': respondedAt == null ? null : Timestamp.fromDate(respondedAt!),
      'shippingDeadline': shippingDeadline == null ? null : Timestamp.fromDate(shippingDeadline!),
      'requesterTrackingNumber': requesterTrackingNumber,
      'ownerTrackingNumber': ownerTrackingNumber,
      'requesterShippedAt': requesterShippedAt == null ? null : Timestamp.fromDate(requesterShippedAt!),
      'ownerShippedAt': ownerShippedAt == null ? null : Timestamp.fromDate(ownerShippedAt!),
      'requesterReviewed': requesterReviewed,
      'ownerReviewed': ownerReviewed,
    };
  }

  static DateTime? _toDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
