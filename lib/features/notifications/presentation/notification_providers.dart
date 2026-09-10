import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/pagination_meta.dart';
import '../data/notification_model.dart';
import '../data/notification_repository.dart';

final notificationsProvider =
    FutureProvider.autoDispose<PagedResult<AppNotification>>((ref) {
  return ref.watch(notificationRepositoryProvider).list();
});
