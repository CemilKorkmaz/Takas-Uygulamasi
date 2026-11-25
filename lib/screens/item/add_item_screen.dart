import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/categories.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass.dart';
import '../../models/item.dart';
import '../../providers/providers.dart';

class AddItemScreen extends ConsumerStatefulWidget {
  const AddItemScreen({super.key});

  @override
  ConsumerState<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends ConsumerState<AddItemScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final Map<String, TextEditingController> _attrCtrls = {};
  ItemCategory _category = CategoryCatalog.telefon;
  final List<XFile> _images = [];
  bool _saving = false;
  final _picker = ImagePicker();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    for (final c in _attrCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _attrCtrl(String key) {
    return _attrCtrls.putIfAbsent(key, () => TextEditingController());
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 80, maxWidth: 1600);
    if (picked.isEmpty) return;
    setState(() {
      _images.addAll(picked);
      if (_images.length > 6) _images.removeRange(6, _images.length);
    });
  }

  Future<void> _save() async {
    final user = ref.read(currentUserDocProvider).valueOrNull;
    final authUser = ref.read(authServiceProvider).currentUser;
    if (user == null || authUser == null) {
      _error('Oturum bulunamadı.');
      return;
    }
    final title = _titleCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    if (title.isEmpty || desc.isEmpty) {
      _error('Başlık ve açıklama zorunludur.');
      return;
    }

    setState(() => _saving = true);
    try {
      final storage = ref.read(storageServiceProvider);
      final urls = <String>[];
      for (final img in _images) {
        final url = await storage.uploadItemImage(ownerId: authUser.uid, file: File(img.path));
        urls.add(url);
      }

      final attrs = <String, dynamic>{};
      for (final field in _category.fields) {
        final val = _attrCtrl(field.key).text.trim();
        if (val.isNotEmpty) attrs[field.key] = val;
      }

      final item = Item(
        id: '',
        ownerId: authUser.uid,
        ownerName: user.displayName,
        ownerPhotoUrl: user.photoUrl,
        title: title,
        description: desc,
        categoryId: _category.id,
        attributes: attrs,
        imageUrls: urls,
        createdAt: DateTime.now(),
      );
      await ref.read(itemRepositoryProvider).createItem(item);
      if (mounted) context.pop();
    } catch (e) {
      _error('Ürün kaydedilemedi: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _error(String msg) {
    showCupertinoDialog<void>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Hata'),
        content: Text(msg),
        actions: [
          CupertinoDialogAction(child: const Text('Tamam'), onPressed: () => Navigator.pop(context)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: const Color(0x00000000),
        border: null,
        middle: const Text('Ürün Ekle', style: TextStyle(color: AppColors.textPrimary)),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => context.pop(),
          child: const Icon(CupertinoIcons.back, color: AppColors.textPrimary),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          GlassSurface(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Fotoğraflar', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (int i = 0; i < _images.length; i++)
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.file(File(_images[i].path), width: 88, height: 88, fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => setState(() => _images.removeAt(i)),
                              child: Container(
                                decoration: const BoxDecoration(color: Color(0xAA000000), shape: BoxShape.circle),
                                padding: const EdgeInsets.all(4),
                                child: const Icon(CupertinoIcons.xmark, size: 12, color: CupertinoColors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (_images.length < 6)
                      GestureDetector(
                        onTap: _pickImages,
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: const Color(0x1AFFFFFF),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0x33FFFFFF)),
                          ),
                          child: const Icon(CupertinoIcons.camera, color: AppColors.textSecondary),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassSurface(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Kategori', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: CategoryCatalog.all.map((c) {
                    final selected = c.id == _category.id;
                    return GestureDetector(
                      onTap: () => setState(() => _category = c),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.accent.withOpacity(0.85) : const Color(0x1AFFFFFF),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: selected ? AppColors.accent : const Color(0x33FFFFFF)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(c.icon, size: 14, color: selected ? CupertinoColors.white : AppColors.textSecondary),
                            const SizedBox(width: 6),
                            Text(c.name, style: TextStyle(color: selected ? CupertinoColors.white : AppColors.textSecondary, fontSize: 13)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassSurface(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ürün Bilgileri', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                _input(_titleCtrl, 'Başlık', 'Örn. iPhone 13 Pro'),
                const SizedBox(height: 12),
                _input(_descCtrl, 'Açıklama', 'Ürünü ve takas tercihlerini yaz', maxLines: 4),
                for (final field in _category.fields) ...[
                  const SizedBox(height: 12),
                  if (field.options != null)
                    _optionField(field)
                  else
                    _input(_attrCtrl(field.key), field.label, field.placeholder,
                        keyboardType: field.keyboardType),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          GlassButton(
            label: _saving ? 'Kaydediliyor...' : 'Ürünü Yayınla',
            icon: CupertinoIcons.checkmark_circle,
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
    );
  }

  Widget _input(TextEditingController ctrl, String label, String placeholder,
      {int maxLines = 1, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 6),
        CupertinoTextField(
          controller: ctrl,
          placeholder: placeholder,
          maxLines: maxLines,
          keyboardType: keyboardType,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          style: const TextStyle(color: AppColors.textPrimary),
          placeholderStyle: const TextStyle(color: AppColors.textTertiary),
          decoration: BoxDecoration(
            color: const Color(0x1AFFFFFF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0x33FFFFFF)),
          ),
        ),
      ],
    );
  }

  Widget _optionField(CategoryField field) {
    final ctrl = _attrCtrl(field.key);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(field.label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: field.options!.map((opt) {
            final selected = ctrl.text == opt;
            return GestureDetector(
              onTap: () => setState(() => ctrl.text = opt),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? AppColors.accent.withOpacity(0.8) : const Color(0x1AFFFFFF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: selected ? AppColors.accent : const Color(0x33FFFFFF)),
                ),
                child: Text(opt, style: TextStyle(color: selected ? CupertinoColors.white : AppColors.textSecondary, fontSize: 13)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
