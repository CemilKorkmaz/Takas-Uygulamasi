import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_notification.dart';
import '../models/app_user.dart';
import '../models/item.dart';
import '../models/review.dart';
import '../models/swap_offer.dart';
import '../repositories/item_repository.dart';
import '../repositories/notification_repository.dart';
import '../repositories/offer_repository.dart';
import '../repositories/user_repository.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final storageServiceProvider = Provider<StorageService>((ref) => StorageService());
final userRepositoryProvider = Provider<UserRepository>((ref) => UserRepository());
final itemRepositoryProvider = Provider<ItemRepository>((ref) => ItemRepository());
final offerRepositoryProvider = Provider<OfferRepository>((ref) => OfferRepository());
final notificationRepositoryProvider =
    Provider<NotificationRepository>((ref) => NotificationRepository());

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final currentUserDocProvider = StreamProvider<AppUser?>((ref) {
  final auth = ref.watch(authStateProvider).valueOrNull;
  if (auth == null) return const Stream.empty();
  return ref.watch(userRepositoryProvider).watchUser(auth.uid);
});

final feedItemsProvider = StreamProvider<List<Item>>((ref) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  return ref.watch(itemRepositoryProvider).watchFeed(excludeOwnerId: uid);
});

final myItemsProvider = StreamProvider<List<Item>>((ref) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return const Stream.empty();
  return ref.watch(itemRepositoryProvider).watchUserItems(uid);
});

final incomingOffersProvider = StreamProvider<List<SwapOffer>>((ref) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return const Stream.empty();
  return ref.watch(offerRepositoryProvider).watchIncomingOffers(uid);
});

final outgoingOffersProvider = StreamProvider<List<SwapOffer>>((ref) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return const Stream.empty();
  return ref.watch(offerRepositoryProvider).watchOutgoingOffers(uid);
});

final notificationsProvider = StreamProvider<List<AppNotification>>((ref) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return const Stream.empty();
  return ref.watch(notificationRepositoryProvider).watchNotifications(uid);
});

final unreadNotificationCountProvider = StreamProvider<int>((ref) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return const Stream.empty();
  return ref.watch(notificationRepositoryProvider).watchUnreadCount(uid);
});

final userReviewsProvider =
    StreamProvider.family<List<Review>, String>((ref, uid) {
  return ref.watch(userRepositoryProvider).watchReviewsForUser(uid);
});

final offerByIdProvider =
    StreamProvider.family<SwapOffer?, String>((ref, offerId) {
  return ref.watch(offerRepositoryProvider).watchOffer(offerId);
});
