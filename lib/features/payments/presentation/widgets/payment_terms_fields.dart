import 'package:flutter/material.dart';

import '../../../../core/i18n/i18n_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';

class PaymentTermsFields extends StatefulWidget {
  const PaymentTermsFields({
    super.key,
    required this.i18n,
    required this.trigger,
    required this.unit,
    required this.dueDays,
    required this.onTriggerChanged,
    required this.onUnitChanged,
    required this.onDueDaysChanged,
    this.referenceDate,
    this.enabled = true,
  });

  final I18nBundle i18n;
  final String trigger;
  final String unit;
  final int dueDays;
  final DateTime? referenceDate;
  final ValueChanged<String> onTriggerChanged;
  final ValueChanged<String> onUnitChanged;
  final ValueChanged<int> onDueDaysChanged;
  final bool enabled;

  @override
  State<PaymentTermsFields> createState() => _PaymentTermsFieldsState();
}

class _PaymentTermsFieldsState extends State<PaymentTermsFields> {
  static const _deliveryTrigger = 'on_delivery';

  late bool _specifyDate;

  @override
  void initState() {
    super.initState();
    _specifyDate = widget.dueDays > 0;
    _ensureDeliveryTrigger();
  }

  @override
  void didUpdateWidget(covariant PaymentTermsFields oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger != _deliveryTrigger) {
      _ensureDeliveryTrigger();
    }
    if (oldWidget.dueDays != widget.dueDays && widget.dueDays > 0) {
      _specifyDate = true;
    }
  }

  void _ensureDeliveryTrigger() {
    if (!widget.enabled || widget.trigger == _deliveryTrigger) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.enabled || widget.trigger == _deliveryTrigger) return;
      widget.onTriggerChanged(_deliveryTrigger);
    });
  }

  DateTime _dateOnly(DateTime value) => DateTime(value.year, value.month, value.day);

  DateTime get _anchor => _dateOnly(widget.referenceDate ?? DateTime.now());

  DateTime get _dueDate => _anchor.add(Duration(days: widget.dueDays));

  Future<void> _pickDueDate() async {
    if (!widget.enabled) return;
    final firstDate = _anchor.add(const Duration(days: 1));
    final lastDate = DateTime(_anchor.year + 2, _anchor.month, _anchor.day);
    final initial = widget.dueDays > 0 ? _dueDate : firstDate;
    final selected = await showDatePicker(
      context: context,
      locale: widget.i18n.locale,
      initialDate: initial.isBefore(firstDate) || initial.isAfter(lastDate) ? firstDate : initial,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (selected == null) return;
    final days = _dateOnly(selected).difference(_anchor).inDays;
    if (days <= 0) {
      _selectImmediate();
      return;
    }
    setState(() => _specifyDate = true);
    widget.onDueDaysChanged(days);
  }

  void _selectImmediate() {
    setState(() => _specifyDate = false);
    widget.onDueDaysChanged(0);
  }

  Future<void> _selectSpecifyDate() async {
    setState(() => _specifyDate = true);
    if (widget.dueDays <= 0) {
      await _pickDueDate();
      if (widget.dueDays <= 0 && mounted) {
        setState(() => _specifyDate = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final i18n = widget.i18n;
    final titleStyle = Theme.of(context).textTheme.titleSmall;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(i18n.t('paymentContract.unit'), style: titleStyle),
        RadioListTile<String>(
          contentPadding: EdgeInsets.zero,
          title: Text(i18n.t('paymentContract.unitJob')),
          subtitle: Text(
            i18n.t('paymentContract.unitJobHint'),
            style: const TextStyle(color: AppColors.muted),
          ),
          value: 'job',
          groupValue: widget.unit,
          onChanged: widget.enabled ? (value) => widget.onUnitChanged(value ?? 'job') : null,
        ),
        RadioListTile<String>(
          contentPadding: EdgeInsets.zero,
          title: Text(i18n.t('paymentContract.unitTrip')),
          subtitle: Text(
            i18n.t('paymentContract.unitTripHint'),
            style: const TextStyle(color: AppColors.muted),
          ),
          value: 'trip',
          groupValue: widget.unit,
          onChanged: widget.enabled ? (value) => widget.onUnitChanged(value ?? 'trip') : null,
        ),
        const SizedBox(height: 8),
        Text(i18n.t('paymentContract.dueDays'), style: titleStyle),
        RadioListTile<bool>(
          contentPadding: EdgeInsets.zero,
          title: Text(i18n.t('paymentContract.dueImmediate')),
          value: false,
          groupValue: _specifyDate,
          onChanged: widget.enabled ? (_) => _selectImmediate() : null,
        ),
        RadioListTile<bool>(
          contentPadding: EdgeInsets.zero,
          title: Text(i18n.t('paymentContract.dueOnDate')),
          value: true,
          groupValue: _specifyDate,
          onChanged: widget.enabled ? (_) => _selectSpecifyDate() : null,
        ),
        if (_specifyDate) ...[
          ListTile(
            contentPadding: EdgeInsets.zero,
            enabled: widget.enabled,
            title: Text(
              widget.dueDays > 0
                  ? formatDate(_dueDate, locale: i18n.locale.languageCode)
                  : i18n.t('paymentContract.pickDueDate'),
            ),
            trailing: const Icon(Icons.event),
            onTap: widget.enabled ? _pickDueDate : null,
          ),
        ],
      ],
    );
  }
}
