import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  const Item({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    required this.ownerPhotoUrl,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.attributes,
    required this.imageUrls,
    required this.createdAt,
    this.isActive = true,
  });

  final String id;
  final String ownerId;
  final String ownerName;
  final String? ownerPhotoUrl;
  final String title;
  final String description;
  final String categoryId;
  final Map<String, dynamic> attributes;
  final List<String> imageUrls;
  final DateTime createdAt;
  final bool isActive;

  factory Item.fromMap(Map<String, dynamic> map, String id) {
    return Item(
      id: id,
      ownerId: (map['ownerId'] ?? '') as String,
      ownerName: (map['ownerName'] ?? '') as String,
      ownerPhotoUrl: map['ownerPhotoUrl'] as String?,
      title: (map['title'] ?? '') as String,
      description: (map['description'] ?? '') as String,
      categoryId: (map['categoryId'] ?? 'diger') as String,
      attributes: Map<String, dynamic>.from((map['attributes'] ?? {}) as Map),
      imageUrls: List<String>.from((map['imageUrls'] ?? const []) as List),
      createdAt: _toDate(map['createdAt']),
      isActive: (map['isActive'] ?? true) as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'ownerName': ownerName,
      'ownerPhotoUrl': ownerPhotoUrl,
      'title': title,
      'description': description,
      'categoryId': categoryId,
      'attributes': attributes,
      'imageUrls': imageUrls,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
    };
  }

  static DateTime _toDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }
}
