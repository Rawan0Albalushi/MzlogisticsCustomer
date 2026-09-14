import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/i18n/i18n_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/app_button.dart';
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
          return ContentWidth(
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                EntitySummaryCard(
                  title: shipment.reference ?? shipment.cargoType ?? '—',
                  subtitle: shipment.cargoType,
                  icon: Icons.inventory_2_rounded,
                  badge: StatusBadge(status: shipment.status ?? '', label: i18n.status(shipment.status)),
                  facts: [
                    EntityFact(
                      i18n.t('shipment.requiredDate'),
                      formatDate(shipment.requiredDate, locale: locale),
                    ),
                    EntityFact(
                      i18n.t('shipment.weight'),
                      '${formatNumber(shipment.weightTons)} ${i18n.t('common.tons')}',
                    ),
                  ],
                  footer: AppRouteLine(
                    from: shipment.pickupCity ?? shipment.pickupAddress ?? '—',
                    to: shipment.deliveryCity ?? shipment.deliveryAddress ?? '—',
                  ),
                ),
                const SizedBox(height: 16),
                SectionCard(
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
                const SizedBox(height: 16),
                SectionCard(
                  title: i18n.t('shipment.cargo'),
                  icon: Icons.category_rounded,
                  child: Wrap(
                    spacing: 24,
                    runSpacing: 16,
                    children: [
                      InfoRow(label: i18n.t('shipment.cargoType'), value: shipment.cargoType ?? '—'),
                      InfoRow(
                        label: i18n.t('shipment.weight'),
                        value: '${formatNumber(shipment.weightTons)} ${i18n.t('common.tons')}',
                      ),
                      if (!QuantityUnits.isTons(shipment.quantityUnit))
                        InfoRow(
                          label: QuantityUnits.countFieldLabel(i18n, shipment.quantityUnit ?? ''),
                          value: QuantityUnits.formatQuantity(
                            i18n,
                            shipment.quantity,
                            shipment.quantityUnit,
                          ),
                        ),
                      InfoRow(
                        label: i18n.t('shipment.volume'),
                        value: shipment.volumeCbm == null
                            ? i18n.t('common.notAvailable')
                            : '${formatNumber(shipment.volumeCbm)} ${i18n.t('common.cbm')}',
                      ),
                      if (shipment.cargoDescription != null)
                        SizedBox(
                          width: double.infinity,
                          child: InfoRow(
                            label: i18n.t('shipment.cargoDescription'),
                            value: shipment.cargoDescription!,
                            wide: true,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SectionCard(
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
                      ),
                      if (shipment.notes != null)
                        InfoRow(label: i18n.t('common.notes'), value: shipment.notes!, wide: true),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
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
                if (shipment.quotations.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    i18n.t('shipment.quotationsCount', {'count': '${shipment.quotations.length}'}),
                    style: const TextStyle(color: AppColors.muted),
                  ),
                ],
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
