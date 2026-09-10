import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/i18n_controller.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/pagination_meta.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_list_card.dart';
import '../../../shared/widgets/async_body.dart';
import '../../../shared/widgets/page_scaffold.dart';
import '../../../shared/widgets/status_badge.dart';
import '../data/shipment_model.dart';
import 'shipment_providers.dart';

class ShipmentsListScreen extends ConsumerWidget {
  const ShipmentsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n = ref.i18n;
    final value = ref.watch(shipmentsProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: AppButton(
              label: i18n.t('shipment.create'),
              icon: Icons.add,
              onPressed: () => context.push('/shipments/new'),
            ),
          ),
        ),
        Expanded(
          child: AsyncBody<PagedResult<ShipmentRequest>>(
            value: value,
            i18n: i18n,
            onRetry: () => ref.invalidate(shipmentsProvider),
            isEmpty: (data) => data.items.isEmpty,
            emptyTitle: i18n.t('shipment.empty'),
            emptyMessage: i18n.t('home.emptyHint'),
            emptyIcon: Icons.inventory_2_outlined,
            emptyAction: AppButton(
              label: i18n.t('shipment.create'),
              onPressed: () => context.push('/shipments/new'),
            ),
            builder: (page) {
              if (context.isDesktop) {
                return ContentWidth(
                  child: Card(
                    child: SingleChildScrollView(
                      child: DataTable(
                        columns: [
                          DataColumn(label: Text(i18n.t('common.reference'))),
                          DataColumn(label: Text(i18n.t('shipment.cargoType'))),
                          DataColumn(label: Text(i18n.t('shipment.route'))),
                          DataColumn(label: Text(i18n.t('shipment.weight'))),
                          DataColumn(label: Text(i18n.t('common.status'))),
                          DataColumn(label: Text(i18n.t('common.date'))),
                        ],
                        rows: [
                          for (final item in page.items)
                            DataRow(
                              onSelectChanged: (_) => context.push('/shipments/${item.id}'),
                              cells: [
                                DataCell(Text(item.reference ?? '—')),
                                DataCell(Text(item.cargoType ?? '—')),
                                DataCell(Text(item.routeLabel)),
                                DataCell(Text('${formatNumber(item.weightTons)} ${i18n.t('common.tons')}')),
                                DataCell(StatusBadge(status: item.status ?? '', label: i18n.status(item.status))),
                                DataCell(Text(formatDate(item.requiredDate, locale: i18n.locale.languageCode))),
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
                  final item = page.items[index];
                  return AppListCard(
                    onTap: () => context.push('/shipments/${item.id}'),
                    title: item.reference ?? item.cargoType ?? '—',
                    subtitle: item.routeLabel,
                    meta:
                        '${formatNumber(item.weightTons)} ${i18n.t('common.tons')} · ${formatDate(item.requiredDate, locale: i18n.locale.languageCode)}',
                    trailing: StatusBadge(status: item.status ?? '', label: i18n.status(item.status)),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
