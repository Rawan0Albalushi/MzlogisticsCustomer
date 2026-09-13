import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/i18n_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/async_body.dart';
import '../../../shared/widgets/info_row.dart';
import '../../../shared/widgets/location_preview.dart';
import '../../../shared/widgets/page_scaffold.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../tracking/presentation/tracking_panel.dart';
import '../data/trip_model.dart';
import 'trip_providers.dart';

class TripDetailScreen extends ConsumerWidget {
  const TripDetailScreen({super.key, required this.tripId});

  final int tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n = ref.i18n;
    final value = ref.watch(tripDetailProvider(tripId));

    return PageScaffold(
      title: i18n.t('trip.detail'),
      body: AsyncBody<Trip>(
        value: value,
        i18n: i18n,
        onRetry: () => ref.invalidate(tripDetailProvider(tripId)),
        builder: (trip) {
          final locale = i18n.locale.languageCode;
          return ContentWidth(
            child: ListView(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        trip.reference ?? i18n.t('trip.sequence', {'n': '${trip.sequence ?? ''}'}),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    StatusBadge(status: trip.status ?? '', label: i18n.status(trip.status)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(i18n.t('trip.hint'), style: const TextStyle(color: AppColors.muted)),
                const SizedBox(height: 16),
                SectionCard(
                  title: i18n.t('common.details'),
                  child: Wrap(
                    spacing: 24,
                    runSpacing: 12,
                    children: [
                      InfoRow(label: i18n.t('nav.jobs'), value: trip.jobReference ?? '—'),
                      InfoRow(label: i18n.t('trip.driver'), value: trip.driver?.name ?? i18n.t('common.notAvailable')),
                      InfoRow(label: i18n.t('trip.truck'), value: trip.truck?.plateNumber ?? i18n.t('common.notAvailable')),
                      InfoRow(label: i18n.t('trip.planned'), value: formatNumber(trip.plannedQuantity)),
                      InfoRow(label: i18n.t('trip.delivered'), value: formatNumber(trip.deliveredQuantity)),
                      LocationPreview(
                        i18n: i18n,
                        title: i18n.t('common.pickup'),
                        address: trip.pickupAddress,
                        city: trip.pickupCity,
                        lat: trip.pickupLat,
                        lng: trip.pickupLng,
                      ),
                      LocationPreview(
                        i18n: i18n,
                        title: i18n.t('common.delivery'),
                        address: trip.deliveryAddress,
                        city: trip.deliveryCity,
                        lat: trip.deliveryLat,
                        lng: trip.deliveryLng,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                TrackingPanel(trip: trip, i18n: i18n),
                const SizedBox(height: 12),
                SectionCard(
                  title: i18n.t('trip.timeline'),
                  child: Column(
                    children: [
                      _event(i18n.t('trip.assignedAt'), formatDateTime(trip.assignedAt, locale: locale)),
                      _event(i18n.t('trip.pickupAt'), formatDateTime(trip.arrivedPickupAt, locale: locale)),
                      _event(i18n.t('trip.loadedAt'), formatDateTime(trip.loadedAt, locale: locale)),
                      _event(i18n.t('trip.transitAt'), formatDateTime(trip.inTransitAt, locale: locale)),
                      _event(i18n.t('trip.arrivedAt'), formatDateTime(trip.arrivedAt, locale: locale)),
                      _event(i18n.t('trip.deliveredAt'), formatDateTime(trip.deliveredAt, locale: locale)),
                      _event(i18n.t('trip.completedAt'), formatDateTime(trip.completedAt, locale: locale)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    AppButton(
                      label: i18n.t('trip.viewTracking'),
                      icon: Icons.my_location_outlined,
                      onPressed: () => context.push('/trips/${trip.id}/tracking'),
                    ),
                    AppButton(
                      label: i18n.t('trip.viewPod'),
                      icon: Icons.verified_outlined,
                      variant: AppButtonVariant.secondary,
                      onPressed: () => context.push('/trips/${trip.id}/pod'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _event(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: AppColors.muted))),
          Text(value),
        ],
      ),
    );
  }
}

class TripTrackingScreen extends ConsumerWidget {
  const TripTrackingScreen({super.key, required this.tripId});

  final int tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n = ref.i18n;
    final value = ref.watch(tripDetailProvider(tripId));
    return PageScaffold(
      title: i18n.t('tracking.title'),
      body: AsyncBody<Trip>(
        value: value,
        i18n: i18n,
        onRetry: () => ref.invalidate(tripDetailProvider(tripId)),
        builder: (trip) => ContentWidth(child: TrackingPanel(trip: trip, i18n: i18n)),
      ),
    );
  }
}
