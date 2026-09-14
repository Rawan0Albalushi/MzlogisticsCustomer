import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class AppRouteLine extends StatelessWidget {
  const AppRouteLine({
    super.key,
    required this.from,
    required this.to,
    this.compact = false,
  });

  final String from;
  final String to;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.muted,
          height: 1.3,
        );
    return Row(
      children: [
        if (!compact) ...[
          const _RouteMark(),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(from, maxLines: 1, overflow: TextOverflow.ellipsis, style: style),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Icon(Icons.arrow_forward, size: 12, color: AppColors.navyMuted),
              ),
              Flexible(
                child: Text(to, maxLines: 1, overflow: TextOverflow.ellipsis, style: style),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RouteMark extends StatelessWidget {
  const _RouteMark();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 12,
      height: 32,
      child: Column(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(color: AppColors.navy, shape: BoxShape.circle),
          ),
          Expanded(child: Container(width: 2, color: AppColors.border)),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.accentFrom,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.onNeon, width: 1.2),
            ),
          ),
        ],
      ),
    );
  }
}
