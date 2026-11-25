import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/categories.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass.dart';
import '../../models/item.dart';
import '../../models/swap_offer.dart';
import '../../providers/providers.dart';

final _itemProvider = StreamProvider.family<Item?, String>((ref, id) {
  return ref.watch(itemRepositoryProvider).watchItem(id);
});

class ItemDetailScreen extends ConsumerWidget {
  const ItemDetailScreen({super.key, required this.itemId});
  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(_itemProvider(itemId));
    return itemAsync.when(
      data: (item) {
        if (item == null) {
          return const GlassScaffold(
            child: Center(
              child: Text('Ürün bulunamadı',
                  style: TextStyle(color: AppColors.textPrimary)),
            ),
          );
        }
        return _ItemDetailBody(item: item);
      },
      loading: () => const GlassScaffold(
        child: Center(child: CupertinoActivityIndicator(radius: 14)),
      ),
      error: (e, _) => GlassScaffold(
        child: Center(
          child: Text('$e',
              style: const TextStyle(color: AppColors.textSecondary)),
        ),
      ),
    );
  }
}

class _ItemDetailBody extends ConsumerWidget {
  const _ItemDetailBody({required this.item});
  final Item item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(authStateProvider).valueOrNull;
    final category = CategoryCatalog.byId(item.categoryId);
    final isMine = me?.uid == item.ownerId;

    return GlassScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: const Color(0x00000000),
        border: null,
        middle: Text(item.title, style: const TextStyle(color: AppColors.textPrimary)),
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
            borderRadius: 24,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: item.imageUrls.isNotEmpty
                    ? PageView(
                        children: item.imageUrls
                            .map((u) => Image.network(u, fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _ph()))
                            .toList(),
                      )
                    : _ph(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          GlassSurface(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(category.icon, size: 16, color: AppColors.accent),
                    const SizedBox(width: 6),
                    Text(category.name, style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(item.title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(item.description, style: const TextStyle(color: AppColors.textSecondary, fontSize: 15, height: 1.4)),
                if (item.attributes.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('Özellikler', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ...item.attributes.entries.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 110,
                              child: Text(_labelFor(category, e.key),
                                  style: const TextStyle(color: AppColors.textTertiary, fontSize: 13)),
                            ),
                            Expanded(
                              child: Text('${e.value}',
                                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                            ),
                          ],
                        ),
                      )),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassSurface(
            padding: const EdgeInsets.all(16),
            onTap: isMine ? null : () => context.push('/profile/${item.ownerId}'),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0x2AFFFFFF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(CupertinoIcons.person_fill, color: AppColors.textSecondary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.ownerName.isEmpty ? 'Kullanıcı' : item.ownerName,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                      Text(isMine ? 'Senin ürünün' : 'Profili gör',
                          style: const TextStyle(color: AppColors.textTertiary, fontSize: 13)),
                    ],
                  ),
                ),
                if (!isMine)
                  const Icon(CupertinoIcons.chevron_right, size: 16, color: AppColors.textTertiary),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (!isMine)
            GlassButton(
              label: 'Takas Teklifi Gönder',
              icon: CupertinoIcons.arrow_right_arrow_left,
              onPressed: () => _showOfferSheet(context, ref, item),
            ),
        ],
      ),
    );
  }

  static String _labelFor(ItemCategory category, String key) {
    for (final f in category.fields) {
      if (f.key == key) return f.label;
    }
    return key;
  }

  static Widget _ph() => Container(
        color: const Color(0x1AFFFFFF),
        alignment: Alignment.center,
        child: const Icon(CupertinoIcons.photo, size: 48, color: AppColors.textTertiary),
      );

  void _showOfferSheet(BuildContext context, WidgetRef ref, Item targetItem) {
    final myItems = ref.read(myItemsProvider).valueOrNull ?? [];
    final activeMine = myItems.where((i) => i.isActive).toList();
    showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.65,
        decoration: const BoxDecoration(
          color: Color(0xFF171C2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0x55FFFFFF), borderRadius: BorderRadius.circular(4))),
            ),
            const SizedBox(height: 16),
            const Text('Takas için bir ürününü seç',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('"${targetItem.title}" karşılığında teklif edeceğin ürünü seç.',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            const SizedBox(height: 16),
            Expanded(
              child: activeMine.isEmpty
                  ? const Center(
                      child: Text('Teklif vermek için önce bir ürün eklemelisin.',
                          style: TextStyle(color: AppColors.textSecondary)),
                    )
                  : ListView.separated(
                      itemCount: activeMine.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final mine = activeMine[i];
                        return GlassSurface(
                          padding: const EdgeInsets.all(12),
                          borderRadius: 16,
                          onTap: () async {
                            Navigator.pop(ctx);
                            await _sendOffer(context, ref, targetItem, mine);
                          },
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: mine.imageUrls.isNotEmpty
                                    ? Image.network(mine.imageUrls.first, width: 56, height: 56, fit: BoxFit.cover)
                                    : Container(width: 56, height: 56, color: const Color(0x1AFFFFFF),
                                        child: const Icon(CupertinoIcons.photo, color: AppColors.textTertiary)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(mine.title,
                                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
                              ),
                              const Icon(CupertinoIcons.chevron_right, size: 16, color: AppColors.textTertiary),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendOffer(BuildContext context, WidgetRef ref, Item target, Item mine) async {
    final me = ref.read(currentUserDocProvider).valueOrNull;
    final authUser = ref.read(authServiceProvider).currentUser;
    if (me == null || authUser == null) return;
    try {
      final offer = SwapOffer(
        id: '',
        requesterId: authUser.uid,
        requesterName: me.displayName,
        ownerId: target.ownerId,
        ownerName: target.ownerName,
        requestedItemId: target.id,
        requestedItemTitle: target.title,
        requestedItemImage: target.imageUrls.isNotEmpty ? target.imageUrls.first : null,
        offeredItemId: mine.id,
        offeredItemTitle: mine.title,
        offeredItemImage: mine.imageUrls.isNotEmpty ? mine.imageUrls.first : null,
        status: SwapOfferStatus.pending,
        createdAt: DateTime.now(),
      );
      await ref.read(offerRepositoryProvider).createOffer(offer);
      if (context.mounted) {
        showCupertinoDialog<void>(
          context: context,
          builder: (_) => CupertinoAlertDialog(
            title: const Text('Teklif Gönderildi'),
            content: const Text('Takas teklifin karşı tarafa iletildi.'),
            actions: [
              CupertinoDialogAction(child: const Text('Tamam'), onPressed: () => Navigator.pop(context)),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        showCupertinoDialog<void>(
          context: context,
          builder: (_) => CupertinoAlertDialog(
            title: const Text('Hata'),
            content: Text('$e'),
            actions: [CupertinoDialogAction(child: const Text('Tamam'), onPressed: () => Navigator.pop(context))],
          ),
        );
      }
    }
  }
}
