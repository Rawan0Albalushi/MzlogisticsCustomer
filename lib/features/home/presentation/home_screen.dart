import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/i18n_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/app_appear.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/async_body.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/page_scaffold.dart';
import '../../../shared/models/pagination_meta.dart';
import '../../shipments/data/shipment_model.dart';
import '../../shipments/presentation/shipment_providers.dart';
import '../../shipments/presentation/widgets/shipment_card.dart';
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
          padding: EdgeInsets.fromLTRB(context.isDesktop ? 24 : 20, 12, context.isDesktop ? 24 : 20, 28),
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
                _RecentSection(
                  i18n: i18n,
                  shipments: shipments,
                  onRetry: () => ref.invalidate(shipmentsProvider),
                ),
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
    required this.onRetry,
  });

  final I18nBundle i18n;
  final AsyncValue<PagedResult<ShipmentRequest>> shipments;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final columns = context.isMobile ? 1 : 2;
    final limit = context.isMobile ? 4 : 6;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _SectionLabel(label: i18n.t('home.recentShipments'))),
            TextButton.icon(
              onPressed: () => context.go('/shipments'),
              iconAlignment: IconAlignment.end,
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              label: Text(i18n.t('common.viewAll')),
            ),
          ],
        ),
        const SizedBox(height: 8),
        shipments.when(
          loading: () => _RecentLoading(columns: columns),
          error: (error, _) => Card(
            child: ErrorState(i18n: i18n, error: error, onRetry: onRetry),
          ),
          data: (page) {
            final items = page.items.take(limit).toList();
            if (items.isEmpty) return _RecentEmpty(i18n: i18n);

            final cards = [
              for (var index = 0; index < items.length; index++)
                AppAppear(
                  index: index,
                  child: ShipmentCard(
                    i18n: i18n,
                    shipment: items[index],
                    compact: true,
                  ),
                ),
            ];

            if (columns == 1) {
              return Column(
                children: [
                  for (var index = 0; index < cards.length; index++) ...[
                    if (index > 0) const SizedBox(height: 10),
                    cards[index],
                  ],
                ],
              );
            }

            return _TwoColumnGrid(children: cards);
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
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ColoredBox(
            color: AppColors.accentFrom,
            child: SizedBox(height: 3),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.navySoft,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.inventory_2_outlined, color: AppColors.navy, size: 26),
                  ),
                ),
                const SizedBox(height: 14),
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
                        height: 1.45,
                      ),
                ),
                const SizedBox(height: 18),
                AppButton(
                  label: i18n.t('home.newShipment'),
                  icon: Icons.add_rounded,
                  expanded: true,
                  onPressed: () => context.push('/shipments/new'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentLoading extends StatelessWidget {
  const _RecentLoading({required this.columns});

  final int columns;

  @override
  Widget build(BuildContext context) {
    final placeholders = List<Widget>.generate(columns == 1 ? 3 : 4, (_) => const _RecentSkeleton());
    if (columns == 1) {
      return Column(
        children: [
          for (var index = 0; index < placeholders.length; index++) ...[
            if (index > 0) const SizedBox(height: 10),
            placeholders[index],
          ],
        ],
      );
    }
    return _TwoColumnGrid(children: placeholders);
  }
}

class _RecentSkeleton extends StatelessWidget {
  const _RecentSkeleton();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.mist,
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _SkeletonBar(width: 140, height: 12),
                      SizedBox(height: 8),
                      _SkeletonBar(width: 88, height: 10),
                    ],
                  ),
                ),
                const _SkeletonBar(width: 64, height: 22, radius: 20),
              ],
            ),
            const SizedBox(height: 14),
            const _SkeletonBar(width: double.infinity, height: 12),
            const SizedBox(height: 12),
            const Wrap(
              spacing: 8,
              children: [
                _SkeletonBar(width: 84, height: 26, radius: 20),
                _SkeletonBar(width: 96, height: 26, radius: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonBar extends StatelessWidget {
  const _SkeletonBar({
    required this.width,
    required this.height,
    this.radius = 8,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.mist,
        borderRadius: BorderRadius.circular(radius),
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
