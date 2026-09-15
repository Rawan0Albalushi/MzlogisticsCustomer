import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/i18n/i18n_controller.dart';
import '../../home/presentation/home_providers.dart';
import '../../jobs/presentation/job_providers.dart';
import '../../payments/data/checkout_args.dart';
import '../../payments/presentation/payment_providers.dart';
import '../../shipments/presentation/shipment_providers.dart';
import '../data/quotation_accept_result.dart';
import '../data/quotation_model.dart';
import '../data/quotation_repository.dart';
import 'accept_quotation_dialog.dart';
import 'quotation_providers.dart';

Future<void> startQuotationAcceptance({
  required BuildContext context,
  required WidgetRef ref,
  required Quotation quotation,
}) async {
  final i18n = ref.i18n;
  if (!quotation.canAccept) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(i18n.t('quotation.cannotAccept'))));
    return;
  }

  var prepaid = true;
  final shipmentId = quotation.shipmentRequestId;
  if (shipmentId != null) {
    final shipment = await ref.read(shipmentDetailProvider(shipmentId).future);
    prepaid = shipment.isPrepaid;
  }
  if (!context.mounted) return;

  final method = await showAcceptQuotationDialog(
    context: context,
    ref: ref,
    prepaid: prepaid,
  );
  if (method == null || !context.mounted) return;

  try {
    final result = await ref
        .read(quotationRepositoryProvider)
        .accept(quotation.id, paymentMethod: prepaid ? method : null);
    ref.invalidate(quotationDetailProvider(quotation.id));
    ref.invalidate(jobsProvider);
    ref.invalidate(paymentsProvider);
    ref.invalidate(shipmentsProvider);
    ref.invalidate(dashboardProvider);
    if (shipmentId != null) {
      ref.invalidate(quotationsByShipmentProvider(shipmentId));
      ref.invalidate(shipmentDetailProvider(shipmentId));
    }
    if (!context.mounted) return;
    _openAcceptance(context, i18n, result, prepaid: prepaid);
  } catch (error) {
    if (!context.mounted) return;
    final message = error is ApiException && error.message == 'network'
        ? i18n.t('common.networkError')
        : error.toString();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

void _openAcceptance(
  BuildContext context,
  I18nBundle i18n,
  QuotationAcceptResult result, {
  required bool prepaid,
}) {
  if (result.requiresCheckout && result.payment != null) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(i18n.t('payment.redirecting'))));
    context.go(
      '/payments/checkout/${result.payment!.id}',
      extra: CheckoutArgs(paymentLink: result.paymentLink),
    );
    return;
  }
  if (result.job != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          i18n.t(prepaid ? 'quotation.accepted' : 'quotation.acceptedDeferred'),
        ),
      ),
    );
    context.go('/jobs/${result.job!.id}');
  }
}
