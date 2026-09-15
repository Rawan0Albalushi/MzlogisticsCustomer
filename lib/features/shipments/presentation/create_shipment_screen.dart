import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/i18n/i18n_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../shared/models/geo_location.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/location_picker_field.dart';
import '../../../shared/widgets/page_scaffold.dart';
import '../../payments/presentation/payment_contract_providers.dart';
import '../../payments/presentation/widgets/payment_terms_fields.dart';
import '../data/quantity_units.dart';
import '../data/shipment_model.dart';
import '../data/shipment_repository.dart';
import 'shipment_providers.dart';

class CreateShipmentScreen extends ConsumerStatefulWidget {
  const CreateShipmentScreen({super.key});

  @override
  ConsumerState<CreateShipmentScreen> createState() => _CreateShipmentScreenState();
}

class _CreateShipmentScreenState extends ConsumerState<CreateShipmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cargoType = TextEditingController();
  final _cargoDescription = TextEditingController();
  final _weight = TextEditingController();
  final _volume = TextEditingController();
  final _quantity = TextEditingController();
  final _notes = TextEditingController();
  GeoLocation? _pickup;
  GeoLocation? _delivery;
  String _quantityUnit = QuantityUnits.tons;
  DateTime? _requiredDate;
  bool _publish = true;
  bool _submitting = false;
  int _step = 0;
  String? _error;
  String _billingTrigger = 'on_delivery';
  String _billingUnit = 'job';
  int _dueDays = 0;
  bool _paymentPrefillDone = false;

  @override
  void dispose() {
    _cargoType.dispose();
    _cargoDescription.dispose();
    _weight.dispose();
    _volume.dispose();
    _quantity.dispose();
    _notes.dispose();
    super.dispose();
  }

  bool _validateStep(I18nBundle i18n) {
    if (_step == 0) {
      if (_cargoType.text.trim().isEmpty) {
        _error = i18n.t('shipment.cargoTypeRequired');
        return false;
      }
      if ((double.tryParse(_weight.text) ?? 0) <= 0) {
        _error = i18n.t('shipment.weightRequired');
        return false;
      }
      if (!QuantityUnits.isTons(_quantityUnit) && (double.tryParse(_quantity.text) ?? 0) <= 0) {
        _error = i18n.t('shipment.quantityRequired');
        return false;
      }
    }
    if (_step == 1) {
      if (_pickup == null || _pickup!.city.isEmpty) {
        _error = i18n.t('shipment.pickupRequired');
        return false;
      }
      if (!_pickup!.hasCoordinates) {
        _error = i18n.t('location.pickupMapRequired');
        return false;
      }
      if (_delivery == null || _delivery!.city.isEmpty) {
        _error = i18n.t('shipment.deliveryRequired');
        return false;
      }
      if (!_delivery!.hasCoordinates) {
        _error = i18n.t('location.deliveryMapRequired');
        return false;
      }
    }
    _error = null;
    return true;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _requiredDate ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 2),
    );
    if (selected != null) setState(() => _requiredDate = selected);
  }

  Future<void> _submit({required bool publish}) async {
    final i18n = ref.i18n;
    if (_submitting) return;
    if (_requiredDate == null) {
      setState(() => _error = i18n.t('shipment.dateRequired'));
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false) || !_validateStep(i18n)) {
      setState(() {});
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
      _publish = publish;
    });
    try {
      final created = await ref.read(shipmentRepositoryProvider).create(
            CreateShipmentPayload(
              cargoType: _cargoType.text.trim(),
              cargoDescription: _cargoDescription.text.trim(),
              weightTons: double.parse(_weight.text),
              volumeCbm: double.tryParse(_volume.text),
              quantity: QuantityUnits.isTons(_quantityUnit)
                  ? double.parse(_weight.text)
                  : double.parse(_quantity.text),
              quantityUnit: _quantityUnit,
              pickupAddress: _pickup!.address.trim(),
              pickupCity: _pickup!.city.trim(),
              pickupLat: _pickup!.lat,
              pickupLng: _pickup!.lng,
              deliveryAddress: _delivery!.address.trim(),
              deliveryCity: _delivery!.city.trim(),
              deliveryLat: _delivery!.lat,
              deliveryLng: _delivery!.lng,
              requiredDate: _requiredDate!,
              notes: _notes.text.trim(),
              publish: publish,
              billingTrigger: _billingTrigger,
              dueDays: _dueDays,
              billingUnit: _billingUnit,
            ),
          );
      ref.invalidate(shipmentsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(i18n.t('shipment.created'))),
      );
      context.go('/shipments/${created.id}');
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error is ApiException
            ? (error.message == 'network' ? i18n.t('common.networkError') : error.message)
            : error.toString();
      });
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final i18n = ref.i18n;
    final desktop = context.isDesktop;
    final contractAsync = ref.watch(paymentContractProvider);
    contractAsync.whenData((contract) {
      if (_paymentPrefillDone) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _paymentPrefillDone) return;
        setState(() {
          _paymentPrefillDone = true;
          _billingTrigger = contract.billingTrigger == 'on_award'
              ? 'on_delivery'
              : contract.billingTrigger;
          _billingUnit = contract.billingUnit;
          _dueDays = contract.dueDays;
        });
      });
    });
    final steps = [
      i18n.t('shipment.stepCargo'),
      i18n.t('shipment.stepRoute'),
      i18n.t('shipment.stepSchedule'),
    ];

    return PageScaffold(
      title: i18n.t('shipment.create'),
      body: ContentWidth(
        maxWidth: 880,
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (!desktop)
                _NativeStepper(steps: steps, current: _step),
              if (!desktop) ...[
                const SizedBox(height: 16),
                Text(
                  steps[_step],
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
              ],
              if (desktop || _step == 0)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _cargoFields(i18n),
                  ),
                ),
              if (desktop || _step == 1) ...[
                if (desktop) const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _routeFields(i18n),
                  ),
                ),
              ],
              if (desktop || _step == 2) ...[
                if (desktop) const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _scheduleFields(i18n),
                  ),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: AppColors.danger)),
              ],
              const SizedBox(height: 20),
              if (desktop)
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: i18n.t('shipment.saveDraft'),
                        variant: AppButtonVariant.secondary,
                        loading: _submitting && !_publish,
                        onPressed: _submitting ? null : () => _submit(publish: false),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        label: i18n.t('shipment.publish'),
                        loading: _submitting && _publish,
                        onPressed: _submitting ? null : () => _submit(publish: true),
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    if (_step > 0)
                      Expanded(
                        child: AppButton(
                          label: i18n.t('common.back'),
                          variant: AppButtonVariant.secondary,
                          onPressed: _submitting ? null : () => setState(() => _step -= 1),
                        ),
                      ),
                    if (_step > 0) const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        label: _step < 2 ? i18n.t('common.next') : i18n.t('shipment.publish'),
                        loading: _submitting && _step == 2,
                        onPressed: _submitting
                            ? null
                            : () {
                                if (!_validateStep(i18n)) {
                                  setState(() {});
                                  return;
                                }
                                if (_step < 2) {
                                  setState(() => _step += 1);
                                } else {
                                  _submit(publish: _publish);
                                }
                              },
                      ),
                    ),
                  ],
                ),
              if (!desktop && _step == 2) ...[
                const SizedBox(height: 8),
                AppButton(
                  label: i18n.t('shipment.saveDraft'),
                  variant: AppButtonVariant.ghost,
                  onPressed: _submitting ? null : () => _submit(publish: false),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _cargoFields(I18nBundle i18n) {
    final byWeight = QuantityUnits.isTons(_quantityUnit);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(label: i18n.t('shipment.cargoType'), controller: _cargoType),
        const SizedBox(height: 12),
        AppTextField(
          label: i18n.t('shipment.cargoDescription'),
          controller: _cargoDescription,
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        Text(
          i18n.t('shipment.measureBy'),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _measureChip(i18n.t('shipment.measureTons'), QuantityUnits.tons),
            _measureChip(i18n.t('shipment.measurePallets'), QuantityUnits.pallets),
            _measureChip(i18n.t('shipment.measureUnits'), QuantityUnits.units),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          QuantityUnits.measureHint(i18n, _quantityUnit),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.muted, height: 1.4),
        ),
        const SizedBox(height: 16),
        if (!byWeight) ...[
          AppTextField(
            label: QuantityUnits.countFieldLabel(i18n, _quantityUnit),
            controller: _quantity,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 12),
        ],
        AppTextField(
          label: i18n.t('shipment.weight'),
          controller: _weight,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 12),
        AppTextField(
          label: i18n.t('shipment.volume'),
          hint: i18n.t('shipment.volumeHint'),
          controller: _volume,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
      ],
    );
  }

  Widget _measureChip(String label, String value) {
    final selected = _quantityUnit == value;
    return Material(
      color: selected ? AppColors.navy : AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: selected ? AppColors.navy : AppColors.border),
      ),
      child: InkWell(
        onTap: () => setState(() => _quantityUnit = value),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.white : AppColors.ink,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _routeFields(I18nBundle i18n) {
    return Column(
      children: [
        LocationPickerField(
          label: i18n.t('shipment.pickupAddress'),
          value: _pickup,
          i18n: i18n,
          onChanged: (value) => setState(() => _pickup = value),
        ),
        const SizedBox(height: 12),
        LocationPickerField(
          label: i18n.t('shipment.deliveryAddress'),
          value: _delivery,
          i18n: i18n,
          onChanged: (value) => setState(() => _delivery = value),
        ),
      ],
    );
  }

  Widget _scheduleFields(I18nBundle i18n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(i18n.t('shipment.requiredDate')),
          subtitle: Text(
            _requiredDate == null
                ? i18n.t('common.required')
                : '${_requiredDate!.year}-${_requiredDate!.month.toString().padLeft(2, '0')}-${_requiredDate!.day.toString().padLeft(2, '0')}',
          ),
          trailing: const Icon(Icons.event),
          onTap: _pickDate,
        ),
        AppTextField(
          label: i18n.t('common.notes'),
          hint: i18n.t('shipment.notesHint'),
          controller: _notes,
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            i18n.t('paymentContract.title'),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          i18n.t('paymentContract.wizardHint'),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.muted, height: 1.4),
        ),
        const SizedBox(height: 8),
        PaymentTermsFields(
          i18n: i18n,
          trigger: _billingTrigger,
          unit: _billingUnit,
          dueDays: _dueDays,
          referenceDate: _requiredDate,
          enabled: !_submitting,
          onTriggerChanged: (value) => setState(() => _billingTrigger = value),
          onUnitChanged: (value) => setState(() => _billingUnit = value),
          onDueDaysChanged: (value) => setState(() => _dueDays = value),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(i18n.t('shipment.publishNow')),
          subtitle: Text(i18n.t('shipment.publishHint')),
          value: _publish,
          onChanged: (value) => setState(() => _publish = value),
        ),
      ],
    );
  }
}

class _NativeStepper extends StatelessWidget {
  const _NativeStepper({required this.steps, required this.current});

  final List<String> steps;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < steps.length; index++) ...[
          if (index > 0) const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 4,
                  decoration: BoxDecoration(
                    color: index < current
                        ? AppColors.navy
                        : index == current
                            ? AppColors.accentFrom
                            : AppColors.border,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  steps[index],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: index == current ? AppColors.navy : AppColors.muted,
                        fontWeight: index == current ? FontWeight.w700 : FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
