import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/glass.dart';
import '../../models/app_notification.dart';
import '../../providers/providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);
    final uid = ref.watch(authStateProvider).valueOrNull?.uid;

    return GlassScaffold(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Bildirimler',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.8,
                      ),
                    ),
                  ),
                  if (uid != null)
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => ref.read(notificationRepositoryProvider).markAllAsRead(uid),
                      child: const Text('Tümünü oku', style: TextStyle(color: AppColors.accent, fontSize: 14)),
                    ),
                ],
              ),
            ),
          ),
          notificationsAsync.when(
            data: (items) {
              if (items.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: CupertinoIcons.bell,
                    title: 'Bildirim yok',
                    message: 'Takas teklifleri ve güncellemeler burada görünecek.',
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                sliver: SliverList.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _NotificationTile(notification: items[i]),
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

class _NotificationTile extends ConsumerWidget {
  const _NotificationTile({required this.notification});
  final AppNotification notification;

  IconData get _icon => switch (notification.type) {
        NotificationType.offerReceived => CupertinoIcons.tray_arrow_down_fill,
        NotificationType.offerAccepted => CupertinoIcons.check_mark_circled_solid,
        NotificationType.offerRejected => CupertinoIcons.xmark_circle_fill,
        NotificationType.trackingUpdated => CupertinoIcons.cube_box_fill,
        NotificationType.reviewReceived => CupertinoIcons.star_fill,
        NotificationType.system => CupertinoIcons.bell_fill,
      };

  Color get _color => switch (notification.type) {
        NotificationType.offerReceived => AppColors.accent,
        NotificationType.offerAccepted => AppColors.success,
        NotificationType.offerRejected => AppColors.danger,
        NotificationType.trackingUpdated => AppColors.warning,
        NotificationType.reviewReceived => const Color(0xFFFFD60A),
        NotificationType.system => AppColors.accentSecondary,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final df = DateFormat('d MMM HH:mm', 'tr_TR');
    return GlassSurface(
      padding: const EdgeInsets.all(14),
      opacity: notification.isRead ? 0.08 : 0.14,
      onTap: () async {
        if (!notification.isRead) {
          await ref.read(notificationRepositoryProvider).markAsRead(notification.id);
        }
        if (notification.relatedOfferId != null && context.mounted) {
          context.push('/offer/${notification.relatedOfferId}');
        }
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_icon, color: _color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(notification.title,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700,
                          )),
                    ),
                    if (!notification.isRead)
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(notification.body, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 6),
                Text(df.format(notification.createdAt),
                    style: const TextStyle(color: AppColors.textTertiary, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
