import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/categories.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/glass.dart';
import '../../models/item.dart';
import '../../providers/providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _selectedCategory;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(feedItemsProvider);

    return GlassScaffold(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Keşfet',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.8,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Takas edebileceğin ürünleri bul',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/item/add'),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: AppColors.accentGradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(CupertinoIcons.add, color: CupertinoColors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: CupertinoSearchTextField(
                placeholder: 'Ürün ara',
                style: const TextStyle(color: AppColors.textPrimary),
                backgroundColor: const Color(0x1AFFFFFF),
                onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                children: [
                  _CategoryChip(
                    label: 'Tümü',
                    selected: _selectedCategory == null,
                    onTap: () => setState(() => _selectedCategory = null),
                  ),
                  ...CategoryCatalog.all.map(
                    (c) => Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _CategoryChip(
                        label: c.name,
                        selected: _selectedCategory == c.id,
                        onTap: () => setState(() => _selectedCategory = c.id),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          itemsAsync.when(
            data: (items) {
              final filtered = items.where((i) {
                final matchCat = _selectedCategory == null || i.categoryId == _selectedCategory;
                final q = _query;
                final matchQuery = q.isEmpty ||
                    i.title.toLowerCase().contains(q) ||
                    i.description.toLowerCase().contains(q);
                return matchCat && matchQuery;
              }).toList();
              if (filtered.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: CupertinoIcons.cube_box,
                    title: 'Henüz ürün yok',
                    message: 'İlk ürünü sen ekle veya daha sonra tekrar bak.',
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                sliver: SliverList.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) => _ItemCard(item: filtered[index]),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CupertinoActivityIndicator(radius: 14)),
            ),
            error: (e, _) => SliverFillRemaining(
              child: EmptyState(
                icon: CupertinoIcons.exclamationmark_triangle,
                title: 'Bir sorun oluştu',
                message: '$e',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent.withOpacity(0.85) : const Color(0x1AFFFFFF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.accent : const Color(0x33FFFFFF),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? CupertinoColors.white : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.item});
  final Item item;

  @override
  Widget build(BuildContext context) {
    final category = CategoryCatalog.byId(item.categoryId);
    return GlassSurface(
      borderRadius: 22,
      onTap: () => context.push('/item/${item.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: item.imageUrls.isNotEmpty
                  ? Image.network(
                      item.imageUrls.first,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _imagePlaceholder(),
                    )
                  : _imagePlaceholder(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(category.icon, size: 14, color: AppColors.accent),
                    const SizedBox(width: 6),
                    Text(category.name,
                        style: const TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(CupertinoIcons.person_circle, size: 16, color: AppColors.textTertiary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item.ownerName.isEmpty ? 'Kullanıcı' : item.ownerName,
                        style: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(CupertinoIcons.chevron_right, size: 14, color: AppColors.textTertiary),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0x1AFFFFFF),
      alignment: Alignment.center,
      child: const Icon(CupertinoIcons.photo, size: 42, color: AppColors.textTertiary),
    );
  }
}
