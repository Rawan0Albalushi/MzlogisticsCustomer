import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/i18n_controller.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_progress.dart';
import '../../../shared/widgets/app_route_line.dart';
import '../../../shared/widgets/async_body.dart';
import '../../../shared/widgets/entity_summary_card.dart';
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
        onRefresh: () async {
          ref.invalidate(tripDetailProvider(tripId));
          await ref.read(tripDetailProvider(tripId).future);
        },
        builder: (trip) {
          final locale = i18n.locale.languageCode;
          return ContentWidth(
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                EntitySummaryCard(
                  title: trip.reference ?? i18n.t('trip.sequence', {'n': '${trip.sequence ?? ''}'}),
                  subtitle: i18n.t('trip.hint'),
                  icon: Icons.local_shipping_rounded,
                  badge: StatusBadge(status: trip.status ?? '', label: i18n.status(trip.status)),
                  facts: [
                    EntityFact(i18n.t('trip.driver'), trip.driver?.name ?? i18n.t('common.notAvailable')),
                    EntityFact(i18n.t('trip.truck'), trip.truck?.plateNumber ?? i18n.t('common.notAvailable')),
                  ],
                  footer: AppRouteLine(
                    from: trip.pickupCity ?? trip.pickupAddress ?? '—',
                    to: trip.deliveryCity ?? trip.deliveryAddress ?? '—',
                  ),
                ),
                const SizedBox(height: 16),
                SectionCard(
                  title: i18n.t('progress.stage'),
                  icon: Icons.alt_route_rounded,
                  child: AppStatusStepper(
                    steps: [
                      AppStepItem(id: 'assigned', label: i18n.status('assigned'), icon: Icons.person_pin_circle_rounded),
                      AppStepItem(id: 'loaded', label: i18n.status('loaded'), icon: Icons.inventory_2_rounded),
                      AppStepItem(id: 'in_transit', label: i18n.status('in_transit'), icon: Icons.near_me_rounded),
                      AppStepItem(id: 'delivered', label: i18n.status('delivered'), icon: Icons.flag_rounded),
                    ],
                    currentId: _tripStep(trip.status),
                    failed: trip.status == 'cancelled',
                  ),
                ),
                const SizedBox(height: 16),
                SectionCard(
                  title: i18n.t('common.details'),
                  icon: Icons.info_rounded,
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
                  icon: Icons.history_rounded,
                  child: AppTimeline(
                    events: [
                      AppTimelineEvent(
                        label: i18n.t('trip.assignedAt'),
                        value: formatDateTime(trip.assignedAt, locale: locale),
                        icon: Icons.assignment_ind_rounded,
                        done: trip.assignedAt != null,
                        current: trip.status == 'assigned' || trip.status == 'unassigned',
                      ),
                      AppTimelineEvent(
                        label: i18n.t('trip.pickupAt'),
                        value: formatDateTime(trip.arrivedPickupAt, locale: locale),
                        icon: Icons.trip_origin_rounded,
                        done: trip.arrivedPickupAt != null,
                        current: trip.status == 'arrived_at_pickup',
                      ),
                      AppTimelineEvent(
                        label: i18n.t('trip.loadedAt'),
                        value: formatDateTime(trip.loadedAt, locale: locale),
                        icon: Icons.inventory_2_rounded,
                        done: trip.loadedAt != null,
                        current: trip.status == 'loaded',
                      ),
                      AppTimelineEvent(
                        label: i18n.t('trip.transitAt'),
                        value: formatDateTime(trip.inTransitAt, locale: locale),
                        icon: Icons.near_me_rounded,
                        done: trip.inTransitAt != null,
                        current: trip.status == 'in_transit',
                      ),
                      AppTimelineEvent(
                        label: i18n.t('trip.arrivedAt'),
                        value: formatDateTime(trip.arrivedAt, locale: locale),
                        icon: Icons.place_rounded,
                        done: trip.arrivedAt != null,
                        current: trip.status == 'arrived',
                      ),
                      AppTimelineEvent(
                        label: i18n.t('trip.deliveredAt'),
                        value: formatDateTime(trip.deliveredAt, locale: locale),
                        icon: Icons.flag_rounded,
                        done: trip.deliveredAt != null,
                        current: trip.status == 'delivered',
                      ),
                      AppTimelineEvent(
                        label: i18n.t('trip.completedAt'),
                        value: formatDateTime(trip.completedAt, locale: locale),
                        icon: Icons.verified_rounded,
                        done: trip.completedAt != null,
                        current: trip.status == 'completed',
                      ),
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
                      icon: Icons.near_me_rounded,
                      onPressed: () => context.push('/trips/${trip.id}/tracking'),
                    ),
                    AppButton(
                      label: i18n.t('trip.viewPod'),
                      icon: Icons.verified_rounded,
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
}

String _tripStep(String? status) {
  return switch (status) {
    'loaded' => 'loaded',
    'in_transit' || 'arrived' => 'in_transit',
    'delivered' || 'completed' => 'delivered',
    _ => 'assigned',
  };
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
