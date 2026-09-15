import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/providers.dart';
import '../../../core/utils/json_utils.dart';
import '../../../shared/models/pagination_meta.dart';
import '../../jobs/data/job_model.dart';
import '../../payments/data/payment_model.dart';
import '../../quotations/data/quotation_accept_result.dart';
import 'invoice_model.dart';

class InvoiceRepository {
  InvoiceRepository(this._api);

  final ApiClient _api;

  Future<PagedResult<Invoice>> list({int page = 1}) async {
    final envelope = await _api.get('/invoices', query: {'page': page});
    return PagedResult(
      items: envelope.list
          .whereType<Map>()
          .map((item) => Invoice.fromJson(asMap(item)))
          .toList(),
      meta: PaginationMeta.fromJson(envelope.meta.isEmpty ? envelope.map : envelope.meta),
    );
  }

  Future<QuotationAcceptResult> pay(int id, {required String paymentMethod}) async {
    final envelope = await _api.post(
      '/invoices/$id/pay',
      data: {'payment_method': paymentMethod},
    );
    final map = envelope.map;
    if (asBool(map['requires_checkout'])) {
      return QuotationAcceptResult(
        requiresCheckout: true,
        paymentLink: asString(map['payment_link']),
        payment: map['payment'] is Map ? Payment.fromJson(asMap(map['payment'])) : null,
        job: map['job'] is Map ? TransportJob.fromJson(asMap(map['job'])) : null,
      );
    }
    return QuotationAcceptResult(
      requiresCheckout: false,
      payment: map['payment'] is Map ? Payment.fromJson(asMap(map['payment'])) : null,
      job: map['job'] is Map ? TransportJob.fromJson(asMap(map['job'])) : null,
    );
  }
}

final invoiceRepositoryProvider = Provider<InvoiceRepository>((ref) {
  return InvoiceRepository(ref.watch(apiClientProvider));
});
