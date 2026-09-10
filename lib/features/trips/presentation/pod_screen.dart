import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/i18n/i18n_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/async_body.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/info_row.dart';
import '../../../shared/widgets/page_scaffold.dart';
import '../../../shared/widgets/status_badge.dart';
import '../data/trip_model.dart';
import 'trip_providers.dart';

class PodScreen extends ConsumerWidget {
  const PodScreen({super.key, required this.tripId});

  final int tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n = ref.i18n;
    final value = ref.watch(tripDetailProvider(tripId));

    return PageScaffold(
      title: i18n.t('pod.title'),
      body: AsyncBody<Trip>(
        value: value,
        i18n: i18n,
        onRetry: () => ref.invalidate(tripDetailProvider(tripId)),
        builder: (trip) {
          final pod = trip.proofOfDelivery;
          if (pod == null) {
            return EmptyState(
              title: i18n.t('pod.empty'),
              icon: Icons.photo_outlined,
            );
          }
          final locale = i18n.locale.languageCode;
          return ContentWidth(
            child: ListView(
              children: [
                SectionCard(
                  title: i18n.t('pod.title'),
                  trailing: StatusBadge(
                    status: pod.otpVerified ? 'completed' : 'pending',
                    label: pod.otpVerified ? i18n.t('pod.otpVerified') : i18n.t('pod.otpPending'),
                  ),
                  child: Wrap(
                    spacing: 24,
                    runSpacing: 12,
                    children: [
                      InfoRow(label: i18n.t('pod.receiver'), value: pod.receiverName ?? '—'),
                      InfoRow(label: i18n.t('pod.receivedQty'), value: formatNumber(pod.receivedQuantity)),
                      InfoRow(label: i18n.t('pod.otp'), value: pod.otpVerified ? i18n.t('common.verified') : i18n.t('common.unverified')),
                      InfoRow(label: i18n.t('pod.capturedAt'), value: formatDateTime(pod.capturedAt, locale: locale)),
                      if (pod.notes != null)
                        InfoRow(label: i18n.t('common.notes'), value: pod.notes!, wide: true),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  i18n.t('common.photos'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                if (pod.photoPaths.isEmpty)
                  Text(i18n.t('pod.noPhotos'), style: const TextStyle(color: AppColors.muted))
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final path in pod.photoPaths)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppTheme.radius),
                          child: Image.network(
                            mediaUrl(path, AppConstants.storageBaseUrl),
                            width: 160,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              width: 160,
                              height: 120,
                              color: AppColors.surface,
                              alignment: Alignment.center,
                              child: const Icon(Icons.broken_image_outlined, color: AppColors.muted),
                            ),
                          ),
                        ),
                    ],
                  ),
                if (pod.signaturePath != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    i18n.t('pod.signature'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Image.network(
                    mediaUrl(pod.signaturePath, AppConstants.storageBaseUrl),
                    height: 120,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
