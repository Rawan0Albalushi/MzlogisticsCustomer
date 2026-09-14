import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class AppGroupedListView<T> extends StatelessWidget {
  const AppGroupedListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.onRefresh,
    this.padding = const EdgeInsets.fromLTRB(16, 12, 16, 24),
    this.header,
  });

  final List<T> items;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final Future<void> Function()? onRefresh;
  final EdgeInsets padding;
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    final list = ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: padding,
      children: [
        if (header != null) ...[
          header!,
          const SizedBox(height: 12),
        ],
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var index = 0; index < items.length; index++) ...[
                if (index > 0) const Divider(height: 1, indent: 16, endIndent: 16),
                itemBuilder(context, items[index]),
              ],
            ],
          ),
        ),
      ],
    );

    if (onRefresh == null) return list;
    return RefreshIndicator(
      color: AppColors.navy,
      onRefresh: onRefresh!,
      child: list,
    );
  }
}

class AppTableCard extends StatelessWidget {
  const AppTableCard({
    super.key,
    required this.child,
    this.onRefresh,
  });

  final Widget child;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final body = ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ColoredBox(
                color: AppColors.accentFrom,
                child: SizedBox(height: 3),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: child,
              ),
            ],
          ),
        ),
      ],
    );

    if (onRefresh == null) return body;
    return RefreshIndicator(
      color: AppColors.navy,
      onRefresh: onRefresh!,
      child: body,
    );
  }
}
