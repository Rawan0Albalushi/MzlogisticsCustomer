import 'package:flutter/material.dart';

import '../../../core/i18n/i18n_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/info_row.dart';
import '../../trips/data/trip_model.dart';

class TrackingPanel extends StatelessWidget {
  const TrackingPanel({
    super.key,
    required this.trip,
    required this.i18n,
  });

  final Trip trip;
  final I18nBundle i18n;

  @override
  Widget build(BuildContext context) {
    final locale = i18n.locale.languageCode;
    return SectionCard(
      title: i18n.t('tracking.title'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RouteSchematic(trip: trip, i18n: i18n),
          const SizedBox(height: 16),
          if (!trip.hasTracking)
            Text(i18n.t('trip.noTracking'), style: const TextStyle(color: AppColors.muted))
          else
            Wrap(
              spacing: 24,
              runSpacing: 12,
              children: [
                InfoRow(label: i18n.t('tracking.lat'), value: formatCoordinate(trip.currentLat)),
                InfoRow(label: i18n.t('tracking.lng'), value: formatCoordinate(trip.currentLng)),
                InfoRow(label: i18n.t('common.eta'), value: formatDateTime(trip.etaAt, locale: locale)),
              ],
            ),
          const SizedBox(height: 12),
          InfoRow(
            label: i18n.t('tracking.pickupPoint'),
            value: '${formatCoordinate(trip.pickupLat)}, ${formatCoordinate(trip.pickupLng)}',
            wide: true,
          ),
          InfoRow(
            label: i18n.t('tracking.deliveryPoint'),
            value: '${formatCoordinate(trip.deliveryLat)}, ${formatCoordinate(trip.deliveryLng)}',
            wide: true,
          ),
        ],
      ),
    );
  }
}

class _RouteSchematic extends StatelessWidget {
  const _RouteSchematic({required this.trip, required this.i18n});

  final Trip trip;
  final I18nBundle i18n;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _dot(AppColors.navy, i18n.t('common.pickup')),
          Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              color: trip.hasTracking ? AppColors.amber : AppColors.border,
            ),
          ),
          if (trip.hasTracking) ...[
            _dot(AppColors.amber, i18n.t('trip.currentPosition')),
            Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                color: AppColors.border,
              ),
            ),
          ],
          _dot(AppColors.success, i18n.t('common.delivery')),
        ],
      ),
    );
  }

  Widget _dot(Color color, String label) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
      ],
    );
  }
}
