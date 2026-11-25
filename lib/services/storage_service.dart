import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  StorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;
  final _uuid = const Uuid();

  Future<String> uploadItemImage({
    required String ownerId,
    required File file,
  }) async {
    final id = _uuid.v4();
    final ref = _storage.ref().child('items/$ownerId/$id.jpg');
    await ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
    return ref.getDownloadURL();
  }

  Future<String> uploadProfilePhoto({
    required String uid,
    required File file,
  }) async {
    final ref = _storage.ref().child('users/$uid/profile.jpg');
    await ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
    return ref.getDownloadURL();
  }
}
