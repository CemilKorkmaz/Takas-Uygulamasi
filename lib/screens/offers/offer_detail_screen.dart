import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass.dart';
import '../../models/swap_offer.dart';
import '../../providers/providers.dart';

class OfferDetailScreen extends ConsumerStatefulWidget {
  const OfferDetailScreen({super.key, required this.offerId});
  final String offerId;

  @override
  ConsumerState<OfferDetailScreen> createState() => _OfferDetailScreenState();
}

class _OfferDetailScreenState extends ConsumerState<OfferDetailScreen> {
  final _trackingCtrl = TextEditingController();
  final _reviewCommentCtrl = TextEditingController();
  int _rating = 5;
  bool _busy = false;

  @override
  void dispose() {
    _trackingCtrl.dispose();
    _reviewCommentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final offerAsync = ref.watch(offerByIdProvider(widget.offerId));
    final uid = ref.watch(authStateProvider).valueOrNull?.uid;

    return GlassScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: const Color(0x00000000),
        border: null,
        middle: const Text('Takas Detayı', style: TextStyle(color: AppColors.textPrimary)),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => context.pop(),
          child: const Icon(CupertinoIcons.back, color: AppColors.textPrimary),
        ),
      ),
      child: offerAsync.when(
        data: (offer) {
          if (offer == null || uid == null) {
            return const Center(child: Text('Teklif bulunamadı', style: TextStyle(color: AppColors.textPrimary)));
          }
          return _body(context, offer, uid);
        },
        loading: () => const Center(child: CupertinoActivityIndicator(radius: 14)),
        error: (e, _) => Center(child: Text('$e', style: const TextStyle(color: AppColors.textSecondary))),
      ),
    );
  }

  Widget _body(BuildContext context, SwapOffer offer, String uid) {
    final isOwner = offer.ownerId == uid;
    final isRequester = offer.requesterId == uid;
    final df = DateFormat('d MMM yyyy HH:mm', 'tr_TR');

    final myTracking = isRequester ? offer.requesterTrackingNumber : offer.ownerTrackingNumber;
    final otherTracking = isRequester ? offer.ownerTrackingNumber : offer.requesterTrackingNumber;
    final myReviewed = isRequester ? offer.requesterReviewed : offer.ownerReviewed;
    final canReview = offer.status == SwapOfferStatus.accepted || offer.status == SwapOfferStatus.completed;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      children: [
        _statusBanner(offer),
        const SizedBox(height: 16),
        GlassSurface(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _itemRow('Teklif Edilen', offer.offeredItemTitle, offer.offeredItemImage, offer.requesterName),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Icon(CupertinoIcons.arrow_right_arrow_left, color: AppColors.accent, size: 24),
              ),
              _itemRow('İstenen', offer.requestedItemTitle, offer.requestedItemImage, offer.ownerName),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GlassSurface(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoLine('Oluşturulma', df.format(offer.createdAt)),
              if (offer.respondedAt != null) _infoLine('Yanıt', df.format(offer.respondedAt!)),
              if (offer.shippingDeadline != null)
                _infoLine('Kargo Son Tarihi', df.format(offer.shippingDeadline!)),
            ],
          ),
        ),
        if (offer.status == SwapOfferStatus.pending && isOwner) ...[
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: GlassButton(
                  label: 'Reddet',
                  destructive: true,
                  onPressed: _busy ? null : () => _run(() => ref.read(offerRepositoryProvider).rejectOffer(offer)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GlassButton(
                  label: 'Kabul Et',
                  onPressed: _busy ? null : () => _run(() => ref.read(offerRepositoryProvider).acceptOffer(offer)),
                ),
              ),
            ],
          ),
        ],
        if (offer.status == SwapOfferStatus.accepted || offer.status == SwapOfferStatus.completed) ...[
          const SizedBox(height: 16),
          GlassSurface(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Kargo Takibi', style: TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                const Text(
                  'Kabul edilen takaslarda her iki taraf 5 gün içinde kargoya vermelidir.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 14),
                _timelineStep('Teklif kabul edildi', true),
                _timelineStep('Sen kargoladın', myTracking != null && myTracking.isNotEmpty),
                _timelineStep('Karşı taraf kargoladı', otherTracking != null && otherTracking.isNotEmpty),
                _timelineStep('Takas tamamlandı', offer.status == SwapOfferStatus.completed, isLast: true),
                const SizedBox(height: 14),
                _trackingStatus('Senin takip numaran', myTracking),
                const SizedBox(height: 8),
                _trackingStatus('Karşı tarafın takip numarası', otherTracking),
                const SizedBox(height: 14),
                CupertinoTextField(
                  controller: _trackingCtrl,
                  placeholder: 'Takip numaranı gir',
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  style: const TextStyle(color: AppColors.textPrimary),
                  placeholderStyle: const TextStyle(color: AppColors.textTertiary),
                  decoration: BoxDecoration(
                    color: const Color(0x1AFFFFFF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0x33FFFFFF)),
                  ),
                ),
                const SizedBox(height: 10),
                GlassButton(
                  label: 'Takip Numarasını Kaydet',
                  icon: CupertinoIcons.cube_box,
                  onPressed: _busy
                      ? null
                      : () {
                          final tn = _trackingCtrl.text.trim();
                          if (tn.isEmpty) return;
                          _run(() => ref.read(offerRepositoryProvider).submitTracking(
                                offer: offer,
                                uid: uid,
                                trackingNumber: tn,
                              ));
                        },
                ),
              ],
            ),
          ),
        ],
        if (canReview) ...[
          const SizedBox(height: 16),
          GlassSurface(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Değerlendirme', style: TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(
                  myReviewed ? 'Bu takas için değerlendirmeni yaptın.' : 'Takas deneyimini değerlendir.',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                if (!myReviewed) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: List.generate(5, (i) {
                      final star = i + 1;
                      return GestureDetector(
                        onTap: () => setState(() => _rating = star),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(
                            star <= _rating ? CupertinoIcons.star_fill : CupertinoIcons.star,
                            color: const Color(0xFFFFD60A),
                            size: 30,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  CupertinoTextField(
                    controller: _reviewCommentCtrl,
                    placeholder: 'Deneyimini yaz...',
                    maxLines: 3,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    style: const TextStyle(color: AppColors.textPrimary),
                    placeholderStyle: const TextStyle(color: AppColors.textTertiary),
                    decoration: BoxDecoration(
                      color: const Color(0x1AFFFFFF),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0x33FFFFFF)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GlassButton(
                    label: 'Değerlendirmeyi Gönder',
                    icon: CupertinoIcons.star_fill,
                    onPressed: _busy ? null : () => _submitReview(offer, uid),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _statusBanner(SwapOffer offer) {
    final color = switch (offer.status) {
      SwapOfferStatus.pending => AppColors.warning,
      SwapOfferStatus.accepted => AppColors.accent,
      SwapOfferStatus.rejected => AppColors.danger,
      SwapOfferStatus.cancelled => AppColors.textTertiary,
      SwapOfferStatus.completed => AppColors.success,
    };
    return GlassSurface(
      padding: const EdgeInsets.all(14),
      borderOpacity: 0.3,
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Text('Durum: ${offer.status.label}',
              style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _itemRow(String label, String title, String? image, String owner) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: image != null
              ? Image.network(image, width: 72, height: 72, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _ph())
              : _ph(),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.textTertiary, fontSize: 12)),
              const SizedBox(height: 2),
              Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(owner, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _ph() => Container(
        width: 72,
        height: 72,
        color: const Color(0x1AFFFFFF),
        alignment: Alignment.center,
        child: const Icon(CupertinoIcons.photo, color: AppColors.textTertiary),
      );

  Widget _infoLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 130, child: Text(label, style: const TextStyle(color: AppColors.textTertiary, fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14))),
        ],
      ),
    );
  }

  Widget _timelineStep(String label, bool done, {bool isLast = false}) {
    final color = done ? AppColors.success : AppColors.textTertiary;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(done ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.circle, size: 18, color: color),
            if (!isLast)
              Container(width: 2, height: 18, color: color.withOpacity(0.35)),
          ],
        ),
        const SizedBox(width: 10),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(label, style: TextStyle(color: done ? AppColors.textPrimary : AppColors.textTertiary, fontSize: 13, fontWeight: done ? FontWeight.w600 : FontWeight.w400)),
        ),
      ],
    );
  }

  Widget _trackingStatus(String label, String? value) {
    final has = value != null && value.isNotEmpty;
    return Row(
      children: [
        Icon(has ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.clock,
            size: 16, color: has ? AppColors.success : AppColors.textTertiary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$label: ${has ? value : 'Henüz girilmedi'}',
            style: TextStyle(color: has ? AppColors.textPrimary : AppColors.textTertiary, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
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
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submitReview(SwapOffer offer, String uid) async {
    final comment = _reviewCommentCtrl.text.trim();
    if (comment.isEmpty) {
      showCupertinoDialog<void>(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text('Eksik Bilgi'),
          content: const Text('Lütfen deneyimini kısaca yaz.'),
          actions: [CupertinoDialogAction(child: const Text('Tamam'), onPressed: () => Navigator.pop(context))],
        ),
      );
      return;
    }
    final me = ref.read(currentUserDocProvider).valueOrNull;
    await _run(() => ref.read(offerRepositoryProvider).submitReview(
          offer: offer,
          reviewerId: uid,
          reviewerName: me?.displayName ?? 'Kullanıcı',
          rating: _rating,
          comment: comment,
        ));
    _reviewCommentCtrl.clear();
  }
}
