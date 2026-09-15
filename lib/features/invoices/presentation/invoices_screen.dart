import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
import '../data/invoice_model.dart';
import 'invoice_providers.dart';

enum _InvoiceFilter { all, issued, paid, closed }

class InvoicesScreen extends ConsumerStatefulWidget {
  const InvoicesScreen({super.key});

  @override
  ConsumerState<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends ConsumerState<InvoicesScreen> {
  final _search = TextEditingController();
  _InvoiceFilter _filter = _InvoiceFilter.all;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref.invalidate(invoicesProvider);
    await ref.read(invoicesProvider.future);
  }

  List<Invoice> _visible(List<Invoice> items) {
    final query = _search.text.trim().toLowerCase();
    return items.where((invoice) {
      if (!_matches(invoice.status, _filter)) return false;
      return matchesSearch(query, [
        invoice.reference,
        invoice.type,
        invoice.jobReference,
      ]);
    }).toList();
  }

  List<AppFilterOption<_InvoiceFilter>> _options(I18nBundle i18n, List<Invoice> items) {
    int count(_InvoiceFilter filter) => items.where((item) => _matches(item.status, filter)).length;
    return [
      AppFilterOption(
        value: _InvoiceFilter.all,
        label: i18n.t('common.filterAll'),
        icon: Icons.apps_rounded,
        count: count(_InvoiceFilter.all),
      ),
      AppFilterOption(
        value: _InvoiceFilter.issued,
        label: i18n.status('issued'),
        icon: Icons.receipt_long_outlined,
        count: count(_InvoiceFilter.issued),
      ),
      AppFilterOption(
        value: _InvoiceFilter.paid,
        label: i18n.status('paid'),
        icon: Icons.payments_outlined,
        count: count(_InvoiceFilter.paid),
      ),
      AppFilterOption(
        value: _InvoiceFilter.closed,
        label: i18n.status('void'),
        icon: Icons.block_rounded,
        count: count(_InvoiceFilter.closed),
      ),
    ];
  }

  void _clear() {
    setState(() {
      _filter = _InvoiceFilter.all;
      _search.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final i18n = ref.i18n;
    final value = ref.watch(invoicesProvider);

    return AsyncBody<PagedResult<Invoice>>(
      value: value,
      i18n: i18n,
      onRetry: () => ref.invalidate(invoicesProvider),
      onRefresh: _refresh,
      isEmpty: (data) => data.items.isEmpty,
      emptyTitle: i18n.t('invoice.empty'),
      emptyIcon: Icons.receipt_long_outlined,
      builder: (page) {
        final visible = _visible(page.items);
        final toolbar = AppListToolbar<_InvoiceFilter>(
          i18n: i18n,
          search: _search,
          searchHint: i18n.t('invoice.searchHint'),
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
                  DataColumn(label: Text(i18n.t('common.type'))),
                  DataColumn(label: Text(i18n.t('common.amount'))),
                  DataColumn(label: Text(i18n.t('invoice.issued'))),
                  DataColumn(label: Text(i18n.t('invoice.due'))),
                  DataColumn(label: Text(i18n.t('common.status'))),
                  DataColumn(label: Text(i18n.t('invoice.job'))),
                ],
                rows: [
                  for (final invoice in visible)
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
          );
        }

        return AppGroupedListView<Invoice>(
          header: toolbar,
          items: visible,
          itemBuilder: (context, invoice) {
            return AppListCard(
              embedded: true,
              showChevron: invoice.jobId != null,
              onTap: invoice.jobId == null ? null : () => context.push('/jobs/${invoice.jobId}'),
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

bool _matches(String? status, _InvoiceFilter filter) {
  return switch (filter) {
    _InvoiceFilter.all => true,
    _InvoiceFilter.issued => status == 'issued',
    _InvoiceFilter.paid => status == 'paid',
    _InvoiceFilter.closed => status == 'void',
  };
}
