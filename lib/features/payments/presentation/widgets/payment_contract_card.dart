import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_exception.dart';
import '../../../../core/i18n/i18n_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/info_row.dart';
import '../../../auth/presentation/auth_controller.dart';
import '../../data/payment_contract_model.dart';
import '../../data/payment_contract_repository.dart';
import '../payment_contract_providers.dart';
import 'payment_terms_fields.dart';

class ProfilePaymentContractCard extends ConsumerStatefulWidget {
  const ProfilePaymentContractCard({super.key, required this.i18n});

  final I18nBundle i18n;

  @override
  ConsumerState<ProfilePaymentContractCard> createState() => _ProfilePaymentContractCardState();
}

class _ProfilePaymentContractCardState extends ConsumerState<ProfilePaymentContractCard> {
  String? _trigger;
  int? _dueDays;
  String? _unit;
  bool _saving = false;

  Future<void> _save(PaymentContract contract) async {
    final organizationId = ref.read(authControllerProvider).user?.organizationId ?? contract.organizationId;
    if (organizationId == null || _saving) return;
    final trigger = (_trigger ?? contract.billingTrigger) == 'on_award'
        ? 'on_delivery'
        : (_trigger ?? contract.billingTrigger);
    final dueDays = _dueDays ?? contract.dueDays;
    final unit = _unit ?? contract.billingUnit;
    setState(() => _saving = true);
    try {
      await ref.read(paymentContractRepositoryProvider).update(
            organizationId: organizationId,
            billingTrigger: trigger,
            dueDays: dueDays,
            billingUnit: unit,
          );
      setState(() {
        _trigger = null;
        _dueDays = null;
        _unit = null;
      });
      ref.invalidate(paymentContractProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.i18n.t('paymentContract.saved'))),
      );
    } catch (error) {
      if (!mounted) return;
      final message = error is ApiException && error.message == 'network'
          ? widget.i18n.t('common.networkError')
          : error.toString();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final i18n = widget.i18n;
    final contractAsync = ref.watch(paymentContractProvider);
    final canManage = ref.watch(authControllerProvider).user?.canManageCompany ?? false;

    return contractAsync.when(
      loading: () => SectionCard(
        title: i18n.t('paymentContract.title'),
        icon: Icons.account_balance_wallet_outlined,
        child: Text(i18n.t('common.loading'), style: const TextStyle(color: AppColors.muted)),
      ),
      error: (error, _) => SectionCard(
        title: i18n.t('paymentContract.title'),
        icon: Icons.account_balance_wallet_outlined,
        child: Text(error.toString(), style: const TextStyle(color: AppColors.danger)),
      ),
      data: (contract) {
        final trigger = (_trigger ?? contract.billingTrigger) == 'on_award'
            ? 'on_delivery'
            : (_trigger ?? contract.billingTrigger);
        final dueDays = _dueDays ?? contract.dueDays;
        final unit = _unit ?? contract.billingUnit;
        return SectionCard(
          title: i18n.t('paymentContract.title'),
          icon: Icons.account_balance_wallet_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                i18n.t('paymentContract.hint'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.muted, height: 1.4),
              ),
              if (canManage) ...[
                const SizedBox(height: 16),
                PaymentTermsFields(
                  i18n: i18n,
                  trigger: trigger,
                  unit: unit,
                  dueDays: dueDays,
                  enabled: !_saving,
                  onTriggerChanged: (value) => setState(() => _trigger = value),
                  onUnitChanged: (value) => setState(() => _unit = value),
                  onDueDaysChanged: (value) => setState(() => _dueDays = value),
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: i18n.t('paymentContract.save'),
                  loading: _saving,
                  onPressed: () => _save(contract),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
