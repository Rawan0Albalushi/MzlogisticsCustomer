import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/providers.dart';
import '../../../core/utils/json_utils.dart';
import '../../../shared/models/pagination_meta.dart';
import 'shipment_model.dart';

class ShipmentRepository {
  ShipmentRepository(this._api);

  final ApiClient _api;

  Future<PagedResult<ShipmentRequest>> list({int page = 1}) async {
    final envelope = await _api.get('/shipments', query: {'page': page});
    return PagedResult(
      items: envelope.list
          .whereType<Map>()
          .map((item) => ShipmentRequest.fromJson(asMap(item)))
          .toList(),
      meta: PaginationMeta.fromJson(envelope.meta.isEmpty ? envelope.map : envelope.meta),
    );
  }

  Future<ShipmentRequest> getById(int id) async {
    final envelope = await _api.get('/shipments/$id');
    return ShipmentRequest.fromJson(envelope.map);
  }

  Future<ShipmentRequest> create(CreateShipmentPayload payload) async {
    final envelope = await _api.post('/shipments', data: payload.toJson());
    return ShipmentRequest.fromJson(envelope.map);
  }

  Future<ShipmentRequest> update(int id, CreateShipmentPayload payload) async {
    final envelope = await _api.put('/shipments/$id', data: payload.toJson());
    return ShipmentRequest.fromJson(envelope.map);
  }

  Future<ShipmentRequest> publish(int id) async {
    final envelope = await _api.post('/shipments/$id/publish');
    return ShipmentRequest.fromJson(envelope.map);
  }

  Future<ShipmentRequest> cancel(int id) async {
    final envelope = await _api.post('/shipments/$id/cancel');
    return ShipmentRequest.fromJson(envelope.map);
  }
}

final shipmentRepositoryProvider = Provider<ShipmentRepository>((ref) {
  return ShipmentRepository(ref.watch(apiClientProvider));
});
