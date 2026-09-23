import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/i18n/i18n_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/app_appear.dart';
import '../../../shared/widgets/app_route_line.dart';
import '../../../shared/widgets/async_body.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/entity_summary_card.dart';
import '../../../shared/widgets/page_scaffold.dart';
import '../../../shared/widgets/status_badge.dart';
import '../data/quantity_units.dart';
import '../data/shipment_model.dart';
import '../data/shipment_repository.dart';
import 'shipment_providers.dart';
import 'widgets/shipment_card.dart';
import 'widgets/shipment_detail_sections.dart';

class ShipmentDetailScreen extends ConsumerStatefulWidget {
  const ShipmentDetailScreen({super.key, required this.shipmentId});

  final int shipmentId;

  @override
  ConsumerState<ShipmentDetailScreen> createState() =>
      _ShipmentDetailScreenState();
}

class _ShipmentDetailScreenState extends ConsumerState<ShipmentDetailScreen> {
  bool _busy = false;

  Future<void> _act(Future<void> Function() action, String successKey) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
      ref.invalidate(shipmentDetailProvider(widget.shipmentId));
      ref.invalidate(shipmentsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(ref.i18n.t(successKey))));
    } catch (error) {
      if (!mounted) return;
      final i18n = ref.i18n;
      final message = error is ApiException && error.message == 'network'
          ? i18n.t('common.networkError')
          : error.toString();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _publish(ShipmentRequest shipment) async {
    final i18n = ref.i18n;
    final ok = await showConfirmDialog(
      context,
      i18n: i18n,
      title: i18n.t('shipment.publish'),
      message: i18n.t('shipment.publishConfirm'),
    );
    if (!ok || !mounted) return;
    await _act(
      () => ref.read(shipmentRepositoryProvider).publish(shipment.id),
      'shipment.published',
    );
  }

  Future<void> _cancel(ShipmentRequest shipment) async {
    final i18n = ref.i18n;
    final ok = await showConfirmDialog(
      context,
      i18n: i18n,
      title: i18n.t('shipment.cancelRequest'),
      message: i18n.t('shipment.cancelConfirm'),
      danger: true,
    );
    if (!ok || !mounted) return;
    await _act(
      () => ref.read(shipmentRepositoryProvider).cancel(shipment.id),
      'shipment.cancelled',
    );
  }

  @override
  Widget build(BuildContext context) {
    final i18n = ref.i18n;
    final value = ref.watch(shipmentDetailProvider(widget.shipmentId));

    return PageScaffold(
      title: i18n.t('shipment.detail'),
      showBack: true,
      body: AsyncBody<ShipmentRequest>(
        value: value,
        i18n: i18n,
        onRetry: () =>
            ref.invalidate(shipmentDetailProvider(widget.shipmentId)),
        onRefresh: () async {
          ref.invalidate(shipmentDetailProvider(widget.shipmentId));
          await ref.read(shipmentDetailProvider(widget.shipmentId).future);
        },
        builder: (shipment) {
          final locale = i18n.locale.languageCode;
          final status = shipment.status ?? '';
          final cargo = shipment.cargoType?.trim();
          final reference = shipment.reference?.trim();
          final title = (cargo != null && cargo.isNotEmpty)
              ? cargo
              : (reference != null && reference.isNotEmpty)
                  ? reference
                  : i18n.t('shipment.detail');
          final listedQuotes = shipment.canCompareQuotations
              ? shipment.quotations
              : shipment.awardedQuotations;
          final showCompare = shipment.canCompareQuotations;
          final quoteFact = shipmentQuoteFact(i18n, shipment);
          final decisionFirst =
              shipment.status == 'published' || shipment.status == 'awarded';
          final showQuotes = listedQuotes.isNotEmpty || showCompare;

          final quotations = ShipmentQuotationsSection(
            i18n: i18n,
            quotations: listedQuotes,
            showCompare: showCompare,
          );

          return ContentWidth(
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                AppAppear(
                  index: 0,
                  child: EntitySummaryCard(
                    title: title,
                    subtitle: cargo != null && cargo.isNotEmpty
                        ? reference
                        : null,
                    icon: shipmentStatusIcon(status),
                    tone: shipmentStatusTone(status),
                    accent: AppColors.statusForeground(status)
                        .withValues(alpha: 0.85),
                    badge: StatusBadge(
                      status: status,
                      label: i18n.status(status),
                    ),
                    facts: [
                      EntityFact(
                        i18n.t('shipment.requiredDate'),
                        formatDate(shipment.requiredDate, locale: locale),
                        icon: Icons.event_outlined,
                      ),
                      EntityFact(
                        i18n.t('shipment.cargo'),
                        QuantityUnits.cargoSummary(
                          i18n,
                          weightTons: shipment.weightTons,
                          quantity: shipment.quantity,
                          unit: shipment.quantityUnit,
                        ),
                        icon: Icons.inventory_2_outlined,
                      ),
                      EntityFact(
                        quoteFact.label,
                        quoteFact.value,
                        icon: Icons.request_quote_outlined,
                      ),
                    ],
                    footer: AppRoutePanel(
                      fromLabel: i18n.t('common.pickup'),
                      toLabel: i18n.t('common.delivery'),
                      from: shipment.pickupCity ?? shipment.pickupAddress ?? '—',
                      to: shipment.deliveryCity ??
                          shipment.deliveryAddress ??
                          '—',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AppAppear(
                  index: 1,
                  child: ShipmentNextStep(
                    i18n: i18n,
                    shipment: shipment,
                    busy: _busy,
                    onPublish: () => _publish(shipment),
                    onCancel: () => _cancel(shipment),
                    onCompare: () =>
                        context.push('/shipments/${shipment.id}/quotations'),
                  ),
                ),
                if (decisionFirst && showQuotes) ...[
                  const SizedBox(height: 16),
                  AppAppear(index: 2, child: quotations),
                ],
                const SizedBox(height: 16),
                AppAppear(
                  index: 3,
                  child: ShipmentRecordLayout(i18n: i18n, shipment: shipment),
                ),
                if (!decisionFirst && showQuotes) ...[
                  const SizedBox(height: 16),
                  AppAppear(index: 4, child: quotations),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
