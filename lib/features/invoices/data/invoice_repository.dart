import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/providers.dart';
import '../../../core/utils/json_utils.dart';
import '../../../shared/models/pagination_meta.dart';
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
}

final invoiceRepositoryProvider = Provider<InvoiceRepository>((ref) {
  return InvoiceRepository(ref.watch(apiClientProvider));
});
