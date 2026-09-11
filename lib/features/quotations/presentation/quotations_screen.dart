import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/i18n/i18n_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/pagination_meta.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/async_body.dart';
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

class _QuotationsScreenState extends ConsumerState<QuotationsScreen> {
  bool _accepting = false;

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
          if (context.isDesktop) {
            return ContentWidth(
              child: ListView(
                children: [
                  Text(
                    i18n.t('quotation.selectBest'),
                    style: const TextStyle(color: AppColors.muted),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final quotation in items)
                          SizedBox(
                            width: 320,
                            child: Padding(
                              padding: const EdgeInsetsDirectional.only(end: 12),
                              child: _QuotationCard(
                                quotation: quotation,
                                i18n: i18n,
                                accepting: _accepting,
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
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final quotation = items[index];
              return _QuotationCard(
                quotation: quotation,
                i18n: i18n,
                accepting: _accepting,
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

class _QuotationCard extends StatelessWidget {
  const _QuotationCard({
    required this.quotation,
    required this.i18n,
    required this.accepting,
    required this.onAccept,
    required this.onOpen,
  });

  final Quotation quotation;
  final I18nBundle i18n;
  final bool accepting;
  final VoidCallback onAccept;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final locale = i18n.locale.languageCode;
    return Card(
      child: Padding(
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
          return ContentWidth(
            child: _QuotationCard(
              quotation: quotation,
              i18n: i18n,
              accepting: false,
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
          );
        },
      ),
    );
  }
}
