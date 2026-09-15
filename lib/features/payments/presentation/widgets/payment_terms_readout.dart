import 'package:flutter/material.dart';

import '../../../../core/i18n/i18n_controller.dart';
import '../../data/payment_contract_model.dart';
import '../../../../shared/widgets/info_row.dart';

class PaymentTermsReadout extends StatelessWidget {
  const PaymentTermsReadout({super.key, required this.i18n, required this.terms});

  final I18nBundle i18n;
  final PaymentTermsSnapshot terms;

  @override
  Widget build(BuildContext context) {
    final prepaid = terms.prepaid || terms.billingTrigger == 'on_award';
    return Wrap(
      spacing: 24,
      runSpacing: 16,
      children: [
        InfoRow(
          label: i18n.t('paymentContract.trigger'),
          value: prepaid ? i18n.t('paymentContract.onAward') : i18n.t('paymentContract.onDelivery'),
          icon: Icons.schedule_outlined,
        ),
        if (!prepaid) ...[
          InfoRow(
            label: i18n.t('paymentContract.unit'),
            value: terms.billingUnit == 'trip'
                ? i18n.t('paymentContract.unitTrip')
                : i18n.t('paymentContract.unitJob'),
            icon: Icons.account_balance_wallet_outlined,
          ),
          InfoRow(
            label: i18n.t('paymentContract.dueDays'),
            value: terms.dueDays <= 0
                ? i18n.t('paymentContract.dueImmediate')
                : i18n.t('paymentContract.netDays', {'days': '${terms.dueDays}'}),
            icon: Icons.event_available_outlined,
          ),
        ],
      ],
    );
  }
}
