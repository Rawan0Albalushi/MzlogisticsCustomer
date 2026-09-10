import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

String accountTypeLabel(I18nBundle i18n, String? type) {
  switch (type) {
    case 'individual':
      return i18n.t('auth.individual');
    case 'company':
      return i18n.t('auth.company');
    default:
      return type == null || type.isEmpty
          ? i18n.t('common.notAvailable')
          : type;
  }
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

class ProfilePanel extends StatelessWidget {
  const ProfilePanel({
    super.key,
    required this.title,
    required this.child,
    this.icon,
    this.trailing,
    this.hint,
  });

  final IconData? icon;
  final String title;
  final Widget? trailing;
  final String? hint;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (icon != null) ...[
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.mist,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: Icon(icon, size: 18, color: AppColors.navy),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: text.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.navy,
                          ),
                        ),
                        if (hint != null && hint!.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            hint!,
                            style: text.bodySmall?.copyWith(
                              color: AppColors.muted,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 8),
                  trailing!,
                ],
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class ProfileMetaChip extends StatelessWidget {
  const ProfileMetaChip({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.mist,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.navy),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: AppColors.navy, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class ProfileDetailsGroup extends StatelessWidget {
  const ProfileDetailsGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (var index = 0; index < children.length; index++) ...[
            children[index],
            if (index < children.length - 1)
              const Divider(height: 1, indent: 56, endIndent: 12),
          ],
        ],
      ),
    );
  }
}

class ProfileDetailTile extends StatelessWidget {
  const ProfileDetailTile({
    super.key,
    required this.i18n,
    required this.icon,
    required this.label,
    required this.value,
    this.copyable = false,
    this.ltr = false,
  });

  final I18nBundle i18n;
  final IconData icon;
  final String label;
  final String value;
  final bool copyable;
  final bool ltr;

  bool get _hasValue => value.isNotEmpty && value != '—';

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(icon, size: 16, color: AppColors.navy),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: text.labelSmall?.copyWith(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _hasValue ? value : i18n.t('common.notAvailable'),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  textDirection: ltr ? TextDirection.ltr : null,
                  style: text.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                    color: _hasValue ? AppColors.ink : AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          if (copyable && _hasValue)
            IconButton(
              tooltip: i18n.t('profile.copy'),
              visualDensity: VisualDensity.compact,
              onPressed: () => copyProfileValue(context, i18n, value),
              icon: const Icon(
                Icons.copy_outlined,
                size: 18,
                color: AppColors.muted,
              ),
            ),
        ],
      ),
    );
  }
}

class PasswordStrengthBar extends StatelessWidget {
  const PasswordStrengthBar({super.key, required this.value});

  final String value;

  int get _score {
    if (value.isEmpty) return 0;
    if (value.length < 8) return 1;
    final mixed = RegExp(r'[A-Za-z]').hasMatch(value) &&
        RegExp(r'\d').hasMatch(value);
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
