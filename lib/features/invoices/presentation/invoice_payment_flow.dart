import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/i18n/i18n_controller.dart';
import '../../jobs/presentation/job_providers.dart';
import '../../payments/data/checkout_args.dart';
import '../../payments/presentation/payment_providers.dart';
import '../../payments/presentation/select_payment_method_dialog.dart';
import '../../quotations/data/quotation_accept_result.dart';
import '../data/invoice_model.dart';
import '../data/invoice_repository.dart';
import 'invoice_providers.dart';

Future<void> startInvoicePayment({
  required BuildContext context,
  required WidgetRef ref,
  required Invoice invoice,
}) async {
  final i18n = ref.i18n;
  final method = await showSelectPaymentMethodDialog(
    context: context,
    ref: ref,
    titleKey: 'invoice.pay',
    confirmHintKey: 'invoice.payConfirm',
  );
  if (method == null || !context.mounted) return;

  try {
    final result = await ref.read(invoiceRepositoryProvider).pay(invoice.id, paymentMethod: method);
    ref.invalidate(invoicesProvider);
    ref.invalidate(paymentsProvider);
    if (result.job != null) {
      ref.invalidate(jobDetailProvider(result.job!.id));
      ref.invalidate(jobsProvider);
    }
    if (!context.mounted) return;
    _openPayment(context, i18n, result);
  } catch (error) {
    if (!context.mounted) return;
    final message = error is ApiException && error.message == 'network'
        ? i18n.t('common.networkError')
        : error.toString();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

void _openPayment(BuildContext context, I18nBundle i18n, QuotationAcceptResult result) {
  if (result.requiresCheckout && result.payment != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(i18n.t('payment.redirecting'))),
    );
    context.go(
      '/payments/checkout/${result.payment!.id}',
      extra: CheckoutArgs(
        paymentLink: result.paymentLink,
        jobId: result.job?.id,
        invoicePayment: true,
      ),
    );
    return;
  }
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(i18n.t('invoice.paid'))),
  );
  if (result.job != null) {
    context.go('/jobs/${result.job!.id}');
  }
}
