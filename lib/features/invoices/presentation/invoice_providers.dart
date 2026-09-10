import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/pagination_meta.dart';
import '../data/invoice_model.dart';
import '../data/invoice_repository.dart';

final invoicesProvider = FutureProvider.autoDispose<PagedResult<Invoice>>((ref) {
  return ref.watch(invoiceRepositoryProvider).list();
});
