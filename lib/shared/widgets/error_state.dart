import 'package:flutter/material.dart';

import '../../core/api/api_exception.dart';
import '../../core/i18n/i18n_controller.dart';
import '../../core/theme/app_colors.dart';
import 'app_button.dart';

class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.i18n,
    required this.error,
    this.onRetry,
  });

  final I18nBundle i18n;
  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final message = _message();
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppColors.danger, size: 36),
              const SizedBox(height: 12),
              Text(
                i18n.t('common.error'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.muted,
                    ),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 16),
                AppButton(
                  label: i18n.t('common.retry'),
                  icon: Icons.refresh,
                  onPressed: onRetry,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _message() {
    if (error is ApiException) {
      final exception = error as ApiException;
      if (exception.message == 'network') return i18n.t('common.networkError');
      if (exception.isUnauthorized) return i18n.t('common.unauthorized');
      return exception.message;
    }
    return error.toString();
  }
}
