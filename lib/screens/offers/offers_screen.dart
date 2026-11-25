import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/glass.dart';
import '../../models/swap_offer.dart';
import '../../providers/providers.dart';

class OffersScreen extends ConsumerStatefulWidget {
  const OffersScreen({super.key});

  @override
  ConsumerState<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends ConsumerState<OffersScreen> {
  int _segment = 0; // 0 gelen, 1 giden

  @override
  Widget build(BuildContext context) {
    final incoming = ref.watch(incomingOffersProvider);
    final outgoing = ref.watch(outgoingOffersProvider);
    final async = _segment == 0 ? incoming : outgoing;

    return GlassScaffold(
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                'Teklifler',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.8,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: CupertinoSlidingSegmentedControl<int>(
                groupValue: _segment,
                backgroundColor: const Color(0x1AFFFFFF),
                thumbColor: AppColors.accent.withOpacity(0.85),
                children: const {
                  0: Padding(padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8), child: Text('Gelen')),
                  1: Padding(padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8), child: Text('Giden')),
                },
                onValueChanged: (v) => setState(() => _segment = v ?? 0),
              ),
            ),
          ),
          async.when(
            data: (offers) {
              if (offers.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: CupertinoIcons.arrow_right_arrow_left,
                    title: _segment == 0 ? 'Gelen teklif yok' : 'Giden teklif yok',
                    message: _segment == 0
                        ? 'Birisi ürününe teklif gönderdiğinde burada görünecek.'
                        : 'Beğendiğin ürünlere takas teklifi gönderebilirsin.',
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                sliver: SliverList.separated(
                  itemCount: offers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _OfferCard(offer: offers[i], incoming: _segment == 0),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CupertinoActivityIndicator(radius: 14)),
            ),
            error: (e, _) => SliverFillRemaining(
              child: EmptyState(icon: CupertinoIcons.exclamationmark_triangle, title: 'Hata', message: '$e'),
            ),
          ),
        ],
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({required this.offer, required this.incoming});
  final SwapOffer offer;
  final bool incoming;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (offer.status) {
      SwapOfferStatus.pending => AppColors.warning,
      SwapOfferStatus.accepted => AppColors.accent,
      SwapOfferStatus.rejected => AppColors.danger,
      SwapOfferStatus.cancelled => AppColors.textTertiary,
      SwapOfferStatus.completed => AppColors.success,
    };

    return GlassSurface(
      padding: const EdgeInsets.all(14),
      onTap: () => context.push('/offer/${offer.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  incoming ? '${offer.requesterName} teklif gönderdi' : '${offer.ownerName} kullanıcısına teklif',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withOpacity(0.5)),
                ),
                child: Text(offer.status.label, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _itemThumb(offer.offeredItemImage, offer.offeredItemTitle),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Icon(CupertinoIcons.arrow_right_arrow_left, color: AppColors.accent, size: 20),
              ),
              _itemThumb(offer.requestedItemImage, offer.requestedItemTitle),
            ],
          ),
        ],
      ),
    );
  }

  Widget _itemThumb(String? image, String title) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: image != null
                ? Image.network(image, height: 72, width: double.infinity, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _ph())
                : _ph(),
          ),
          const SizedBox(height: 6),
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _ph() => Container(
        height: 72,
        color: const Color(0x1AFFFFFF),
        alignment: Alignment.center,
        child: const Icon(CupertinoIcons.photo, color: AppColors.textTertiary),
      );
}
