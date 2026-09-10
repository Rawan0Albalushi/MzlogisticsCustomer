import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/i18n_controller.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/pagination_meta.dart';
import '../../../shared/widgets/app_list_card.dart';
import '../../../shared/widgets/async_body.dart';
import '../../../shared/widgets/page_scaffold.dart';
import '../../../shared/widgets/status_badge.dart';
import '../data/job_model.dart';
import 'job_providers.dart';

class JobsListScreen extends ConsumerWidget {
  const JobsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n = ref.i18n;
    final value = ref.watch(jobsProvider);

    return AsyncBody<PagedResult<TransportJob>>(
      value: value,
      i18n: i18n,
      onRetry: () => ref.invalidate(jobsProvider),
      isEmpty: (data) => data.items.isEmpty,
      emptyTitle: i18n.t('job.empty'),
      emptyMessage: i18n.t('job.hint'),
      emptyIcon: Icons.assignment_outlined,
      builder: (page) {
        if (context.isDesktop) {
          return ContentWidth(
            child: Card(
              child: SingleChildScrollView(
                child: DataTable(
                  columns: [
                    DataColumn(label: Text(i18n.t('common.reference'))),
                    DataColumn(label: Text(i18n.t('common.provider'))),
                    DataColumn(label: Text(i18n.t('common.progress'))),
                    DataColumn(label: Text(i18n.t('nav.trips'))),
                    DataColumn(label: Text(i18n.t('common.status'))),
                    DataColumn(label: Text(i18n.t('common.amount'))),
                  ],
                  rows: [
                    for (final job in page.items)
                      DataRow(
                        onSelectChanged: (_) => context.push('/jobs/${job.id}'),
                        cells: [
                          DataCell(Text(job.reference ?? '—')),
                          DataCell(Text(job.provider?.displayName(i18n.locale.languageCode) ?? '—')),
                          DataCell(Text(formatPercent(job.progressPercent))),
                          DataCell(Text('${job.trips.length}')),
                          DataCell(StatusBadge(status: job.status ?? '', label: i18n.status(job.status))),
                          DataCell(Text(formatAmount(job.totalPrice, currency: job.currency ?? 'OMR'))),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: page.items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final job = page.items[index];
            return AppListCard(
              onTap: () => context.push('/jobs/${job.id}'),
              title: job.reference ?? i18n.t('job.detail'),
              subtitle:
                  '${i18n.t('job.deliveredOf', {
                    'delivered': formatNumber(job.deliveredQuantity),
                    'total': formatNumber(job.totalQuantity),
                  })} · ${job.trips.length} ${i18n.t('nav.trips')}',
              meta: formatAmount(job.totalPrice, currency: job.currency ?? 'OMR'),
              trailing: StatusBadge(status: job.status ?? '', label: i18n.status(job.status)),
            );
          },
        );
      },
    );
  }
}
