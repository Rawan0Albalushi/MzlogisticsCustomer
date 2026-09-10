import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/i18n/i18n_controller.dart';
import 'empty_state.dart';
import 'error_state.dart';
import 'loading_state.dart';

class AsyncBody<T> extends StatelessWidget {
  const AsyncBody({
    super.key,
    required this.value,
    required this.i18n,
    required this.builder,
    this.onRetry,
    this.isEmpty,
    this.emptyTitle,
    this.emptyMessage,
    this.emptyIcon = Icons.inbox_outlined,
    this.emptyAction,
  });

  final AsyncValue<T> value;
  final I18nBundle i18n;
  final Widget Function(T data) builder;
  final VoidCallback? onRetry;
  final bool Function(T data)? isEmpty;
  final String? emptyTitle;
  final String? emptyMessage;
  final IconData emptyIcon;
  final Widget? emptyAction;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => LoadingState(label: i18n.t('common.loading')),
      error: (error, _) => ErrorState(
        i18n: i18n,
        error: error,
        onRetry: onRetry,
      ),
      data: (data) {
        if (isEmpty?.call(data) ?? false) {
          return EmptyState(
            title: emptyTitle ?? i18n.t('common.empty'),
            message: emptyMessage,
            icon: emptyIcon,
            action: emptyAction,
          );
        }
        return builder(data);
      },
    );
  }
}
