import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/i18n_controller.dart';
import '../../../core/theme/app_colors.dart';
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
          padding: EdgeInsets.fromLTRB(
            context.isDesktop ? 24 : 20,
            8,
            context.isDesktop ? 24 : 20,
            28,
          ),
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
                _OperationsBoard(i18n: i18n, summary: summary),
                const SizedBox(height: 28),
                _ActivityChart(i18n: i18n, summary: summary),
                const SizedBox(height: 28),
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

class _OperationsBoard extends StatelessWidget {
  const _OperationsBoard({required this.i18n, required this.summary});

  final I18nBundle i18n;
  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final split = constraints.maxWidth >= 680;
          final intro = _BoardIntro(i18n: i18n, wide: split);
          final figures = _BoardFigures(i18n: i18n, summary: summary);

          if (!split) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [intro, const SizedBox(height: 20), figures],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 22, 20, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: intro),
                const SizedBox(width: 28),
                Expanded(
                  flex: 6,
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      border: BorderDirectional(
                        start: BorderSide(color: AppColors.border),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(start: 24),
                      child: figures,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BoardIntro extends StatelessWidget {
  const _BoardIntro({required this.i18n, required this.wide});

  final I18nBundle i18n;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FreightLane(),
        const SizedBox(height: 18),
        Text(
          i18n.t('home.heroTitle'),
          style: text.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          i18n.t('home.heroBody'),
          style: text.bodyMedium?.copyWith(color: AppColors.muted, height: 1.5),
        ),
        const SizedBox(height: 20),
        AppButton(
          label: i18n.t('home.newShipment'),
          icon: Icons.add,
          expanded: !wide,
          onPressed: () => context.push('/shipments/new'),
        ),
      ],
    );
  }
}

class _FreightLane extends StatefulWidget {
  const _FreightLane();

  @override
  State<_FreightLane> createState() => _FreightLaneState();
}

class _FreightLaneState extends State<_FreightLane>
    with SingleTickerProviderStateMixin {
  static const _iconSize = 52.0;
  static const _edge = 18.0;

  late final AnimationController _motion;

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = MediaQuery.disableAnimationsOf(context);
    if (reduced) {
      if (_motion.isAnimating) _motion.stop();
      _motion.value = 0.46;
      return;
    }
    if (!_motion.isAnimating) _motion.repeat();
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  double _travel(double t) {
    const depart = 0.1;
    const arrive = 0.78;
    if (t <= depart) return 0;
    if (t >= arrive) return 1;
    return Curves.easeInOutCubic.transform((t - depart) / (arrive - depart));
  }

  double _opacity(double t) {
    if (t < 0.08) return t / 0.08;
    if (t > 0.9) return ((1 - t) / 0.1).clamp(0, 1);
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.disableAnimationsOf(context);
    final mirror = Directionality.of(context) == TextDirection.rtl;

    return RepaintBoundary(
      child: ExcludeSemantics(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final span = (constraints.maxWidth - _edge * 2 - _iconSize)
                    .clamp(0.0, constraints.maxWidth);
                return AnimatedBuilder(
                  animation: _motion,
                  builder: (context, child) {
                    final raw = reduced ? 0.46 : _motion.value;
                    final along = reduced ? 0.42 : _travel(raw);
                    final opacity = reduced ? 1.0 : _opacity(raw);
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        const Row(
                          children: [
                            _LaneNode(filled: true),
                            SizedBox(width: 8),
                            Expanded(child: _LaneDash(emphasis: true)),
                            SizedBox(width: 8),
                            _LaneNode(filled: false),
                          ],
                        ),
                        PositionedDirectional(
                          start: _edge + span * along,
                          top: 0,
                          bottom: 0,
                          child: Opacity(opacity: opacity, child: child),
                        ),
                      ],
                    );
                  },
                  child: Transform.flip(
                    flipX: mirror,
                    child: const _ColoredTruck(),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ColoredTruck extends StatelessWidget {
  const _ColoredTruck();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      key: Key('home-freight-truck'),
      width: 52,
      height: 34,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 6,
            child: _TruckBox(
              width: 32,
              height: 16,
              color: AppColors.navy,
              radius: 3,
            ),
          ),
          Positioned(
            left: 0,
            top: 12,
            child: ColoredBox(
              color: AppColors.accentFrom,
              child: SizedBox(width: 32, height: 4),
            ),
          ),
          Positioned(
            left: 28,
            top: 9,
            child: _TruckBox(
              width: 18,
              height: 13,
              color: Color(0xFF3B7AF5),
              radius: 4,
            ),
          ),
          Positioned(
            left: 36,
            top: 12,
            child: _TruckBox(
              width: 7,
              height: 5,
              color: AppColors.white,
              radius: 1,
            ),
          ),
          Positioned(left: 6, top: 18, child: _TruckWheel()),
          Positioned(left: 34, top: 18, child: _TruckWheel()),
        ],
      ),
    );
  }
}

class _TruckBox extends StatelessWidget {
  const _TruckBox({
    required this.width,
    required this.height,
    required this.color,
    required this.radius,
  });

  final double width;
  final double height;
  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: SizedBox(width: width, height: height),
    );
  }
}

class _TruckWheel extends StatelessWidget {
  const _TruckWheel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(
        color: AppColors.ink,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Container(
        width: 4,
        height: 4,
        decoration: const BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _LaneNode extends StatelessWidget {
  const _LaneNode({required this.filled});

  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: filled ? AppColors.navy : AppColors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.navy, width: 1.6),
      ),
    );
  }
}

class _LaneDash extends StatelessWidget {
  const _LaneDash({this.emphasis = false});

  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashPainter(
        color: emphasis ? AppColors.navy : AppColors.navyMuted,
      ),
      child: const SizedBox(height: 2),
    );
  }
}

class _DashPainter extends CustomPainter {
  const _DashPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    const dash = 5.0;
    const gap = 4.0;
    final y = size.height / 2;
    var x = 0.0;
    while (x < size.width) {
      final end = (x + dash).clamp(0.0, size.width);
      canvas.drawLine(Offset(x, y), Offset(end, y), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _BoardFigures extends StatelessWidget {
  const _BoardFigures({required this.i18n, required this.summary});

  final I18nBundle i18n;
  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final quotations = _MetricData(
      label: i18n.t('home.quotationsPending'),
      value: '${summary.quotationsPending}',
      emphasize: summary.quotationsPending > 0,
      onTap: () => context.go('/shipments'),
    );
    final paid = _MetricData(
      label: i18n.t('home.paymentsCompleted'),
      value: formatAmount(summary.paymentsCompletedAmount),
      centered: true,
      onTap: () => context.go(context.isDesktop ? '/payments' : '/billing'),
    );
    final invoices = _MetricData(
      label: i18n.t('home.invoices'),
      value: '${summary.invoicesCount}',
      onTap: () => context.go(context.isDesktop ? '/invoices' : '/billing'),
    );

    return Column(
      children: [
        _MetricRow(cells: [quotations, invoices]),
        const Divider(height: 1),
        _MetricCell(data: paid),
      ],
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.cells});

  final List<_MetricData> cells;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < cells.length; index++) ...[
            if (index > 0)
              const ColoredBox(
                color: AppColors.border,
                child: SizedBox(width: 1),
              ),
            Expanded(child: _MetricCell(data: cells[index])),
          ],
        ],
      ),
    );
  }
}

class _MetricData {
  const _MetricData({
    required this.label,
    required this.value,
    required this.onTap,
    this.emphasize = false,
    this.centered = false,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final bool emphasize;
  final bool centered;
}

class _MetricCell extends StatelessWidget {
  const _MetricCell({required this.data});

  final _MetricData data;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final valueStyle = (text.titleMedium ?? const TextStyle()).copyWith(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      height: 1.15,
      letterSpacing: -0.3,
      color: AppColors.ink,
    );
    final labelStyle = text.bodySmall?.copyWith(
      color: AppColors.muted,
      height: 1.2,
    );
    final textAlign = data.centered ? TextAlign.center : TextAlign.start;

    return Semantics(
      button: true,
      label: '${data.value}, ${data.label}',
      child: InkWell(
        onTap: data.onTap,
        child: ExcludeSemantics(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Column(
              crossAxisAlignment: data.centered
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                Text(data.value, textAlign: textAlign, style: valueStyle),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: data.centered
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (data.emphasize) ...[
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.navy,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Flexible(
                      child: Text(
                        data.label,
                        textAlign: textAlign,
                        style: labelStyle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivityChart extends StatefulWidget {
  const _ActivityChart({required this.i18n, required this.summary});

  final I18nBundle i18n;
  final DashboardSummary summary;

  @override
  State<_ActivityChart> createState() => _ActivityChartState();
}

class _ActivityChartState extends State<_ActivityChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bars;

  @override
  void initState() {
    super.initState();
    _bars = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _bars.value = 1;
      return;
    }
    if (_bars.value == 0 && !_bars.isAnimating) _bars.forward();
  }

  @override
  void dispose() {
    _bars.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final summary = widget.summary;
    final i18n = widget.i18n;
    final rows = [
      _ChartRowData(
        label: i18n.t('home.shipmentsOpen'),
        current: summary.shipmentsOpen,
        total: _atLeast(summary.shipmentsTotal, summary.shipmentsOpen),
        onTap: () => context.go('/shipments'),
      ),
      _ChartRowData(
        label: i18n.t('home.jobsActive'),
        current: summary.jobsActive,
        total: summary.jobsActive + summary.jobsCompleted,
        onTap: () => context.go('/jobs'),
      ),
      _ChartRowData(
        label: i18n.t('home.tripsInTransit'),
        current: summary.tripsInTransit,
        total: _atLeast(summary.tripsActive, summary.tripsInTransit),
        onTap: () => context.go('/jobs'),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label: i18n.t('home.snapshot')),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: AnimatedBuilder(
              animation: _bars,
              builder: (context, _) {
                return Column(
                  children: [
                    for (var index = 0; index < rows.length; index++)
                      _ChartRow(
                        data: rows[index],
                        caption: i18n.t('home.ofTotal', {
                          'current': '${rows[index].current}',
                          'total': '${rows[index].total}',
                        }),
                        progress: _rowProgress(index),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  double _rowProgress(int index) {
    const start = [0.0, 0.12, 0.24];
    const end = [0.72, 0.84, 1.0];
    final span = end[index] - start[index];
    final local = ((_bars.value - start[index]) / span).clamp(0.0, 1.0);
    return Curves.easeOutCubic.transform(local);
  }
}

int _atLeast(int total, int current) => total > current ? total : current;

class _ChartRowData {
  const _ChartRowData({
    required this.label,
    required this.current,
    required this.total,
    required this.onTap,
  });

  final String label;
  final int current;
  final int total;
  final VoidCallback onTap;
}

class _ChartRow extends StatelessWidget {
  const _ChartRow({
    required this.data,
    required this.caption,
    required this.progress,
  });

  final _ChartRowData data;
  final String caption;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final ratio = data.total == 0 ? 0.0 : data.current / data.total;
    final fill = (ratio * progress).clamp(0.0, 1.0);

    return Semantics(
      button: true,
      label: '${data.label}, $caption',
      child: InkWell(
        onTap: data.onTap,
        child: ExcludeSemantics(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        data.label,
                        style: text.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      caption,
                      style: text.bodySmall?.copyWith(
                        color: AppColors.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: SizedBox(
                    height: 8,
                    width: double.infinity,
                    child: ColoredBox(
                      color: AppColors.mist,
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: FractionallySizedBox(
                          widthFactor: fill,
                          heightFactor: 1,
                          child: const ColoredBox(color: AppColors.navy),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
            Expanded(
              child: _SectionLabel(label: i18n.t('home.recentShipments')),
            ),
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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
        child: Column(
          children: [
            const Center(child: _FreightLane()),
            const SizedBox(height: 16),
            Text(
              i18n.t('home.noShipments'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              i18n.t('home.emptyHint'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: AppColors.muted, height: 1.45),
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
    );
  }
}

class _RecentLoading extends StatelessWidget {
  const _RecentLoading({required this.columns});

  final int columns;

  @override
  Widget build(BuildContext context) {
    final placeholders = List<Widget>.generate(
      columns == 1 ? 3 : 4,
      (_) => const _RecentSkeleton(),
    );
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
    return const Card(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _SkeletonBar(width: 40, height: 40, radius: 13),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SkeletonBar(width: 140, height: 12),
                      SizedBox(height: 8),
                      _SkeletonBar(width: 88, height: 10),
                    ],
                  ),
                ),
                _SkeletonBar(width: 64, height: 22, radius: 20),
              ],
            ),
            SizedBox(height: 14),
            _SkeletonBar(width: double.infinity, height: 12),
            SizedBox(height: 12),
            Wrap(
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
      style: Theme.of(context).textTheme.titleSmall
          ?.copyWith(fontWeight: FontWeight.w700, color: AppColors.ink),
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
      rows.add(
        children.sublist(
          index,
          index + 2 > children.length ? children.length : index + 2,
        ),
      );
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
                  child: rows[rowIndex].length > 1
                      ? rows[rowIndex][1]
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
