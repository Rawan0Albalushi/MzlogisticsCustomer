import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/providers.dart';
import '../../../core/utils/json_utils.dart';
import '../../../shared/models/pagination_meta.dart';
import '../../jobs/data/job_model.dart';
import 'quotation_model.dart';

class QuotationRepository {
  QuotationRepository(this._api);

  final ApiClient _api;

  Future<PagedResult<Quotation>> list({int? shipmentRequestId, int page = 1}) async {
    final envelope = await _api.get('/quotations', query: {
      'page': page,
      'shipment_request_id': ?shipmentRequestId,
    });
    return PagedResult(
      items: envelope.list
          .whereType<Map>()
          .map((item) => Quotation.fromJson(asMap(item)))
          .toList(),
      meta: PaginationMeta.fromJson(envelope.meta.isEmpty ? envelope.map : envelope.meta),
    );
  }

  Future<Quotation> getById(int id) async {
    final envelope = await _api.get('/quotations/$id');
    return Quotation.fromJson(envelope.map);
  }

  Future<TransportJob> accept(int id, {required String paymentMethod}) async {
    final envelope = await _api.post(
      '/quotations/$id/accept',
      data: {'payment_method': paymentMethod},
    );
    return TransportJob.fromJson(envelope.map);
  }
}

final quotationRepositoryProvider = Provider<QuotationRepository>((ref) {
  return QuotationRepository(ref.watch(apiClientProvider));
});
