import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/i18n_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/page_scaffold.dart';
import '../data/transfer_pending_args.dart';

class TransferPendingScreen extends ConsumerWidget {
  const TransferPendingScreen({super.key, required this.args});

  final TransferPendingArgs args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n = ref.i18n;
    final account = args.bankAccount;
    return PageScaffold(
      title: i18n.t('payment.transferTitle'),
      showBack: true,
      body: ContentWidth(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                i18n.t(args.invoicePayment ? 'payment.transferInvoiceBody' : 'payment.transferBody'),
                style: const TextStyle(color: AppColors.muted, height: 1.5),
              ),
              if (args.reference.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(i18n.t('common.reference'), style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(args.reference),
              ],
              if (account.hasDetails) ...[
                const SizedBox(height: 24),
                Text(i18n.t('payment.transferAccount'), style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                _Detail(label: i18n.t('payment.bankName'), value: account.bankName),
                _Detail(label: i18n.t('payment.accountName'), value: account.accountName),
                _Detail(label: i18n.t('payment.accountNumber'), value: account.accountNumber),
                _Detail(label: i18n.t('payment.iban'), value: account.iban),
              ],
              const SizedBox(height: 28),
              AppButton(
                label: i18n.t('payment.viewPayments'),
                onPressed: () => context.go('/payments'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
          const SizedBox(height: 2),
          SelectableText(value),
        ],
      ),
    );
  }
}
