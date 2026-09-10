import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/providers.dart';
import '../../../core/utils/json_utils.dart';
import '../../../shared/models/pagination_meta.dart';
import 'notification_model.dart';

class NotificationRepository {
  NotificationRepository(this._api);

  final ApiClient _api;

  Future<PagedResult<AppNotification>> list({int page = 1}) async {
    final envelope = await _api.get('/notifications', query: {'page': page, 'per_page': 20});
    final source = envelope.data is Map ? asMap(envelope.data) : envelope.map;
    final items = envelope.list.isNotEmpty
        ? envelope.list
        : asList(source['data']);
    return PagedResult(
      items: items
          .whereType<Map>()
          .map((item) => AppNotification.fromJson(asMap(item)))
          .toList(),
      meta: PaginationMeta.fromJson({...source, ...envelope.meta}),
    );
  }

  Future<void> markRead(String id) => _api.post('/notifications/$id/read');

  Future<void> markAllRead() => _api.post('/notifications/read-all');
}

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(ref.watch(apiClientProvider));
});
