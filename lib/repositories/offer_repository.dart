import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_notification.dart';
import '../models/review.dart';
import '../models/swap_offer.dart';

class OfferRepository {
  OfferRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _offers =>
      _db.collection('offers');
  CollectionReference<Map<String, dynamic>> get _notifications =>
      _db.collection('notifications');
  CollectionReference<Map<String, dynamic>> get _reviews =>
      _db.collection('reviews');
  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  Stream<List<SwapOffer>> watchIncomingOffers(String uid) {
    return _offers
        .where('ownerId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => SwapOffer.fromMap(d.data(), d.id)).toList());
  }

  Stream<List<SwapOffer>> watchOutgoingOffers(String uid) {
    return _offers
        .where('requesterId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => SwapOffer.fromMap(d.data(), d.id)).toList());
  }

  Stream<SwapOffer?> watchOffer(String offerId) {
    return _offers.doc(offerId).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return SwapOffer.fromMap(snap.data()!, snap.id);
    });
  }

  Future<String> createOffer(SwapOffer offer) async {
    final ref = await _offers.add(offer.toMap());
    await _createNotification(
      userId: offer.ownerId,
      type: NotificationType.offerReceived,
      title: 'Yeni Takas Teklifi',
      body: '${offer.requesterName}, "${offer.requestedItemTitle}" için takas teklifi gönderdi.',
      relatedOfferId: ref.id,
      relatedItemId: offer.requestedItemId,
    );
    return ref.id;
  }

  Future<void> acceptOffer(SwapOffer offer) async {
    final now = DateTime.now();
    final deadline = now.add(const Duration(days: 5));
    await _offers.doc(offer.id).update({
      'status': SwapOfferStatus.accepted.value,
      'respondedAt': Timestamp.fromDate(now),
      'shippingDeadline': Timestamp.fromDate(deadline),
    });
    await _createNotification(
      userId: offer.requesterId,
      type: NotificationType.offerAccepted,
      title: 'Teklif Kabul Edildi',
      body: '"${offer.requestedItemTitle}" için takas teklifin kabul edildi. 5 gün içinde kargoya ver.',
      relatedOfferId: offer.id,
    );
  }

  Future<void> rejectOffer(SwapOffer offer) async {
    await _offers.doc(offer.id).update({
      'status': SwapOfferStatus.rejected.value,
      'respondedAt': Timestamp.fromDate(DateTime.now()),
    });
    await _createNotification(
      userId: offer.requesterId,
      type: NotificationType.offerRejected,
      title: 'Teklif Reddedildi',
      body: '"${offer.requestedItemTitle}" için takas teklifin reddedildi.',
      relatedOfferId: offer.id,
    );
  }

  Future<void> submitTracking({
    required SwapOffer offer,
    required String uid,
    required String trackingNumber,
  }) async {
    final isRequester = offer.isRequester(uid);
    final field = isRequester ? 'requesterTrackingNumber' : 'ownerTrackingNumber';
    final shippedField = isRequester ? 'requesterShippedAt' : 'ownerShippedAt';
    await _offers.doc(offer.id).update({
      field: trackingNumber.trim(),
      shippedField: Timestamp.fromDate(DateTime.now()),
    });
    final otherUserId = isRequester ? offer.ownerId : offer.requesterId;
    await _createNotification(
      userId: otherUserId,
      type: NotificationType.trackingUpdated,
      title: 'Kargo Takip Numarası Girildi',
      body: 'Karşı taraf kargo takip numarasını ekledi: ${trackingNumber.trim()}',
      relatedOfferId: offer.id,
    );
  }

  Future<void> submitReview({
    required SwapOffer offer,
    required String reviewerId,
    required String reviewerName,
    required int rating,
    required String comment,
  }) async {
    final isRequester = offer.isRequester(reviewerId);
    final reviewedUserId = isRequester ? offer.ownerId : offer.requesterId;
    final reviewFlagField = isRequester ? 'requesterReviewed' : 'ownerReviewed';

    await _db.runTransaction((tx) async {
      final offerRef = _offers.doc(offer.id);
      final offerSnap = await tx.get(offerRef);
      final offerData = offerSnap.data() ?? {};
      final alreadyReviewed = (offerData[reviewFlagField] ?? false) as bool;
      if (alreadyReviewed) {
        throw StateError('Bu takas için zaten değerlendirme yaptınız.');
      }

      final reviewRef = _reviews.doc();
      tx.set(reviewRef, Review(
        id: reviewRef.id,
        offerId: offer.id,
        reviewerId: reviewerId,
        reviewerName: reviewerName,
        reviewedUserId: reviewedUserId,
        rating: rating,
        comment: comment.trim(),
        createdAt: DateTime.now(),
      ).toMap());

      final userRef = _users.doc(reviewedUserId);
      final userSnap = await tx.get(userRef);
      final userData = userSnap.data() ?? {};
      final currentAvg = ((userData['ratingAverage'] ?? 0) as num).toDouble();
      final currentCount = ((userData['ratingCount'] ?? 0) as num).toInt();
      final newCount = currentCount + 1;
      final newAvg = ((currentAvg * currentCount) + rating) / newCount;
      tx.set(userRef, {
        'ratingAverage': newAvg,
        'ratingCount': newCount,
      }, SetOptions(merge: true));

      final otherReviewed = isRequester
          ? ((offerData['ownerReviewed'] ?? false) as bool)
          : ((offerData['requesterReviewed'] ?? false) as bool);

      tx.update(offerRef, {
        reviewFlagField: true,
        if (otherReviewed) 'status': SwapOfferStatus.completed.value,
      });
    });

    await _createNotification(
      userId: reviewedUserId,
      type: NotificationType.reviewReceived,
      title: 'Yeni Değerlendirme',
      body: '$reviewerName sana $rating yıldız verdi.',
      relatedOfferId: offer.id,
    );
  }

  Future<void> _createNotification({
    required String userId,
    required NotificationType type,
    required String title,
    required String body,
    String? relatedOfferId,
    String? relatedItemId,
  }) {
    return _notifications.add({
      'userId': userId,
      'type': type.name,
      'title': title,
      'body': body,
      'createdAt': Timestamp.fromDate(DateTime.now()),
      'isRead': false,
      'relatedOfferId': relatedOfferId,
      'relatedItemId': relatedItemId,
    });
  }
}
