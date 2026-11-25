import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_notification.dart';

class NotificationRepository {
  NotificationRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _notifications =>
      _db.collection('notifications');

  Stream<List<AppNotification>> watchNotifications(String uid) {
    return _notifications
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => AppNotification.fromMap(d.data(), d.id)).toList());
  }

  Stream<int> watchUnreadCount(String uid) {
    return _notifications
        .where('userId', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((s) => s.docs.length);
  }

  Future<void> markAsRead(String id) {
    return _notifications.doc(id).update({'isRead': true});
  }

  Future<void> markAllAsRead(String uid) async {
    final snap = await _notifications
        .where('userId', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }
}
