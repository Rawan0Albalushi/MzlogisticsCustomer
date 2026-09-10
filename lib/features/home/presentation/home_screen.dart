import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/i18n_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_list_card.dart';
import '../../../shared/widgets/async_body.dart';
import '../../../shared/widgets/page_scaffold.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../shipments/presentation/shipment_providers.dart';
import '../data/dashboard_model.dart';
import 'home_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n = ref.i18n;
    final dashboard = ref.watch(dashboardProvider);
    final shipments = ref.watch(shipmentsProvider);

    return AsyncBody<DashboardSummary>(
      value: dashboard,
      i18n: i18n,
      onRetry: () => ref.invalidate(dashboardProvider),
      builder: (summary) {
        final metrics = [
          _Metric(i18n.t('home.shipmentsOpen'), '${summary.shipmentsOpen}', Icons.inventory_2_outlined),
          _Metric(i18n.t('home.quotationsPending'), '${summary.quotationsPending}', Icons.request_quote_outlined),
          _Metric(i18n.t('home.jobsActive'), '${summary.jobsActive}', Icons.assignment_outlined),
          _Metric(i18n.t('home.tripsInTransit'), '${summary.tripsInTransit}', Icons.local_shipping_outlined),
          _Metric(
            i18n.t('home.paymentsCompleted'),
            formatAmount(summary.paymentsCompletedAmount),
            Icons.payments_outlined,
          ),
          _Metric(i18n.t('home.invoices'), '${summary.invoicesCount}', Icons.receipt_long_outlined),
        ];

        return ContentWidth(
          child: ListView(
            children: [
              Text(
                i18n.t('home.subtitle'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.muted,
                      height: 1.4,
                    ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: AppButton(
                  label: i18n.t('home.newShipment'),
                  icon: Icons.add,
                  onPressed: () => context.push('/shipments/new'),
                ),
              ),
              const SizedBox(height: 20),
              _EqualMetricGrid(
                metrics: metrics,
                columns: context.isWide
                    ? 4
                    : context.isDesktop
                    ? 3
                    : 2,
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      i18n.t('home.recentShipments'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/shipments'),
                    child: Text(i18n.t('common.viewAll')),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              shipments.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                error: (error, _) => Text('$error', style: const TextStyle(color: AppColors.danger)),
                data: (page) {
                  if (page.items.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        i18n.t('home.noShipments'),
                        style: const TextStyle(color: AppColors.muted),
                      ),
                    );
                  }
                  return Column(
                    children: [
                      for (final shipment in page.items.take(5))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: AppListCard(
                            onTap: () => context.push('/shipments/${shipment.id}'),
                            title: shipment.reference ?? shipment.cargoType ?? '—',
                            subtitle: shipment.routeLabel,
                            trailing: StatusBadge(
                              status: shipment.status ?? '',
                              label: i18n.status(shipment.status),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Metric {
  const _Metric(this.label, this.value, this.icon);

  final String label;
  final String value;
  final IconData icon;
}

class _EqualMetricGrid extends StatelessWidget {
  const _EqualMetricGrid({
    required this.metrics,
    required this.columns,
  });

  final List<_Metric> metrics;
  final int columns;

  @override
  Widget build(BuildContext context) {
    const gap = 12.0;
    final rows = <List<_Metric>>[];
    for (var index = 0; index < metrics.length; index += columns) {
      rows.add(
        metrics.sublist(index, index + columns > metrics.length ? metrics.length : index + columns),
      );
    }

    return Column(
      children: [
        for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) ...[
          if (rowIndex > 0) const SizedBox(height: gap),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var column = 0; column < columns; column++) ...[
                  if (column > 0) const SizedBox(width: gap),
                  Expanded(
                    child: column < rows[rowIndex].length
                        ? _MetricCard(item: rows[rowIndex][column])
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.item});

  final _Metric item;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppIconWell(icon: item.icon),
            const SizedBox(height: 10),
            Text(
              item.label,
              style: text.bodySmall?.copyWith(
                color: AppColors.muted,
                height: 1.35,
              ),
            ),
            const Spacer(),
            const SizedBox(height: 6),
            Text(
              item.value,
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
