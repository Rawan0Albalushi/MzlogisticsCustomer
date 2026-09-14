import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/i18n_controller.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/pagination_meta.dart';
import '../../../shared/widgets/app_grouped_list.dart';
import '../../../shared/widgets/app_list_card.dart';
import '../../../shared/widgets/async_body.dart';
import '../../../shared/widgets/page_scaffold.dart';
import '../../../shared/widgets/status_badge.dart';
import '../data/payment_model.dart';
import 'payment_providers.dart';

class PaymentsScreen extends ConsumerWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n = ref.i18n;
    final value = ref.watch(paymentsProvider);

    Future<void> refresh() async {
      ref.invalidate(paymentsProvider);
      await ref.read(paymentsProvider.future);
    }

    return AsyncBody<PagedResult<Payment>>(
      value: value,
      i18n: i18n,
      onRetry: () => ref.invalidate(paymentsProvider),
      onRefresh: refresh,
      isEmpty: (data) => data.items.isEmpty,
      emptyTitle: i18n.t('payment.empty'),
      emptyIcon: Icons.payments_outlined,
      builder: (page) {
        if (context.isDesktop) {
          return ContentWidth(
            child: AppTableCard(
              child: DataTable(
                columns: [
                  DataColumn(label: Text(i18n.t('common.reference'))),
                  DataColumn(label: Text(i18n.t('common.amount'))),
                  DataColumn(label: Text(i18n.t('common.method'))),
                  DataColumn(label: Text(i18n.t('common.status'))),
                  DataColumn(label: Text(i18n.t('payment.paidAt'))),
                  DataColumn(label: Text(i18n.t('payment.gateway'))),
                ],
                rows: [
                  for (final payment in page.items)
                    DataRow(
                      cells: [
                        DataCell(Text(payment.reference ?? '—')),
                        DataCell(Text(formatAmount(payment.amount, currency: payment.currency ?? 'OMR'))),
                        DataCell(Text(payment.method ?? '—')),
                        DataCell(StatusBadge(status: payment.status ?? '', label: i18n.status(payment.status))),
                        DataCell(Text(formatDateTime(payment.paidAt, locale: i18n.locale.languageCode))),
                        DataCell(Text(payment.gateway ?? payment.gatewayReference ?? '—')),
                      ],
                    ),
                ],
              ),
            ),
          );
        }

        return AppGroupedListView<Payment>(
          items: page.items,
          itemBuilder: (context, payment) {
            return AppListCard(
              embedded: true,
              title: payment.reference ?? i18n.t('payment.title'),
              subtitle: payment.method ?? '',
              meta: formatAmount(payment.amount, currency: payment.currency ?? 'OMR'),
              trailing: StatusBadge(status: payment.status ?? '', label: i18n.status(payment.status)),
            );
          },
        );
      },
    );
  }
}
