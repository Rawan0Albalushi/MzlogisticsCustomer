import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/i18n_controller.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/pagination_meta.dart';
import '../../../shared/widgets/app_filters.dart';
import '../../../shared/widgets/app_grouped_list.dart';
import '../../../shared/widgets/app_list_card.dart';
import '../../../shared/widgets/async_body.dart';
import '../../../shared/widgets/page_scaffold.dart';
import '../../../shared/widgets/status_badge.dart';
import '../data/payment_model.dart';
import 'payment_providers.dart';

enum _PaymentFilter { all, pending, paid, failed }

class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({super.key});

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
  final _search = TextEditingController();
  _PaymentFilter _filter = _PaymentFilter.all;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref.invalidate(paymentsProvider);
    await ref.read(paymentsProvider.future);
  }

  List<Payment> _visible(List<Payment> items) {
    final query = _search.text.trim().toLowerCase();
    return items.where((payment) {
      if (!_matches(payment.status, _filter)) return false;
      return matchesSearch(query, [
        payment.reference,
        payment.method,
        payment.gateway,
        payment.gatewayReference,
      ]);
    }).toList();
  }

  List<AppFilterOption<_PaymentFilter>> _options(I18nBundle i18n, List<Payment> items) {
    int count(_PaymentFilter filter) => items.where((item) => _matches(item.status, filter)).length;
    return [
      AppFilterOption(
        value: _PaymentFilter.all,
        label: i18n.t('common.filterAll'),
        icon: Icons.apps_rounded,
        count: count(_PaymentFilter.all),
      ),
      AppFilterOption(
        value: _PaymentFilter.pending,
        label: i18n.status('pending'),
        icon: Icons.hourglass_empty_rounded,
        count: count(_PaymentFilter.pending),
      ),
      AppFilterOption(
        value: _PaymentFilter.paid,
        label: i18n.status('paid'),
        icon: Icons.check_circle_outline,
        count: count(_PaymentFilter.paid),
      ),
      AppFilterOption(
        value: _PaymentFilter.failed,
        label: i18n.status('failed'),
        icon: Icons.error_outline,
        count: count(_PaymentFilter.failed),
      ),
    ];
  }

  void _clear() {
    setState(() {
      _filter = _PaymentFilter.all;
      _search.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final i18n = ref.i18n;
    final value = ref.watch(paymentsProvider);

    return AsyncBody<PagedResult<Payment>>(
      value: value,
      i18n: i18n,
      onRetry: () => ref.invalidate(paymentsProvider),
      onRefresh: _refresh,
      isEmpty: (data) => data.items.isEmpty,
      emptyTitle: i18n.t('payment.empty'),
      emptyIcon: Icons.payments_outlined,
      builder: (page) {
        final visible = _visible(page.items);
        final toolbar = AppListToolbar<_PaymentFilter>(
          i18n: i18n,
          search: _search,
          searchHint: i18n.t('payment.searchHint'),
          onSearchChanged: () => setState(() {}),
          options: _options(i18n, page.items),
          selected: _filter,
          onSelected: (filter) => setState(() => _filter = filter),
        );

        if (visible.isEmpty) {
          return ContentWidth(
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                toolbar,
                const SizedBox(height: 24),
                AppFilterEmpty(i18n: i18n, onClear: _clear),
              ],
            ),
          );
        }

        if (context.isDesktop) {
          return ContentWidth(
            child: AppTableCard(
              header: toolbar,
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
                  for (final payment in visible)
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
          header: toolbar,
          items: visible,
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

bool _matches(String? status, _PaymentFilter filter) {
  return switch (filter) {
    _PaymentFilter.all => true,
    _PaymentFilter.pending => status == 'pending' || status == 'processing',
    _PaymentFilter.paid => status == 'paid',
    _PaymentFilter.failed => status == 'failed' || status == 'refunded',
  };
}
