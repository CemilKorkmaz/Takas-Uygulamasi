import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass.dart';
import '../../providers/providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key, required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRepo = ref.watch(userRepositoryProvider);
    final itemsRepo = ref.watch(itemRepositoryProvider);
    final reviewsAsync = ref.watch(userReviewsProvider(userId));

    return GlassScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: const Color(0x00000000),
        border: null,
        middle: const Text('Profil', style: TextStyle(color: AppColors.textPrimary)),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => context.pop(),
          child: const Icon(CupertinoIcons.back, color: AppColors.textPrimary),
        ),
      ),
      child: StreamBuilder(
        stream: userRepo.watchUser(userId),
        builder: (context, snapshot) {
          final user = snapshot.data;
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CupertinoActivityIndicator());
          }
          if (user == null) {
            return const Center(child: Text('Kullanıcı bulunamadı', style: TextStyle(color: AppColors.textPrimary)));
          }
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: GlassSurface(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0x33FFFFFF),
                            image: user.photoUrl != null
                                ? DecorationImage(image: NetworkImage(user.photoUrl!), fit: BoxFit.cover)
                                : null,
                          ),
                          child: user.photoUrl == null
                              ? const Icon(CupertinoIcons.person_fill, size: 40, color: AppColors.textSecondary)
                              : null,
                        ),
                        const SizedBox(height: 12),
                        Text(user.displayName.isEmpty ? 'Kullanıcı' : user.displayName,
                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
                        if ((user.city ?? '').isNotEmpty)
                          Text(user.city!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                        if ((user.bio ?? '').isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(user.bio!, textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(CupertinoIcons.star_fill, color: Color(0xFFFFD60A), size: 18),
                            const SizedBox(width: 6),
                            Text(
                              user.ratingCount == 0
                                  ? 'Henüz değerlendirme yok'
                                  : '${user.ratingAverage.toStringAsFixed(1)} (${user.ratingCount})',
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: const Text('Ürünleri', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
                ),
              ),
              StreamBuilder(
                stream: itemsRepo.watchUserItems(userId),
                builder: (context, snap) {
                  final items = (snap.data ?? []).where((i) => i.isActive).toList();
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(20), child: CupertinoActivityIndicator()));
                  }
                  if (items.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text('Aktif ürün yok.', style: TextStyle(color: AppColors.textSecondary))),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final item = items[i];
                        return GlassSurface(
                          padding: const EdgeInsets.all(12),
                          borderRadius: 16,
                          onTap: () => context.push('/item/${item.id}'),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: item.imageUrls.isNotEmpty
                                    ? Image.network(item.imageUrls.first, width: 60, height: 60, fit: BoxFit.cover)
                                    : Container(width: 60, height: 60, color: const Color(0x1AFFFFFF),
                                        child: const Icon(CupertinoIcons.photo, color: AppColors.textTertiary)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Text(item.title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600))),
                              const Icon(CupertinoIcons.chevron_right, size: 16, color: AppColors.textTertiary),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: const Text('Değerlendirmeler', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
                ),
              ),
              reviewsAsync.when(
                data: (reviews) {
                  if (reviews.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(padding: EdgeInsets.fromLTRB(20, 0, 20, 40), child: Text('Henüz değerlendirme yok.', style: TextStyle(color: AppColors.textSecondary))),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                    sliver: SliverList.separated(
                      itemCount: reviews.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final r = reviews[i];
                        return GlassSurface(
                          padding: const EdgeInsets.all(14),
                          borderRadius: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(child: Text(r.reviewerName, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600))),
                                  Row(children: List.generate(5, (s) => Icon(s < r.rating ? CupertinoIcons.star_fill : CupertinoIcons.star, size: 14, color: const Color(0xFFFFD60A)))),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(r.comment, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(20), child: CupertinoActivityIndicator())),
                error: (e, _) => SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(20), child: Text('$e'))),
              ),
            ],
          );
        },
      ),
    );
  }
}
