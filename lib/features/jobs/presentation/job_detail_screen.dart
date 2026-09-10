import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/i18n_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/async_body.dart';
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
        builder: (job) {
          final locale = i18n.locale.languageCode;
          final progress = ((job.progressPercent ?? 0) / 100).clamp(0.0, 1.0);
          return ContentWidth(
            child: ListView(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        job.reference ?? i18n.t('job.detail'),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    StatusBadge(status: job.status ?? '', label: i18n.status(job.status)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(i18n.t('job.hint'), style: const TextStyle(color: AppColors.muted)),
                const SizedBox(height: 16),
                SectionCard(
                  title: i18n.t('job.progress'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppTheme.radius),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 10,
                          backgroundColor: AppColors.border,
                          color: AppColors.navy,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${formatPercent(job.progressPercent)} · ${i18n.t('job.deliveredOf', {
                          'delivered': formatNumber(job.deliveredQuantity),
                          'total': formatNumber(job.totalQuantity),
                        })}',
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 24,
                        runSpacing: 12,
                        children: [
                          InfoRow(
                            label: i18n.t('common.provider'),
                            value: job.provider?.displayName(locale) ?? '—',
                          ),
                          InfoRow(
                            label: i18n.t('common.amount'),
                            value: formatAmount(job.totalPrice, currency: job.currency ?? 'OMR'),
                          ),
                          InfoRow(
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
                  ...job.trips.map((trip) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Card(
                        child: ListTile(
                          onTap: () => context.push('/trips/${trip.id}'),
                          title: Text(
                            trip.reference ??
                                i18n.t('trip.sequence', {'n': '${trip.sequence ?? ''}'}),
                          ),
                          subtitle: Text(
                            '${trip.pickupCity ?? '—'} → ${trip.deliveryCity ?? '—'}',
                            style: const TextStyle(color: AppColors.muted),
                          ),
                          trailing: StatusBadge(
                            status: trip.status ?? '',
                            label: i18n.status(trip.status),
                          ),
                        ),
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }
}
