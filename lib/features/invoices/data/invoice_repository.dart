import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/providers.dart';
import '../../../core/utils/json_utils.dart';
import '../../../shared/models/pagination_meta.dart';
import '../../jobs/data/job_model.dart';
import '../../payments/data/bank_account.dart';
import '../../payments/data/payment_model.dart';
import '../../quotations/data/quotation_accept_result.dart';
import 'invoice_model.dart';

class InvoiceRepository {
  InvoiceRepository(this._api);

  final ApiClient _api;

  /// The invoice screen has no pager, so the statement includes every page.
  Future<PagedResult<Invoice>> list() async {
    final items = <Invoice>[];
    var page = 1;
    var meta = const PaginationMeta();
    const pageSize = 50;
    const maxPages = 20;

    while (page <= maxPages) {
      final envelope = await _api.get('/invoices', query: {
        'page': page,
        'per_page': pageSize,
      });
      items.addAll(
        envelope.list
            .whereType<Map>()
            .map((item) => Invoice.fromJson(asMap(item))),
      );
      meta = PaginationMeta.fromJson(
        envelope.meta.isEmpty ? envelope.map : envelope.meta,
      );
      if (!meta.hasMore) break;
      page++;
    }

    return PagedResult(items: items, meta: meta);
  }

  Future<QuotationAcceptResult> pay(int id, {required String paymentMethod}) async {
    final envelope = await _api.post(
      '/invoices/$id/pay',
      data: {'payment_method': paymentMethod},
    );
    final map = envelope.map;
    if (asBool(map['awaiting_transfer'])) {
      return QuotationAcceptResult(
        requiresCheckout: false,
        awaitingTransfer: true,
        payment: map['payment'] is Map ? Payment.fromJson(asMap(map['payment'])) : null,
        bankAccount: BankAccount.fromJson(map['bank_account'] is Map ? asMap(map['bank_account']) : null),
        job: map['job'] is Map ? TransportJob.fromJson(asMap(map['job'])) : null,
      );
    }
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
