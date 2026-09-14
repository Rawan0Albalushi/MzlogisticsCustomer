import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/i18n_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/pagination_meta.dart';
import '../../../shared/widgets/app_grouped_list.dart';
import '../../../shared/widgets/app_list_card.dart';
import '../../../shared/widgets/async_body.dart';
import '../../../shared/widgets/page_scaffold.dart';
import '../data/notification_model.dart';
import '../data/notification_repository.dart';
import 'notification_providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n = ref.i18n;
    final value = ref.watch(notificationsProvider);

    Future<void> refresh() async {
      ref.invalidate(notificationsProvider);
      await ref.read(notificationsProvider.future);
    }

    return PageScaffold(
      title: i18n.t('notification.title'),
      actions: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: Colors.white),
          onPressed: () async {
            await ref.read(notificationRepositoryProvider).markAllRead();
            ref.invalidate(notificationsProvider);
          },
          child: Text(i18n.t('notification.markAll')),
        ),
      ],
      body: ContentWidth(
        padding: EdgeInsets.zero,
        child: AsyncBody<PagedResult<AppNotification>>(
          value: value,
          i18n: i18n,
          onRetry: () => ref.invalidate(notificationsProvider),
          onRefresh: refresh,
          isEmpty: (data) => data.items.isEmpty,
          emptyTitle: i18n.t('notification.empty'),
          emptyIcon: Icons.notifications_none,
          builder: (page) {
            return AppGroupedListView<AppNotification>(
              items: page.items,
              itemBuilder: (context, item) {
                return AppListCard(
                  embedded: true,
                  highlighted: item.isUnread,
                  title: item.title ?? i18n.t('notification.title'),
                  subtitle: item.body,
                  meta: formatDateTime(item.createdAt, locale: i18n.locale.languageCode),
                  showChevron: false,
                  trailing: item.isUnread
                      ? IconButton(
                          tooltip: i18n.t('notification.markRead'),
                          onPressed: () async {
                            await ref.read(notificationRepositoryProvider).markRead(item.id);
                            ref.invalidate(notificationsProvider);
                          },
                          icon: const Icon(Icons.mark_email_read_outlined, color: AppColors.navy),
                        )
                      : null,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
