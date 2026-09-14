import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/i18n_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/async_body.dart';
import '../../../shared/widgets/page_scaffold.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/models/pagination_meta.dart';
import '../../shipments/data/shipment_model.dart';
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
        return ContentWidth(
          child: RefreshIndicator(
            color: AppColors.navy,
            onRefresh: () async {
              ref.invalidate(dashboardProvider);
              ref.invalidate(shipmentsProvider);
              await Future.wait([
                ref.read(dashboardProvider.future),
                ref.read(shipmentsProvider.future),
              ]);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                if (context.isDesktop)
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Expanded(flex: 4, child: _HeroCard(fillHeight: true)),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 6,
                          child: _SnapshotSection(i18n: i18n, summary: summary),
                        ),
                      ],
                    ),
                  )
                else ...[
                  const _HeroCard(),
                  const SizedBox(height: 24),
                  _SnapshotSection(i18n: i18n, summary: summary),
                ],
                const SizedBox(height: 24),
                _QuickActions(i18n: i18n),
                const SizedBox(height: 24),
                _RecentSection(i18n: i18n, shipments: shipments),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HeroCard extends ConsumerWidget {
  const _HeroCard({this.fillHeight = false});

  final bool fillHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n = ref.i18n;
    final text = Theme.of(context).textTheme;
    final body = Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.navySoft,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: const Icon(Icons.local_shipping_outlined, color: AppColors.navy, size: 22),
          ),
          const SizedBox(height: 14),
          Text(
            i18n.t('home.heroTitle'),
            style: text.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            i18n.t('home.heroBody'),
            style: text.bodyMedium?.copyWith(
              color: AppColors.muted,
              height: 1.45,
            ),
          ),
          if (fillHeight) const Spacer() else const SizedBox(height: 18),
          if (fillHeight) const SizedBox(height: 18),
          AppButton(
            label: i18n.t('home.newShipment'),
            icon: Icons.add,
            expanded: true,
            onPressed: () => context.push('/shipments/new'),
          ),
        ],
      ),
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ColoredBox(
            color: AppColors.accentFrom,
            child: SizedBox(height: 3),
          ),
          if (fillHeight) Expanded(child: body) else body,
        ],
      ),
    );
  }
}

class _SnapshotSection extends StatelessWidget {
  const _SnapshotSection({
    required this.i18n,
    required this.summary,
  });

  final I18nBundle i18n;
  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final tiles = [
      _SnapshotTileData(
        label: i18n.t('home.shipmentsOpen'),
        value: '${summary.shipmentsOpen}',
        icon: Icons.inventory_2_outlined,
        onTap: () => context.go('/shipments'),
      ),
      _SnapshotTileData(
        label: i18n.t('home.quotationsPending'),
        value: '${summary.quotationsPending}',
        icon: Icons.request_quote_outlined,
        emphasize: summary.quotationsPending > 0,
        onTap: () => context.go('/shipments'),
      ),
      _SnapshotTileData(
        label: i18n.t('home.jobsActive'),
        value: '${summary.jobsActive}',
        icon: Icons.assignment_outlined,
        onTap: () => context.go('/jobs'),
      ),
      _SnapshotTileData(
        label: i18n.t('home.tripsInTransit'),
        value: '${summary.tripsInTransit}',
        icon: Icons.local_shipping_outlined,
        emphasize: summary.tripsInTransit > 0,
        onTap: () => context.go('/jobs'),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label: i18n.t('home.snapshot')),
        const SizedBox(height: 10),
        _TwoColumnGrid(
          children: [
            for (final tile in tiles) _SnapshotTile(data: tile),
          ],
        ),
        const SizedBox(height: 12),
        _TwoColumnGrid(
          children: [
            _SnapshotTile(
              data: _SnapshotTileData(
                label: i18n.t('home.paymentsCompleted'),
                value: formatAmount(summary.paymentsCompletedAmount),
                icon: Icons.payments_outlined,
                compactValue: true,
                onTap: () => context.go(context.isDesktop ? '/payments' : '/billing'),
              ),
            ),
            _SnapshotTile(
              data: _SnapshotTileData(
                label: i18n.t('home.invoices'),
                value: '${summary.invoicesCount}',
                icon: Icons.receipt_long_outlined,
                onTap: () => context.go(context.isDesktop ? '/invoices' : '/billing'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SnapshotTileData {
  const _SnapshotTileData({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    this.emphasize = false,
    this.compactValue = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;
  final bool emphasize;
  final bool compactValue;
}

class _SnapshotTile extends StatelessWidget {
  const _SnapshotTile({required this.data});

  final _SnapshotTileData data;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final iconColor = data.emphasize ? AppColors.onNeon : AppColors.navy;
    final iconBg = data.emphasize ? AppColors.amberSoft : AppColors.mist;

    return Card(
      color: data.emphasize ? AppColors.amberSoft : AppColors.white,
      child: InkWell(
        onTap: data.onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: data.emphasize ? AppColors.white : iconBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(data.icon, color: iconColor, size: 18),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: AppColors.muted.withValues(alpha: 0.7),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                data.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: (data.compactValue ? text.titleMedium : text.headlineSmall)?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                  height: 1.1,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                data.label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: text.bodySmall?.copyWith(
                  color: AppColors.muted,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.i18n});

  final I18nBundle i18n;

  @override
  Widget build(BuildContext context) {
    final actions = [
      (i18n.t('nav.shipmentsShort'), Icons.inventory_2_outlined, '/shipments'),
      (i18n.t('nav.jobs'), Icons.assignment_outlined, '/jobs'),
      (i18n.t('nav.invoices'), Icons.receipt_long_outlined, '/invoices'),
      (i18n.t('nav.payments'), Icons.payments_outlined, '/payments'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label: i18n.t('home.quickActions')),
        const SizedBox(height: 10),
        Row(
          children: [
            for (var index = 0; index < actions.length; index++) ...[
              if (index > 0) const SizedBox(width: 10),
              Expanded(
                child: _QuickAction(
                  label: actions[index].$1,
                  icon: actions[index].$2,
                  onTap: () => context.go(actions[index].$3),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          child: Column(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.navySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.navy, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentSection extends StatelessWidget {
  const _RecentSection({
    required this.i18n,
    required this.shipments,
  });

  final I18nBundle i18n;
  final AsyncValue<PagedResult<ShipmentRequest>> shipments;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _SectionLabel(label: i18n.t('home.recentShipments'))),
            TextButton(
              onPressed: () => context.go('/shipments'),
              child: Text(i18n.t('common.viewAll')),
            ),
          ],
        ),
        const SizedBox(height: 4),
        shipments.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 28),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.navy)),
          ),
          error: (error, _) => Text('$error', style: const TextStyle(color: AppColors.danger)),
          data: (page) {
            final items = page.items.take(5).toList();
            return Card(
              clipBehavior: Clip.antiAlias,
              child: items.isEmpty
                  ? _RecentEmpty(i18n: i18n)
                  : Column(
                      children: [
                        for (var index = 0; index < items.length; index++) ...[
                          if (index > 0) const Divider(height: 1, indent: 16, endIndent: 16),
                          _ShipmentRow(i18n: i18n, shipment: items[index]),
                        ],
                      ],
                    ),
            );
          },
        ),
      ],
    );
  }
}

class _RecentEmpty extends StatelessWidget {
  const _RecentEmpty({required this.i18n});

  final I18nBundle i18n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.mist,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.inventory_2_outlined, color: AppColors.navy),
          ),
          const SizedBox(height: 12),
          Text(
            i18n.t('home.noShipments'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            i18n.t('home.emptyHint'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.muted,
                  height: 1.4,
                ),
          ),
        ],
      ),
    );
  }
}

class _ShipmentRow extends StatelessWidget {
  const _ShipmentRow({
    required this.i18n,
    required this.shipment,
  });

  final I18nBundle i18n;
  final ShipmentRequest shipment;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final from = shipment.pickupCity ?? shipment.pickupAddress ?? '—';
    final to = shipment.deliveryCity ?? shipment.deliveryAddress ?? '—';

    return InkWell(
      onTap: () => context.push('/shipments/${shipment.id}'),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        child: Row(
          children: [
            const _RouteMark(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shipment.reference ?? shipment.cargoType ?? '—',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          from,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.bodySmall?.copyWith(color: AppColors.muted),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(Icons.arrow_forward, size: 12, color: AppColors.navyMuted),
                      ),
                      Flexible(
                        child: Text(
                          to,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.bodySmall?.copyWith(color: AppColors.muted),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            StatusBadge(
              status: shipment.status ?? '',
              label: i18n.status(shipment.status),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.navyMuted),
          ],
        ),
      ),
    );
  }
}

class _RouteMark extends StatelessWidget {
  const _RouteMark();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 14,
      height: 36,
      child: Column(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.navy,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Container(
              width: 2,
              color: AppColors.border,
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.accentFrom,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.onNeon, width: 1.2),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
    );
  }
}

class _TwoColumnGrid extends StatelessWidget {
  const _TwoColumnGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final rows = <List<Widget>>[];
    for (var index = 0; index < children.length; index += 2) {
      rows.add(children.sublist(index, index + 2 > children.length ? children.length : index + 2));
    }

    return Column(
      children: [
        for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) ...[
          if (rowIndex > 0) const SizedBox(height: 10),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: rows[rowIndex][0]),
                const SizedBox(width: 10),
                Expanded(
                  child: rows[rowIndex].length > 1 ? rows[rowIndex][1] : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
