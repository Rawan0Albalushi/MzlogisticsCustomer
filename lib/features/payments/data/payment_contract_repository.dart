import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/providers.dart';
import 'payment_contract_model.dart';

class PaymentContractRepository {
  PaymentContractRepository(this._api);

  final ApiClient _api;

  Future<PaymentContract> current() async {
    final envelope = await _api.get('/payment-contract');
    return PaymentContract.fromJson(envelope.map);
  }

  Future<PaymentContract> update({
    required int organizationId,
    required String billingTrigger,
    required int dueDays,
    String billingUnit = 'job',
  }) async {
    final envelope = await _api.put(
      '/organizations/$organizationId/payment-contract',
      data: {
        'billing_trigger': billingTrigger,
        'due_days': dueDays,
        'billing_unit': billingTrigger == 'on_award' ? 'job' : billingUnit,
      },
    );
    return PaymentContract.fromJson(envelope.map);
  }
}

final paymentContractRepositoryProvider = Provider<PaymentContractRepository>((ref) {
  return PaymentContractRepository(ref.watch(apiClientProvider));
});
