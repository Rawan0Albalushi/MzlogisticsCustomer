import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/i18n_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/app_list_card.dart';
import '../../../shared/widgets/app_progress.dart';
import '../../../shared/widgets/app_route_line.dart';
import '../../../shared/widgets/async_body.dart';
import '../../../shared/widgets/entity_summary_card.dart';
import '../../../shared/widgets/info_row.dart';
import '../../../shared/widgets/page_scaffold.dart';
import '../../../shared/widgets/status_badge.dart';
import '../data/job_model.dart';
import 'job_providers.dart';

class JobDetailScreen extends ConsumerWidget {
  const JobDetailScreen({super.key, required this.jobId});

  final int jobId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n = ref.i18n;
    final value = ref.watch(jobDetailProvider(jobId));

    return PageScaffold(
      title: i18n.t('job.detail'),
      body: AsyncBody<TransportJob>(
        value: value,
        i18n: i18n,
        onRetry: () => ref.invalidate(jobDetailProvider(jobId)),
        onRefresh: () async {
          ref.invalidate(jobDetailProvider(jobId));
          await ref.read(jobDetailProvider(jobId).future);
        },
        builder: (job) {
          final locale = i18n.locale.languageCode;
          final progress = ((job.progressPercent ?? 0) / 100).clamp(0.0, 1.0);
          return ContentWidth(
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                EntitySummaryCard(
                  title: job.reference ?? i18n.t('job.detail'),
                  subtitle: i18n.t('job.hint'),
                  icon: Icons.assignment_turned_in_rounded,
                  badge: StatusBadge(status: job.status ?? '', label: i18n.status(job.status)),
                  facts: [
                    EntityFact(
                      i18n.t('common.provider'),
                      job.provider?.displayName(locale) ?? '—',
                    ),
                    EntityFact(
                      i18n.t('common.amount'),
                      formatAmount(job.totalPrice, currency: job.currency ?? 'OMR'),
                    ),
                    EntityFact(
                      i18n.t('common.progress'),
                      formatPercent(job.progressPercent),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SectionCard(
                  title: i18n.t('job.progress'),
                  icon: Icons.bolt_rounded,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppStatusStepper(
                        steps: [
                          AppStepItem(
                            id: 'pending_dispatch',
                            label: i18n.status('pending_dispatch'),
                            icon: Icons.hourglass_top_rounded,
                          ),
                          AppStepItem(
                            id: 'in_progress',
                            label: i18n.status('in_progress'),
                            icon: Icons.local_shipping_rounded,
                          ),
                          AppStepItem(
                            id: 'completed',
                            label: i18n.status('completed'),
                            icon: Icons.verified_rounded,
                          ),
                        ],
                        currentId: _jobStep(job.status),
                        failed: job.status == 'cancelled',
                      ),
                      const SizedBox(height: 18),
                      AppProgressBar(
                        value: progress,
                        caption: i18n.t('job.deliveredOf', {
                          'delivered': formatNumber(job.deliveredQuantity),
                          'total': formatNumber(job.totalQuantity),
                        }),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          AppMetricChip(
                            icon: Icons.handshake_rounded,
                            label: i18n.t('common.provider'),
                            value: job.provider?.displayName(locale) ?? '—',
                          ),
                          AppMetricChip(
                            icon: Icons.payments_rounded,
                            label: i18n.t('common.amount'),
                            value: formatAmount(job.totalPrice, currency: job.currency ?? 'OMR'),
                          ),
                          AppMetricChip(
                            icon: Icons.tag_rounded,
                            label: i18n.t('common.reference'),
                            value: job.shipment?.reference ?? '—',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  i18n.t('job.trips'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                if (job.trips.isEmpty)
                  Text(i18n.t('job.noTrips'), style: const TextStyle(color: AppColors.muted))
                else
                  Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        for (var index = 0; index < job.trips.length; index++) ...[
                          if (index > 0) const Divider(height: 1, indent: 16, endIndent: 16),
                          AppListCard(
                            embedded: true,
                            onTap: () => context.push('/trips/${job.trips[index].id}'),
                            title: job.trips[index].reference ??
                                i18n.t('trip.sequence', {'n': '${job.trips[index].sequence ?? ''}'}),
                            subtitleWidget: AppRouteLine(
                              compact: true,
                              from: job.trips[index].pickupCity ?? job.trips[index].pickupAddress ?? '—',
                              to: job.trips[index].deliveryCity ?? job.trips[index].deliveryAddress ?? '—',
                            ),
                            trailing: StatusBadge(
                              status: job.trips[index].status ?? '',
                              label: i18n.status(job.trips[index].status),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

String _jobStep(String? status) {
  return switch (status) {
    'in_progress' => 'in_progress',
    'completed' => 'completed',
    _ => 'pending_dispatch',
  };
}
