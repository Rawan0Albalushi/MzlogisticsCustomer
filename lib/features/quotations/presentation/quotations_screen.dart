import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/i18n/i18n_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/pagination_meta.dart';
import '../../../shared/widgets/app_appear.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_filters.dart';
import '../../../shared/widgets/async_body.dart';
import '../../../shared/widgets/entity_summary_card.dart';
import '../../../shared/widgets/page_scaffold.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../jobs/presentation/job_providers.dart';
import '../../payments/presentation/payment_providers.dart';
import '../data/quotation_accept_result.dart';
import '../data/quotation_model.dart';
import '../data/quotation_repository.dart';
import 'accept_quotation_dialog.dart';
import 'quotation_providers.dart';

class QuotationsScreen extends ConsumerStatefulWidget {
  const QuotationsScreen({super.key, required this.shipmentId});

  final int shipmentId;

  @override
  ConsumerState<QuotationsScreen> createState() => _QuotationsScreenState();
}

enum _QuotationFilter { all, submitted, accepted, closed }

class _QuotationsScreenState extends ConsumerState<QuotationsScreen> {
  final _search = TextEditingController();
  _QuotationFilter _filter = _QuotationFilter.all;
  bool _accepting = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _accept(Quotation quotation) async {
    final i18n = ref.i18n;
    if (!quotation.canAccept) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(i18n.t('quotation.cannotAccept'))),
      );
      return;
    }
    final method = await showAcceptQuotationDialog(context: context, ref: ref);
    if (method == null || _accepting) return;
    setState(() => _accepting = true);
    try {
      final result = await ref.read(quotationRepositoryProvider).accept(
            quotation.id,
            paymentMethod: method,
          );
      ref.invalidate(quotationsByShipmentProvider(widget.shipmentId));
      ref.invalidate(jobsProvider);
      ref.invalidate(paymentsProvider);
      if (!mounted) return;
      _openAcceptance(result);
    } catch (error) {
      if (!mounted) return;
      final message = error is ApiException && error.message == 'network'
          ? i18n.t('common.networkError')
          : error.toString();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _accepting = false);
    }
  }

  List<Quotation> _visible(List<Quotation> items) {
    final query = _search.text.trim().toLowerCase();
    return items.where((quotation) {
      if (!_matchesQuotation(quotation.status, _filter)) return false;
      return matchesSearch(query, [
        quotation.reference,
        quotation.provider?.name,
        quotation.provider?.nameAr,
        quotation.truckType,
        quotation.truckTypeLabel,
      ]);
    }).toList();
  }

  List<AppFilterOption<_QuotationFilter>> _quotationOptions(
    I18nBundle i18n,
    List<Quotation> items,
  ) {
    int count(_QuotationFilter filter) {
      return items.where((item) => _matchesQuotation(item.status, filter)).length;
    }

    return [
      AppFilterOption(
        value: _QuotationFilter.all,
        label: i18n.t('common.filterAll'),
        icon: Icons.apps_rounded,
        count: count(_QuotationFilter.all),
      ),
      AppFilterOption(
        value: _QuotationFilter.submitted,
        label: i18n.status('submitted'),
        icon: Icons.request_quote_outlined,
        count: count(_QuotationFilter.submitted),
      ),
      AppFilterOption(
        value: _QuotationFilter.accepted,
        label: i18n.status('accepted'),
        icon: Icons.check_circle_outline,
        count: count(_QuotationFilter.accepted),
      ),
      AppFilterOption(
        value: _QuotationFilter.closed,
        label: i18n.t('common.filterClosed'),
        icon: Icons.block_rounded,
        count: count(_QuotationFilter.closed),
      ),
    ];
  }

  bool _isBestPrice(List<Quotation> items, Quotation quotation) {
    final prices = items.map((item) => item.totalPrice).whereType<double>().toList();
    if (prices.isEmpty || quotation.totalPrice == null) return false;
    final lowest = prices.reduce((a, b) => a < b ? a : b);
    return quotation.totalPrice == lowest;
  }

  void _openAcceptance(QuotationAcceptResult result) {
    final i18n = ref.i18n;
    if (result.requiresCheckout && result.payment != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(i18n.t('payment.redirecting'))),
      );
      context.go(
        '/payments/checkout/${result.payment!.id}',
        extra: result.paymentLink,
      );
      return;
    }
    if (result.job != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(i18n.t('quotation.accepted'))),
      );
      context.go('/jobs/${result.job!.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final i18n = ref.i18n;
    final value = ref.watch(quotationsByShipmentProvider(widget.shipmentId));

    return PageScaffold(
      title: i18n.t('quotation.compare'),
      body: AsyncBody<PagedResult<Quotation>>(
        value: value,
        i18n: i18n,
        onRetry: () => ref.invalidate(quotationsByShipmentProvider(widget.shipmentId)),
        isEmpty: (data) => data.items.isEmpty,
        emptyTitle: i18n.t('quotation.empty'),
        emptyIcon: Icons.request_quote_outlined,
        builder: (page) {
          final items = page.items;
          final visible = _visible(items);
          final toolbar = AppListToolbar<_QuotationFilter>(
            i18n: i18n,
            search: _search,
            searchHint: i18n.t('quotation.searchHint'),
            onSearchChanged: () => setState(() {}),
            options: _quotationOptions(i18n, items),
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
                  AppFilterEmpty(
                    i18n: i18n,
                    onClear: () => setState(() {
                      _filter = _QuotationFilter.all;
                      _search.clear();
                    }),
                  ),
                ],
              ),
            );
          }

          if (context.isDesktop) {
            return ContentWidth(
              child: ListView(
                children: [
                  toolbar,
                  const SizedBox(height: 16),
                  Text(
                    i18n.t('quotation.selectBest'),
                    style: const TextStyle(color: AppColors.muted, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final quotation in visible)
                          SizedBox(
                            width: 320,
                            child: Padding(
                              padding: const EdgeInsetsDirectional.only(end: 12),
                              child: _QuotationCard(
                                quotation: quotation,
                                i18n: i18n,
                                accepting: _accepting,
                                bestPrice: _isBestPrice(items, quotation),
                                onAccept: () => _accept(quotation),
                                onOpen: () => context.push('/quotations/${quotation.id}'),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: visible.length + 1,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == 0) return toolbar;
              final quotation = visible[index - 1];
              return _QuotationCard(
                quotation: quotation,
                i18n: i18n,
                accepting: _accepting,
                bestPrice: _isBestPrice(items, quotation),
                onAccept: () => _accept(quotation),
                onOpen: () => context.push('/quotations/${quotation.id}'),
              );
            },
          );
        },
      ),
    );
  }
}

bool _matchesQuotation(String? status, _QuotationFilter filter) {
  return switch (filter) {
    _QuotationFilter.all => true,
    _QuotationFilter.submitted => status == 'submitted',
    _QuotationFilter.accepted => status == 'accepted',
    _QuotationFilter.closed => status == 'rejected' || status == 'withdrawn',
  };
}

class _QuotationCard extends StatelessWidget {
  const _QuotationCard({
    required this.quotation,
    required this.i18n,
    required this.accepting,
    required this.onAccept,
    required this.onOpen,
    this.bestPrice = false,
  });

  final Quotation quotation;
  final I18nBundle i18n;
  final bool accepting;
  final VoidCallback onAccept;
  final VoidCallback onOpen;
  final bool bestPrice;

  @override
  Widget build(BuildContext context) {
    final locale = i18n.locale.languageCode;
    return Card(
      clipBehavior: Clip.antiAlias,
      color: bestPrice ? AppColors.amberSoft : AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ColoredBox(
            color: bestPrice ? AppColors.accentFrom : AppColors.navy,
            child: const SizedBox(height: 3),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        quotation.provider?.displayName(locale) ?? quotation.reference ?? '—',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    StatusBadge(status: quotation.status ?? '', label: i18n.status(quotation.status)),
                  ],
                ),
                if (bestPrice) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      i18n.t('quotation.bestPrice'),
                      style: const TextStyle(
                        color: AppColors.onNeon,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  formatAmount(quotation.totalPrice, currency: quotation.currency ?? 'OMR'),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                      ),
                ),
                const SizedBox(height: 12),
                _line(i18n.t('quotation.trucks'), '${quotation.truckCount ?? '—'}'),
                _line(i18n.t('quotation.truckType'), quotation.truckTypeLabel ?? quotation.truckType ?? '—'),
                _line(i18n.t('quotation.capacity'), formatNumber(quotation.truckCapacityTons)),
                _line(i18n.t('quotation.trips'), '${quotation.tripCount ?? '—'}'),
                _line(i18n.t('quotation.qtyPerTrip'), formatNumber(quotation.quantityPerTrip)),
                _line(i18n.t('quotation.duration'), '${quotation.durationDays ?? '—'}'),
                _line(i18n.t('quotation.extra'), formatAmount(quotation.additionalCosts, currency: quotation.currency ?? 'OMR')),
                _line(i18n.t('quotation.validUntil'), formatDate(quotation.validUntil, locale: locale)),
                if (quotation.conditions != null) ...[
                  const SizedBox(height: 8),
                  Text(quotation.conditions!, style: const TextStyle(color: AppColors.muted)),
                ],
                const SizedBox(height: 16),
                AppButton(
                  label: i18n.t('quotation.accept'),
                  expanded: true,
                  loading: accepting,
                  onPressed: quotation.canAccept && !accepting ? onAccept : null,
                ),
                const SizedBox(height: 4),
                AppButton(
                  label: i18n.t('common.details'),
                  variant: AppButtonVariant.ghost,
                  expanded: true,
                  onPressed: onOpen,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: AppColors.muted))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class QuotationDetailScreen extends ConsumerWidget {
  const QuotationDetailScreen({super.key, required this.quotationId});

  final int quotationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n = ref.i18n;
    final value = ref.watch(quotationDetailProvider(quotationId));
    return PageScaffold(
      title: i18n.t('quotation.detail'),
      body: AsyncBody<Quotation>(
        value: value,
        i18n: i18n,
        onRetry: () => ref.invalidate(quotationDetailProvider(quotationId)),
        builder: (quotation) {
          final locale = i18n.locale.languageCode;
          final status = quotation.status ?? '';
          return ContentWidth(
            child: ListView(
              children: [
                AppAppear(
                  index: 0,
                  child: EntitySummaryCard(
                    title: quotation.provider?.displayName(locale) ?? quotation.reference ?? i18n.t('quotation.detail'),
                    subtitle: quotation.reference,
                    icon: Icons.request_quote_rounded,
                    accent: AppColors.statusForeground(status).withValues(alpha: 0.85),
                    badge: StatusBadge(status: status, label: i18n.status(status)),
                    facts: [
                      EntityFact(
                        i18n.t('quotation.price'),
                        formatAmount(quotation.totalPrice, currency: quotation.currency ?? 'OMR'),
                        icon: Icons.payments_outlined,
                      ),
                      EntityFact(
                        i18n.t('quotation.trucks'),
                        '${quotation.truckCount ?? '—'}',
                        icon: Icons.local_shipping_outlined,
                      ),
                      EntityFact(
                        i18n.t('quotation.duration'),
                        '${quotation.durationDays ?? '—'}',
                        icon: Icons.schedule_outlined,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AppAppear(
                  index: 1,
                  child: _QuotationCard(
              quotation: quotation,
              i18n: i18n,
              accepting: false,
              bestPrice: false,
              onAccept: () async {
                final method = await showAcceptQuotationDialog(context: context, ref: ref);
                if (method == null || !context.mounted) return;
                try {
                  final result = await ref.read(quotationRepositoryProvider).accept(
                        quotation.id,
                        paymentMethod: method,
                      );
                  if (!context.mounted) return;
                  if (result.requiresCheckout && result.payment != null) {
                    context.go(
                      '/payments/checkout/${result.payment!.id}',
                      extra: result.paymentLink,
                    );
                    return;
                  }
                  if (result.job != null) {
                    context.go('/jobs/${result.job!.id}');
                  }
                } catch (error) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error.toString())),
                  );
                }
              },
              onOpen: () {},
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
