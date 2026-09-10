import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/i18n/i18n_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/async_body.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/info_row.dart';
import '../../../shared/widgets/page_scaffold.dart';
import '../../../shared/widgets/status_badge.dart';
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
      body: AsyncBody<ShipmentRequest>(
        value: value,
        i18n: i18n,
        onRetry: () => ref.invalidate(shipmentDetailProvider(widget.shipmentId)),
        builder: (shipment) {
          final locale = i18n.locale.languageCode;
          return ContentWidth(
            child: ListView(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        shipment.reference ?? shipment.cargoType ?? '—',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    StatusBadge(status: shipment.status ?? '', label: i18n.status(shipment.status)),
                  ],
                ),
                const SizedBox(height: 16),
                SectionCard(
                  title: i18n.t('shipment.cargo'),
                  child: Wrap(
                    spacing: 24,
                    runSpacing: 16,
                    children: [
                      InfoRow(label: i18n.t('shipment.cargoType'), value: shipment.cargoType ?? '—'),
                      InfoRow(
                        label: i18n.t('shipment.weight'),
                        value: '${formatNumber(shipment.weightTons)} ${i18n.t('common.tons')}',
                      ),
                      InfoRow(
                        label: i18n.t('shipment.volume'),
                        value: shipment.volumeCbm == null
                            ? i18n.t('common.notAvailable')
                            : '${formatNumber(shipment.volumeCbm)} ${i18n.t('common.cbm')}',
                      ),
                      InfoRow(
                        label: i18n.t('shipment.quantity'),
                        value: '${formatNumber(shipment.quantity)} ${shipment.quantityUnit ?? ''}',
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InfoRow(
                        label: i18n.t('common.pickup'),
                        value: '${shipment.pickupAddress ?? ''}, ${shipment.pickupCity ?? ''}',
                        wide: true,
                      ),
                      InfoRow(
                        label: i18n.t('common.delivery'),
                        value: '${shipment.deliveryAddress ?? ''}, ${shipment.deliveryCity ?? ''}',
                        wide: true,
                      ),
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
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    AppButton(
                      label: i18n.t('shipment.viewQuotations'),
                      icon: Icons.compare_arrows,
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
}
