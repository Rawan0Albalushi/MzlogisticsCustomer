import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/payment_contract_model.dart';
import '../data/payment_contract_repository.dart';

final paymentContractProvider = FutureProvider.autoDispose<PaymentContract>((ref) {
  return ref.watch(paymentContractRepositoryProvider).current();
});
