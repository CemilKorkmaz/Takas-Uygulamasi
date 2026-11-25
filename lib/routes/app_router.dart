import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/providers.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/home/main_shell.dart';
import '../screens/item/add_item_screen.dart';
import '../screens/item/item_detail_screen.dart';
import '../screens/offers/offer_detail_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/profile_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final loggedIn = authState.valueOrNull != null;
      final loggingIn = state.matchedLocation == '/auth';
      if (authState.isLoading) return null;
      if (!loggedIn && !loggingIn) return '/auth';
      if (loggedIn && loggingIn) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const MainShell(),
        routes: [
          GoRoute(
            path: 'item/add',
            builder: (context, state) => const AddItemScreen(),
          ),
          GoRoute(
            path: 'item/:id',
            builder: (context, state) =>
                ItemDetailScreen(itemId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'offer/:id',
            builder: (context, state) =>
                OfferDetailScreen(offerId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'profile/edit',
            builder: (context, state) => const EditProfileScreen(),
          ),
          GoRoute(
            path: 'profile/:uid',
            builder: (context, state) =>
                ProfileScreen(userId: state.pathParameters['uid']!),
          ),
        ],
      ),
    ],
  );
});
