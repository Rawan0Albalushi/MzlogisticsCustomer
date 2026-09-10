import 'package:flutter/material.dart';

import '../../core/i18n/i18n_controller.dart';
import '../../core/theme/app_colors.dart';
import 'app_button.dart';

Future<bool> showConfirmDialog(
  BuildContext context, {
  required I18nBundle i18n,
  required String title,
  required String message,
  String? confirmLabel,
  bool danger = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message, style: const TextStyle(color: AppColors.muted)),
        actions: [
          AppButton(
            label: i18n.t('common.cancel'),
            variant: AppButtonVariant.ghost,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          AppButton(
            label: confirmLabel ?? i18n.t('common.confirm'),
            variant: danger ? AppButtonVariant.danger : AppButtonVariant.primary,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      );
    },
  );
  return result ?? false;
}
