import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/cities.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass.dart';
import '../../providers/providers.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  bool _initialized = false;
  bool _saving = false;
  XFile? _newPhoto;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80, maxWidth: 800);
    if (picked != null) setState(() => _newPhoto = picked);
  }

  Future<void> _save() async {
    final user = ref.read(currentUserDocProvider).valueOrNull;
    final authUser = ref.read(authServiceProvider).currentUser;
    if (user == null || authUser == null) return;
    setState(() => _saving = true);
    try {
      String? photoUrl = user.photoUrl;
      if (_newPhoto != null) {
        photoUrl = await ref.read(storageServiceProvider).uploadProfilePhoto(
              uid: authUser.uid,
              file: File(_newPhoto!.path),
            );
      }
      await ref.read(userRepositoryProvider).updateProfile(authUser.uid, {
        'displayName': _nameCtrl.text.trim(),
        'bio': _bioCtrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        'photoUrl': photoUrl,
      });
      if (mounted) context.pop();
    } catch (e) {
      if (!mounted) return;
      showCupertinoDialog<void>(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text('Hata'),
          content: Text('$e'),
          actions: [CupertinoDialogAction(child: const Text('Tamam'), onPressed: () => Navigator.pop(context))],
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserDocProvider).valueOrNull;
    if (user != null && !_initialized) {
      _nameCtrl.text = user.displayName;
      _bioCtrl.text = user.bio ?? '';
      _cityCtrl.text = user.city ?? '';
      _initialized = true;
    }

    return GlassScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: const Color(0x00000000),
        border: null,
        middle: const Text('Profili Düzenle', style: TextStyle(color: AppColors.textPrimary)),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => context.pop(),
          child: const Icon(CupertinoIcons.back, color: AppColors.textPrimary),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          Center(
            child: GestureDetector(
              onTap: _pickPhoto,
              child: Stack(
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0x33FFFFFF),
                      image: _newPhoto != null
                          ? DecorationImage(image: FileImage(File(_newPhoto!.path)), fit: BoxFit.cover)
                          : (user?.photoUrl != null
                              ? DecorationImage(image: NetworkImage(user!.photoUrl!), fit: BoxFit.cover)
                              : null),
                    ),
                    child: (_newPhoto == null && user?.photoUrl == null)
                        ? const Icon(CupertinoIcons.person_fill, size: 44, color: AppColors.textSecondary)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                      child: const Icon(CupertinoIcons.camera_fill, size: 14, color: CupertinoColors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          GlassSurface(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _field(_nameCtrl, 'Ad Soyad', 'Adını yaz'),
                const SizedBox(height: 12),
                _cityPickerField(),
                const SizedBox(height: 12),
                _field(_bioCtrl, 'Hakkımda', 'Kendinden ve takas tercihlerinden bahset', maxLines: 4),
              ],
            ),
          ),
          const SizedBox(height: 24),
          GlassButton(
            label: _saving ? 'Kaydediliyor...' : 'Kaydet',
            icon: CupertinoIcons.checkmark_circle,
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
    );
  }

  Widget _cityPickerField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Şehir', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: _showCityPicker,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0x1AFFFFFF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0x33FFFFFF)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _cityCtrl.text.isEmpty ? 'Şehir seç' : _cityCtrl.text,
                    style: TextStyle(
                      color: _cityCtrl.text.isEmpty ? AppColors.textTertiary : AppColors.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                ),
                const Icon(CupertinoIcons.chevron_down, size: 16, color: AppColors.textTertiary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showCityPicker() {
    var query = '';
    showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final results = Cities.search(query);
          return Container(
            height: MediaQuery.of(ctx).size.height * 0.7,
            decoration: const BoxDecoration(
              color: Color(0xFF171C2E),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0x55FFFFFF), borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 16),
                const Text('Şehir Seç', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                CupertinoSearchTextField(
                  placeholder: 'Şehir ara',
                  style: const TextStyle(color: AppColors.textPrimary),
                  backgroundColor: const Color(0x1AFFFFFF),
                  onChanged: (v) => setModalState(() => query = v),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (_, i) {
                      final city = results[i];
                      final selected = city == _cityCtrl.text;
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          setState(() => _cityCtrl.text = city);
                          Navigator.pop(ctx);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: Color(0x1AFFFFFF))),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(city, style: TextStyle(color: selected ? AppColors.accent : AppColors.textPrimary, fontSize: 16, fontWeight: selected ? FontWeight.w600 : FontWeight.w400)),
                              ),
                              if (selected) const Icon(CupertinoIcons.check_mark, color: AppColors.accent, size: 18),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, String placeholder, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 6),
        CupertinoTextField(
          controller: ctrl,
          placeholder: placeholder,
          maxLines: maxLines,
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
}
