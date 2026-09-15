import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/i18n_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_button.dart';
import '../../payments/presentation/select_payment_method_dialog.dart';

Future<String?> showAcceptQuotationDialog({
  required BuildContext context,
  required WidgetRef ref,
  bool prepaid = true,
}) async {
  if (prepaid) {
    return showSelectPaymentMethodDialog(
      context: context,
      ref: ref,
      titleKey: 'quotation.accept',
      confirmHintKey: 'quotation.acceptConfirm',
    );
  }

  final i18n = ref.i18n;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(i18n.t('quotation.accept')),
        content: Text(
          i18n.t('quotation.acceptDeferred'),
          style: const TextStyle(color: AppColors.muted),
        ),
        actions: [
          AppButton(
            label: i18n.t('common.cancel'),
            variant: AppButtonVariant.ghost,
            onPressed: () => Navigator.pop(context, false),
          ),
          AppButton(
            label: i18n.t('common.confirm'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      );
    },
  );

  return confirmed == true ? '' : null;
}
