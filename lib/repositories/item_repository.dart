import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/item.dart';

class ItemRepository {
  ItemRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _items =>
      _db.collection('items');

  Stream<List<Item>> watchFeed({String? excludeOwnerId}) {
    Query<Map<String, dynamic>> query =
        _items.where('isActive', isEqualTo: true).orderBy('createdAt', descending: true);
    return query.snapshots().map((snap) {
      final items = snap.docs.map((d) => Item.fromMap(d.data(), d.id)).toList();
      if (excludeOwnerId == null) return items;
      return items.where((i) => i.ownerId != excludeOwnerId).toList();
    });
  }

  Stream<List<Item>> watchUserItems(String ownerId) {
    return _items
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Item.fromMap(d.data(), d.id)).toList());
  }

  Future<Item?> getItem(String id) async {
    final snap = await _items.doc(id).get();
    if (!snap.exists || snap.data() == null) return null;
    return Item.fromMap(snap.data()!, snap.id);
  }

  Stream<Item?> watchItem(String id) {
    return _items.doc(id).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return Item.fromMap(snap.data()!, snap.id);
    });
  }

  Future<String> createItem(Item item) async {
    final ref = await _items.add(item.toMap());
    return ref.id;
  }

  Future<void> updateItem(String id, Map<String, dynamic> data) {
    return _items.doc(id).set(data, SetOptions(merge: true));
  }

  Future<void> deleteItem(String id) {
    return _items.doc(id).update({'isActive': false});
  }
}
