import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/providers.dart';
import '../../../core/utils/json_utils.dart';
import 'payment_method_model.dart';

class PaymentMethodRepository {
  PaymentMethodRepository(this._api);

  final ApiClient _api;

  Future<List<PaymentMethod>> active() async {
    final envelope = await _api.get('/catalog');
    return asList(envelope.map['payment_methods'])
        .whereType<Map>()
        .map((item) => PaymentMethod.fromJson(asMap(item)))
        .where((method) => method.code.isNotEmpty && method.isActive)
        .toList();
  }
}

final paymentMethodRepositoryProvider = Provider<PaymentMethodRepository>((ref) {
  return PaymentMethodRepository(ref.watch(apiClientProvider));
});
