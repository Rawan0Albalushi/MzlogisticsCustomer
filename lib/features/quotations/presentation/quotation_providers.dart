import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/pagination_meta.dart';
import '../data/quotation_model.dart';
import '../data/quotation_repository.dart';

final quotationsByShipmentProvider =
    FutureProvider.autoDispose.family<PagedResult<Quotation>, int>((ref, shipmentId) {
  return ref.watch(quotationRepositoryProvider).list(shipmentRequestId: shipmentId);
});

final quotationDetailProvider =
    FutureProvider.autoDispose.family<Quotation, int>((ref, id) {
  return ref.watch(quotationRepositoryProvider).getById(id);
});
