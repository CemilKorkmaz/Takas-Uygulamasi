import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';
import '../models/review.dart';

class UserRepository {
  UserRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  Stream<AppUser?> watchUser(String uid) {
    return _users.doc(uid).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return AppUser.fromMap(snap.data()!, snap.id);
    });
  }

  Future<AppUser?> getUser(String uid) async {
    final snap = await _users.doc(uid).get();
    if (!snap.exists || snap.data() == null) return null;
    return AppUser.fromMap(snap.data()!, snap.id);
  }

  Future<void> updateProfile(String uid, Map<String, dynamic> data) {
    return _users.doc(uid).set(data, SetOptions(merge: true));
  }

  Stream<List<Review>> watchReviewsForUser(String uid) {
    return _db
        .collection('reviews')
        .where('reviewedUserId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => Review.fromMap(d.data(), d.id)).toList());
  }
}
