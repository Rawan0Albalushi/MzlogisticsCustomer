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
      if (!mounted || !widget.enabled || widget.trigger == _deliveryTrigger) {
        return;
      }
      widget.onTriggerChanged(_deliveryTrigger);
    });
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

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
      initialDate: initial.isBefore(firstDate) || initial.isAfter(lastDate)
          ? firstDate
          : initial,
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
    final dueLabel = widget.dueDays > 0
        ? formatDate(_dueDate, locale: i18n.locale.languageCode)
        : i18n.t('paymentContract.pickDueDate');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _GroupLabel(label: i18n.t('paymentContract.unit')),
        const SizedBox(height: 8),
        _TermOption(
          selected: widget.unit == 'job',
          title: i18n.t('paymentContract.unitJob'),
          subtitle: i18n.t('paymentContract.unitJobHint'),
          onTap: widget.enabled ? () => widget.onUnitChanged('job') : null,
        ),
        const SizedBox(height: 8),
        _TermOption(
          selected: widget.unit == 'trip',
          title: i18n.t('paymentContract.unitTrip'),
          subtitle: i18n.t('paymentContract.unitTripHint'),
          onTap: widget.enabled ? () => widget.onUnitChanged('trip') : null,
        ),
        const SizedBox(height: 18),
        _GroupLabel(label: i18n.t('paymentContract.dueDays')),
        const SizedBox(height: 8),
        _TermOption(
          selected: !_specifyDate,
          title: i18n.t('paymentContract.dueImmediate'),
          onTap: widget.enabled ? _selectImmediate : null,
        ),
        const SizedBox(height: 8),
        _TermOption(
          selected: _specifyDate,
          title: i18n.t('paymentContract.dueOnDate'),
          onTap: widget.enabled ? _selectSpecifyDate : null,
          footer: _specifyDate
              ? _DueDateButton(
                  label: dueLabel,
                  placeholder: widget.dueDays <= 0,
                  enabled: widget.enabled,
                  onTap: _pickDueDate,
                )
              : null,
        ),
      ],
    );
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelLarge
          ?.copyWith(fontWeight: FontWeight.w700, color: AppColors.ink),
    );
  }
}

class _TermOption extends StatelessWidget {
  const _TermOption({
    required this.selected,
    required this.title,
    this.subtitle,
    this.onTap,
    this.footer,
  });

  final bool selected;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final description = [
      title,
      if (subtitle != null && subtitle!.isNotEmpty) subtitle!,
    ].join('. ');
    return Material(
      color: selected ? AppColors.navySoft : AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? AppColors.navy : AppColors.border,
          width: selected ? 1.5 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            button: true,
            selected: selected,
            enabled: enabled,
            label: description,
            child: InkWell(
              onTap: onTap,
              excludeFromSemantics: true,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  child: ExcludeSemantics(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: _SelectionMark(
                            selected: selected,
                            enabled: enabled,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: enabled
                                          ? AppColors.ink
                                          : AppColors.muted,
                                      height: 1.35,
                                    ),
                              ),
                              if (subtitle != null && subtitle!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  subtitle!,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: AppColors.muted,
                                        height: 1.4,
                                      ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (footer != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(
                start: 44,
                end: 12,
                bottom: 12,
              ),
              child: footer,
            ),
        ],
      ),
    );
  }
}

class _SelectionMark extends StatelessWidget {
  const _SelectionMark({required this.selected, required this.enabled});

  final bool selected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final ring = !enabled
        ? AppColors.border
        : selected
        ? AppColors.navy
        : AppColors.muted;
    return Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.white,
        border: Border.all(color: ring, width: 2),
      ),
      child: selected
          ? Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: enabled ? AppColors.navy : AppColors.muted,
              ),
            )
          : null,
    );
  }
}

class _DueDateButton extends StatelessWidget {
  const _DueDateButton({
    required this.label,
    required this.placeholder,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool placeholder;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onTap : null,
          excludeFromSemantics: true,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: ExcludeSemantics(
                child: Row(
                  children: [
                    Icon(
                      Icons.event_outlined,
                      size: 18,
                      color: placeholder ? AppColors.muted : AppColors.navy,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        label,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: placeholder ? AppColors.muted : AppColors.ink,
                          fontWeight: placeholder
                              ? FontWeight.w500
                              : FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
