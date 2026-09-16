import 'package:flutter/material.dart';

import '../../../../core/i18n/i18n_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_progress.dart';
import '../../../../shared/widgets/info_row.dart';
import '../../data/customer_trip_progress.dart';
import '../../data/trip_model.dart';
import 'trip_status.dart';

class TripProgressCard extends StatelessWidget {
  const TripProgressCard({
    super.key,
    required this.i18n,
    required this.trip,
  });

  final I18nBundle i18n;
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final locale = i18n.locale.languageCode;
    final stage = CustomerTripProgress.stageOf(trip.status);
    final failed = CustomerTripProgress.isFailed(trip.status);
    final currentIndex = CustomerTripProgress.indexOf(trip.status);
    final delivered = stage == CustomerTripProgress.delivered;

    return SectionCard(
      title: i18n.t('trip.progress'),
      icon: Icons.alt_route_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppStatusStepper(
            steps: [
              AppStepItem(
                id: CustomerTripProgress.assigned,
                label: i18n.t('trip.stage.assigned'),
                icon: Icons.person_pin_circle_rounded,
              ),
              AppStepItem(
                id: CustomerTripProgress.loaded,
                label: i18n.t('trip.stage.loaded'),
                icon: Icons.inventory_2_rounded,
              ),
              AppStepItem(
                id: CustomerTripProgress.inTransit,
                label: i18n.t('trip.stage.in_transit'),
                icon: Icons.local_shipping_rounded,
              ),
              AppStepItem(
                id: CustomerTripProgress.delivered,
                label: i18n.t('trip.stage.delivered'),
                icon: Icons.flag_rounded,
              ),
            ],
            currentId: failed
                ? CustomerTripProgress.assigned
                : stage,
            failed: failed,
          ),
          const SizedBox(height: 14),
          Text(
            customerTripStageHint(i18n, trip.status),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: failed ? AppColors.danger : AppColors.muted,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          AppTimeline(
            events: [
              for (var index = 0;
                  index < CustomerTripProgress.stages.length;
                  index++)
                AppTimelineEvent(
                  label: i18n.t(
                    'trip.stage.${CustomerTripProgress.stages[index]}',
                  ),
                  value: formatDateTime(
                    CustomerTripProgress.timestampFor(
                      trip,
                      CustomerTripProgress.stages[index],
                    ),
                    locale: locale,
                  ),
                  icon: tripStatusIcon(CustomerTripProgress.stages[index]),
                  done: !failed && (index < currentIndex || delivered),
                  current: !failed && !delivered && index == currentIndex,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
