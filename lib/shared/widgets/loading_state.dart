import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class LoadingState extends StatelessWidget {
  const LoadingState({super.key, this.label});

  final String? label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: AppColors.navy,
            ),
          ),
          if (label != null) ...[
            const SizedBox(height: 12),
            Text(
              label!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.muted,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
