import 'package:flutter/cupertino.dart';

class CategoryField {
  const CategoryField({
    required this.key,
    required this.label,
    required this.placeholder,
    this.options,
    this.keyboardType,
  });

  final String key;
  final String label;
  final String placeholder;
  final List<String>? options; // null => free text
  final TextInputType? keyboardType;
}

class ItemCategory {
  const ItemCategory({
    required this.id,
    required this.name,
    required this.icon,
    this.fields = const [],
  });

  final String id;
  final String name;
  final IconData icon;
  final List<CategoryField> fields;
}

class CategoryCatalog {
  CategoryCatalog._();

  static const ItemCategory telefon = ItemCategory(
    id: 'telefon',
    name: 'Telefon',
    icon: CupertinoIcons.device_phone_portrait,
    fields: [
      CategoryField(
        key: 'marka',
        label: 'Marka',
        placeholder: 'Örn. Apple, Samsung',
      ),
      CategoryField(
        key: 'model',
        label: 'Model',
        placeholder: 'Örn. iPhone 15',
      ),
      CategoryField(
        key: 'depolama',
        label: 'Depolama',
        placeholder: 'Seçiniz',
        options: ['64 GB', '128 GB', '256 GB', '512 GB', '1 TB', 'Diğer'],
      ),
      CategoryField(
        key: 'renk',
        label: 'Renk',
        placeholder: 'Örn. Siyah',
      ),
      CategoryField(
        key: 'durum',
        label: 'Durum',
        placeholder: 'Seçiniz',
        options: ['Sıfır', 'Çok İyi', 'İyi', 'Orta', 'Tamir Gerekli'],
      ),
    ],
  );

  static const ItemCategory araba = ItemCategory(
    id: 'araba',
    name: 'Araba',
    icon: CupertinoIcons.car_detailed,
    fields: [
      CategoryField(key: 'marka', label: 'Marka', placeholder: 'Örn. BMW'),
      CategoryField(key: 'model', label: 'Model', placeholder: 'Örn. 320i'),
      CategoryField(
        key: 'yil',
        label: 'Yıl',
        placeholder: 'Örn. 2018',
        keyboardType: TextInputType.number,
      ),
      CategoryField(key: 'renk', label: 'Renk', placeholder: 'Örn. Beyaz'),
      CategoryField(
        key: 'kilometre',
        label: 'Kilometre',
        placeholder: 'Örn. 85000',
        keyboardType: TextInputType.number,
      ),
    ],
  );

  static const ItemCategory elektronik = ItemCategory(
    id: 'elektronik',
    name: 'Elektronik',
    icon: CupertinoIcons.device_laptop,
    fields: [
      CategoryField(key: 'marka', label: 'Marka', placeholder: 'Örn. Sony'),
      CategoryField(key: 'model', label: 'Model', placeholder: 'Örn. WH-1000XM5'),
      CategoryField(
        key: 'durum',
        label: 'Durum',
        placeholder: 'Seçiniz',
        options: ['Sıfır', 'Çok İyi', 'İyi', 'Orta', 'Tamir Gerekli'],
      ),
    ],
  );

  static const ItemCategory giyim = ItemCategory(
    id: 'giyim',
    name: 'Giyim',
    icon: CupertinoIcons.tag,
    fields: [
      CategoryField(key: 'marka', label: 'Marka', placeholder: 'Örn. Nike'),
      CategoryField(key: 'beden', label: 'Beden', placeholder: 'Örn. M, 42'),
      CategoryField(key: 'renk', label: 'Renk', placeholder: 'Örn. Lacivert'),
      CategoryField(
        key: 'durum',
        label: 'Durum',
        placeholder: 'Seçiniz',
        options: ['Sıfır', 'Az Kullanılmış', 'İyi', 'Orta'],
      ),
    ],
  );

  static const ItemCategory koleksiyon = ItemCategory(
    id: 'koleksiyon',
    name: 'Koleksiyon / Kart',
    icon: CupertinoIcons.square_grid_2x2,
    fields: [
      CategoryField(key: 'tur', label: 'Tür', placeholder: 'Örn. Pokemon kartı'),
      CategoryField(key: 'nadirlik', label: 'Nadirlik', placeholder: 'Örn. Holo Rare'),
      CategoryField(
        key: 'durum',
        label: 'Durum',
        placeholder: 'Seçiniz',
        options: ['Mükemmel', 'İyi', 'Orta', 'Yıpranmış'],
      ),
    ],
  );

  static const ItemCategory aksesuar = ItemCategory(
    id: 'aksesuar',
    name: 'Aksesuar',
    icon: CupertinoIcons.tag,
    fields: [
      CategoryField(key: 'tur', label: 'Tür', placeholder: 'Örn. Anahtarlık'),
      CategoryField(key: 'malzeme', label: 'Malzeme', placeholder: 'Örn. Deri, Metal'),
    ],
  );

  static const ItemCategory diger = ItemCategory(
    id: 'diger',
    name: 'Diğer',
    icon: CupertinoIcons.square_grid_2x2,
    fields: [],
  );

  static const List<ItemCategory> all = [
    telefon,
    araba,
    elektronik,
    giyim,
    koleksiyon,
    aksesuar,
    diger,
  ];

  static ItemCategory byId(String id) => all.firstWhere(
        (c) => c.id == id,
        orElse: () => diger,
      );
}
