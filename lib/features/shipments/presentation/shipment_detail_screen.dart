import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/i18n/i18n_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/app_appear.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_list_card.dart';
import '../../../shared/widgets/app_progress.dart';
import '../../../shared/widgets/app_route_line.dart';
import '../../../shared/widgets/async_body.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/entity_summary_card.dart';
import '../../../shared/widgets/info_row.dart';
import '../../../shared/widgets/location_preview.dart';
import '../../../shared/widgets/page_scaffold.dart';
import '../../../shared/widgets/status_badge.dart';
import '../data/quantity_units.dart';
import '../data/shipment_model.dart';
import '../data/shipment_repository.dart';
import 'shipment_providers.dart';
import 'widgets/shipment_card.dart';

class ShipmentDetailScreen extends ConsumerStatefulWidget {
  const ShipmentDetailScreen({super.key, required this.shipmentId});

  final int shipmentId;

  @override
  ConsumerState<ShipmentDetailScreen> createState() => _ShipmentDetailScreenState();
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ref.i18n.t(successKey))),
      );
    } catch (error) {
      if (!mounted) return;
      final i18n = ref.i18n;
      final message = error is ApiException && error.message == 'network'
          ? i18n.t('common.networkError')
          : error.toString();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final i18n = ref.i18n;
    final value = ref.watch(shipmentDetailProvider(widget.shipmentId));

    return PageScaffold(
      title: i18n.t('shipment.detail'),
      showBack: true,
      onBack: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/home');
        }
      },
      body: AsyncBody<ShipmentRequest>(
        value: value,
        i18n: i18n,
        onRetry: () => ref.invalidate(shipmentDetailProvider(widget.shipmentId)),
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
          final quotes = shipment.quotationsCount ?? shipment.quotations.length;

          return ContentWidth(
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                AppAppear(
                  index: 0,
                  child: EntitySummaryCard(
                    title: title,
                    subtitle: cargo != null && cargo.isNotEmpty ? reference : null,
                    icon: shipmentStatusIcon(status),
                    tone: shipmentStatusTone(status),
                    accent: AppColors.statusForeground(status).withValues(alpha: 0.85),
                    badge: StatusBadge(status: status, label: i18n.status(status)),
                    facts: [
                      EntityFact(
                        i18n.t('shipment.requiredDate'),
                        formatDate(shipment.requiredDate, locale: locale),
                        icon: Icons.event_outlined,
                      ),
                      EntityFact(
                        i18n.t('shipment.weight'),
                        '${formatNumber(shipment.weightTons)} ${i18n.t('common.tons')}',
                        icon: Icons.inventory_2_outlined,
                      ),
                      EntityFact(
                        i18n.t('shipment.quotationsCount', {'count': '$quotes'}),
                        quotes > 0 ? i18n.t('shipment.viewQuotations') : i18n.t('shipment.waitingQuotes'),
                        icon: Icons.request_quote_outlined,
                      ),
                    ],
                    footer: AppRoutePanel(
                      fromLabel: i18n.t('common.pickup'),
                      toLabel: i18n.t('common.delivery'),
                      from: shipment.pickupCity ?? shipment.pickupAddress ?? '—',
                      to: shipment.deliveryCity ?? shipment.deliveryAddress ?? '—',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AppAppear(
                  index: 1,
                  child: SectionCard(
                    title: i18n.t('progress.stage'),
                    icon: Icons.timeline_rounded,
                    child: AppStatusStepper(
                      steps: [
                        AppStepItem(
                          id: 'draft',
                          label: i18n.status('draft'),
                          icon: Icons.edit_note_rounded,
                        ),
                        AppStepItem(
                          id: 'published',
                          label: i18n.status('published'),
                          icon: Icons.campaign_rounded,
                        ),
                        AppStepItem(
                          id: 'awarded',
                          label: i18n.status('awarded'),
                          icon: Icons.workspace_premium_rounded,
                        ),
                      ],
                      currentId: _shipmentStep(shipment.status),
                      failed: shipment.status == 'cancelled' || shipment.status == 'expired',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AppAppear(
                  index: 2,
                  child: SectionCard(
                    title: i18n.t('shipment.cargo'),
                    icon: Icons.category_rounded,
                    child: Wrap(
                      spacing: 24,
                      runSpacing: 16,
                      children: [
                        InfoRow(
                          label: i18n.t('shipment.cargoType'),
                          value: shipment.cargoType ?? '—',
                          icon: Icons.category_outlined,
                        ),
                        InfoRow(
                          label: i18n.t('shipment.weight'),
                          value: '${formatNumber(shipment.weightTons)} ${i18n.t('common.tons')}',
                          icon: Icons.scale_outlined,
                        ),
                        if (!QuantityUnits.isTons(shipment.quantityUnit))
                          InfoRow(
                            label: QuantityUnits.countFieldLabel(i18n, shipment.quantityUnit ?? ''),
                            value: QuantityUnits.formatQuantity(
                              i18n,
                              shipment.quantity,
                              shipment.quantityUnit,
                            ),
                            icon: Icons.numbers_rounded,
                          ),
                        InfoRow(
                          label: i18n.t('shipment.volume'),
                          value: shipment.volumeCbm == null
                              ? i18n.t('common.notAvailable')
                              : '${formatNumber(shipment.volumeCbm)} ${i18n.t('common.cbm')}',
                          icon: Icons.view_in_ar_outlined,
                        ),
                        if (shipment.cargoDescription != null)
                          SizedBox(
                            width: double.infinity,
                            child: InfoRow(
                              label: i18n.t('shipment.cargoDescription'),
                              value: shipment.cargoDescription!,
                              icon: Icons.notes_rounded,
                              wide: true,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                AppAppear(
                  index: 3,
                  child: SectionCard(
                    title: i18n.t('shipment.route'),
                    icon: Icons.route_rounded,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LocationPreview(
                          i18n: i18n,
                          title: i18n.t('common.pickup'),
                          address: shipment.pickupAddress,
                          city: shipment.pickupCity,
                          lat: shipment.pickupLat,
                          lng: shipment.pickupLng,
                        ),
                        const SizedBox(height: 12),
                        LocationPreview(
                          i18n: i18n,
                          title: i18n.t('common.delivery'),
                          address: shipment.deliveryAddress,
                          city: shipment.deliveryCity,
                          lat: shipment.deliveryLat,
                          lng: shipment.deliveryLng,
                        ),
                        const SizedBox(height: 12),
                        InfoRow(
                          label: i18n.t('shipment.requiredDate'),
                          value: formatDate(shipment.requiredDate, locale: locale),
                          icon: Icons.event_outlined,
                        ),
                        if (shipment.notes != null)
                          InfoRow(
                            label: i18n.t('common.notes'),
                            value: shipment.notes!,
                            icon: Icons.sticky_note_2_outlined,
                            wide: true,
                          ),
                      ],
                    ),
                  ),
                ),
                if (shipment.quotations.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  AppAppear(
                    index: 4,
                    child: SectionCard(
                      title: i18n.t('shipment.quotationsCount', {
                        'count': '${shipment.quotations.length}',
                      }),
                      icon: Icons.request_quote_rounded,
                      trailing: AppButton(
                        label: i18n.t('shipment.viewQuotations'),
                        variant: AppButtonVariant.ghost,
                        icon: Icons.compare_arrows_rounded,
                        onPressed: () => context.push('/shipments/${shipment.id}/quotations'),
                      ),
                      child: Column(
                        children: [
                          for (var index = 0; index < shipment.quotations.length; index++) ...[
                            if (index > 0) const Divider(height: 16),
                            AppListCard(
                              embedded: true,
                              onTap: () => context.push('/quotations/${shipment.quotations[index].id}'),
                              leading: AppIconWell(
                                icon: Icons.handshake_outlined,
                                color: AppColors.navy,
                                background: AppColors.navySoft,
                              ),
                              title: shipment.quotations[index].provider?.displayName(locale) ??
                                  shipment.quotations[index].reference ??
                                  i18n.t('quotation.detail'),
                              meta: formatAmount(
                                shipment.quotations[index].totalPrice,
                                currency: shipment.quotations[index].currency ?? 'OMR',
                              ),
                              trailing: StatusBadge(
                                status: shipment.quotations[index].status ?? '',
                                label: i18n.status(shipment.quotations[index].status),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                AppAppear(
                  index: 5,
                  child: SectionCard(
                    title: i18n.t('common.actions'),
                    icon: Icons.touch_app_rounded,
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        AppButton(
                          label: i18n.t('shipment.viewQuotations'),
                          icon: Icons.request_quote_rounded,
                          onPressed: () => context.push('/shipments/${shipment.id}/quotations'),
                        ),
                        if (shipment.canPublish)
                          AppButton(
                            label: i18n.t('shipment.publish'),
                            icon: Icons.campaign_rounded,
                            loading: _busy,
                            onPressed: () async {
                              final ok = await showConfirmDialog(
                                context,
                                i18n: i18n,
                                title: i18n.t('shipment.publish'),
                                message: i18n.t('shipment.publishConfirm'),
                              );
                              if (!ok) return;
                              await _act(
                                () => ref.read(shipmentRepositoryProvider).publish(shipment.id),
                                'shipment.published',
                              );
                            },
                          ),
                        if (shipment.canCancel)
                          AppButton(
                            label: i18n.t('shipment.cancelRequest'),
                            icon: Icons.cancel_outlined,
                            variant: AppButtonVariant.danger,
                            loading: _busy,
                            onPressed: () async {
                              final ok = await showConfirmDialog(
                                context,
                                i18n: i18n,
                                title: i18n.t('shipment.cancelRequest'),
                                message: i18n.t('shipment.cancelConfirm'),
                                danger: true,
                              );
                              if (!ok) return;
                              await _act(
                                () => ref.read(shipmentRepositoryProvider).cancel(shipment.id),
                                'shipment.cancelled',
                              );
                            },
                          ),
                      ],
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

  String _shipmentStep(String? status) {
    return switch (status) {
      'published' || 'expired' => 'published',
      'awarded' => 'awarded',
      _ => 'draft',
    };
  }
}
