import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../notifications/notifications_screen.dart';
import '../offers/offers_screen.dart';
import '../profile/my_profile_screen.dart';
import 'home_screen.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final unread = ref.watch(unreadNotificationCountProvider).valueOrNull ?? 0;

    final pages = const [
      HomeScreen(),
      OffersScreen(),
      NotificationsScreen(),
      MyProfileScreen(),
    ];

    return CupertinoPageScaffold(
      backgroundColor: const Color(0x00000000),
      child: Stack(
        children: [
          Positioned.fill(child: pages[_index]),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: _GlassTabBar(
              index: _index,
              unreadCount: unread,
              onChanged: (i) => setState(() => _index = i),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassTabBar extends StatelessWidget {
  const _GlassTabBar({
    required this.index,
    required this.onChanged,
    required this.unreadCount,
  });

  final int index;
  final ValueChanged<int> onChanged;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: const Color(0x26FFFFFF),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0x33FFFFFF)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              _tabItem(0, CupertinoIcons.house_fill, 'Keşfet'),
              _tabItem(1, CupertinoIcons.arrow_right_arrow_left, 'Teklifler'),
              _tabItem(2, CupertinoIcons.bell_fill, 'Bildirimler', badge: unreadCount),
              _tabItem(3, CupertinoIcons.person_fill, 'Profil'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabItem(int i, IconData icon, String label, {int badge = 0}) {
    final selected = i == index;
    final color = selected ? AppColors.accent : AppColors.textTertiary;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(i),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, size: 24, color: color),
                if (badge > 0)
                  Positioned(
                    right: -8,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.danger,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        badge > 9 ? '9+' : '$badge',
                        style: const TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
