import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/providers.dart';
import '../../../core/utils/json_utils.dart';
import '../../../shared/models/pagination_meta.dart';
import 'payment_model.dart';

class PaymentRepository {
  PaymentRepository(this._api);

  final ApiClient _api;

  Future<PagedResult<Payment>> list({int page = 1}) async {
    final envelope = await _api.get('/payments', query: {'page': page});
    return PagedResult(
      items: envelope.list
          .whereType<Map>()
          .map((item) => Payment.fromJson(asMap(item)))
          .toList(),
      meta: PaginationMeta.fromJson(envelope.meta.isEmpty ? envelope.map : envelope.meta),
    );
  }
}

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepository(ref.watch(apiClientProvider));
});
