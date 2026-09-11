import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/pagination_meta.dart';
import '../data/payment_method_model.dart';
import '../data/payment_method_repository.dart';
import '../data/payment_model.dart';
import '../data/payment_repository.dart';

final paymentsProvider = FutureProvider.autoDispose<PagedResult<Payment>>((ref) {
  return ref.watch(paymentRepositoryProvider).list();
});

final activePaymentMethodsProvider = FutureProvider.autoDispose<List<PaymentMethod>>((ref) {
  return ref.watch(paymentMethodRepositoryProvider).active();
});
