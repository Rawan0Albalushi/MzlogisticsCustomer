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
import '../data/invoice_model.dart';
import 'invoice_providers.dart';

class InvoicesScreen extends ConsumerWidget {
  const InvoicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n = ref.i18n;
    final value = ref.watch(invoicesProvider);

    return AsyncBody<PagedResult<Invoice>>(
      value: value,
      i18n: i18n,
      onRetry: () => ref.invalidate(invoicesProvider),
      isEmpty: (data) => data.items.isEmpty,
      emptyTitle: i18n.t('invoice.empty'),
      emptyIcon: Icons.receipt_long_outlined,
      builder: (page) {
        if (context.isDesktop) {
          return ContentWidth(
            child: Card(
              child: SingleChildScrollView(
                child: DataTable(
                  columns: [
                    DataColumn(label: Text(i18n.t('common.reference'))),
                    DataColumn(label: Text(i18n.t('common.type'))),
                    DataColumn(label: Text(i18n.t('common.amount'))),
                    DataColumn(label: Text(i18n.t('invoice.issued'))),
                    DataColumn(label: Text(i18n.t('invoice.due'))),
                    DataColumn(label: Text(i18n.t('common.status'))),
                    DataColumn(label: Text(i18n.t('invoice.job'))),
                  ],
                  rows: [
                    for (final invoice in page.items)
                      DataRow(
                        cells: [
                          DataCell(Text(invoice.reference ?? '—')),
                          DataCell(Text(invoice.type ?? '—')),
                          DataCell(Text(formatAmount(invoice.amount, currency: invoice.currency ?? 'OMR'))),
                          DataCell(Text(formatDate(invoice.issuedAt, locale: i18n.locale.languageCode))),
                          DataCell(Text(formatDate(invoice.dueAt, locale: i18n.locale.languageCode))),
                          DataCell(StatusBadge(status: invoice.status ?? '', label: i18n.status(invoice.status))),
                          DataCell(
                            invoice.jobId == null
                                ? const Text('—')
                                : TextButton(
                                    onPressed: () => context.push('/jobs/${invoice.jobId}'),
                                    child: Text(invoice.jobReference ?? i18n.t('common.view')),
                                  ),
                          ),
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
            final invoice = page.items[index];
            return AppListCard(
              title: invoice.reference ?? i18n.t('invoice.title'),
              subtitle: invoice.type ?? '',
              meta: formatAmount(invoice.amount, currency: invoice.currency ?? 'OMR'),
              trailing: StatusBadge(status: invoice.status ?? '', label: i18n.status(invoice.status)),
            );
          },
        );
      },
    );
  }
}
