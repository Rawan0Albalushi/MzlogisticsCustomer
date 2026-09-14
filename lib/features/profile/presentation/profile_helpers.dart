import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/i18n/i18n_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

String initialsFor(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return 'C';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
      .toUpperCase();
}

String displayOrDash(I18nBundle i18n, String? value) {
  final trimmed = value?.trim() ?? '';
  return trimmed.isEmpty ? i18n.t('common.dash') : trimmed;
}

String accountTypeLabel(I18nBundle i18n, String? type) {
  switch (type) {
    case 'individual':
      return i18n.t('auth.individual');
    case 'company':
      return i18n.t('auth.company');
    default:
      return type == null || type.isEmpty ? i18n.t('common.dash') : type;
  }
}

String mapProfileError(Object error, I18nBundle i18n, List<String> fields) {
  if (error is ApiException) {
    if (error.message == 'network') return i18n.t('common.networkError');
    for (final field in fields) {
      final message = error.fieldError(field);
      if (message != null) return message;
    }
    if (error.isUnauthorized) return i18n.t('common.unauthorized');
    return error.message;
  }
  return error.toString();
}

Future<void> copyProfileValue(
  BuildContext context,
  I18nBundle i18n,
  String value,
) async {
  await Clipboard.setData(ClipboardData(text: value));
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(i18n.t('profile.copied'))));
}

class PasswordStrengthBar extends StatelessWidget {
  const PasswordStrengthBar({super.key, required this.value});

  final String value;

  int get _score {
    if (value.isEmpty) return 0;
    if (value.length < 8) return 1;
    final mixed =
        RegExp(r'[A-Za-z]').hasMatch(value) && RegExp(r'\d').hasMatch(value);
    if (value.length >= 12 || mixed) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final score = _score;
    final colors = [
      AppColors.danger,
      AppColors.amber,
      AppColors.success,
    ];
    return Row(
      children: [
        for (var index = 0; index < 3; index++) ...[
          if (index > 0) const SizedBox(width: 6),
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              height: 4,
              decoration: BoxDecoration(
                color: score > index
                    ? colors[(score - 1).clamp(0, 2)]
                    : AppColors.mist,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

Widget passwordVisibilityToggle({
  required I18nBundle i18n,
  required bool obscure,
  required VoidCallback onToggle,
}) {
  return IconButton(
    tooltip: i18n.t(obscure ? 'profile.showPassword' : 'profile.hidePassword'),
    onPressed: onToggle,
    icon: Icon(
      obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
    ),
  );
}

Future<T?> showProfileSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  final wide = MediaQuery.sizeOf(context).width >= 720;
  if (wide) {
    return showDialog<T>(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: builder(context),
          ),
        );
      },
    );
  }

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppTheme.radiusLg + 6),
      ),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: builder(context),
      );
    },
  );
}
