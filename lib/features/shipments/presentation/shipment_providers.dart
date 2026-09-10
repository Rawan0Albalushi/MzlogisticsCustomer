import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/pagination_meta.dart';
import '../data/shipment_model.dart';
import '../data/shipment_repository.dart';

final shipmentsProvider =
    FutureProvider.autoDispose<PagedResult<ShipmentRequest>>((ref) {
  return ref.watch(shipmentRepositoryProvider).list();
});

final shipmentDetailProvider =
    FutureProvider.autoDispose.family<ShipmentRequest, int>((ref, id) {
  return ref.watch(shipmentRepositoryProvider).getById(id);
});
