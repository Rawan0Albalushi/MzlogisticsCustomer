import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/i18n/i18n_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/breakpoints.dart';
import '../../../../shared/models/organization.dart';
import '../../../../shared/models/user.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../profile_helpers.dart';

class ProfileAccountSection extends StatelessWidget {
  const ProfileAccountSection({
    super.key,
    required this.i18n,
    required this.user,
    required this.formKey,
    required this.name,
    required this.phone,
    required this.saving,
    required this.dirty,
    required this.onSave,
    required this.onDiscard,
  });

  final I18nBundle i18n;
  final UserAccount user;
  final GlobalKey<FormState> formKey;
  final TextEditingController name;
  final TextEditingController phone;
  final bool saving;
  final bool dirty;
  final VoidCallback onSave;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    final compact = context.isMobile;

    return ProfilePanel(
      icon: Icons.badge_outlined,
      title: i18n.t('profile.account'),
      hint: i18n.t('profile.accountHint'),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (dirty) ...[
              _UnsavedBanner(message: i18n.t('profile.unsaved')),
              const SizedBox(height: 14),
            ],
            AppTextField(
              label: i18n.t('profile.name'),
              controller: name,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              inputFormatters: [LengthLimitingTextInputFormatter(120)],
              validator: (value) => value == null || value.trim().isEmpty
                  ? i18n.t('auth.nameRequired')
                  : null,
            ),
            const SizedBox(height: 14),
            _LockedField(
              i18n: i18n,
              label: i18n.t('auth.email'),
              value: user.email,
              hint: i18n.t('profile.emailLocked'),
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: i18n.t('auth.phone'),
              controller: phone,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              textDirection: TextDirection.ltr,
              autofillHints: const [AutofillHints.telephoneNumber],
              inputFormatters: [LengthLimitingTextInputFormatter(32)],
            ),
            const SizedBox(height: 16),
            if (compact)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppButton(
                    label: i18n.t('common.save'),
                    icon: Icons.check,
                    loading: saving,
                    expanded: true,
                    onPressed: dirty ? onSave : null,
                  ),
                  if (dirty) ...[
                    const SizedBox(height: 8),
                    AppButton(
                      label: i18n.t('profile.discard'),
                      variant: AppButtonVariant.ghost,
                      expanded: true,
                      onPressed: saving ? null : onDiscard,
                    ),
                  ],
                ],
              )
            else
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  AppButton(
                    label: i18n.t('common.save'),
                    icon: Icons.check,
                    loading: saving,
                    onPressed: dirty ? onSave : null,
                  ),
                  if (dirty)
                    AppButton(
                      label: i18n.t('profile.discard'),
                      variant: AppButtonVariant.ghost,
                      onPressed: saving ? null : onDiscard,
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _UnsavedBanner extends StatelessWidget {
  const _UnsavedBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.amberSoft,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: AppColors.amber.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 18, color: AppColors.amber),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LockedField extends StatelessWidget {
  const _LockedField({
    required this.i18n,
    required this.label,
    required this.value,
    required this.hint,
  });

  final I18nBundle i18n;
  final String label;
  final String value;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 10, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: text.labelMedium?.copyWith(color: AppColors.muted),
                  ),
                ),
                const Icon(Icons.lock_outline, size: 16, color: AppColors.muted),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: i18n.t('profile.copy'),
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                  onPressed: () => copyProfileValue(context, i18n, value),
                  icon: const Icon(
                    Icons.copy_outlined,
                    size: 18,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
            Text(
              hint,
              style: text.bodySmall?.copyWith(
                color: AppColors.muted,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfilePasswordSection extends StatelessWidget {
  const ProfilePasswordSection({
    super.key,
    required this.i18n,
    required this.formKey,
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
    required this.obscureCurrent,
    required this.obscureNew,
    required this.obscureConfirm,
    required this.saving,
    required this.onToggleCurrent,
    required this.onToggleNew,
    required this.onToggleConfirm,
    required this.onSave,
  });

  final I18nBundle i18n;
  final GlobalKey<FormState> formKey;
  final TextEditingController currentPassword;
  final TextEditingController newPassword;
  final TextEditingController confirmPassword;
  final bool obscureCurrent;
  final bool obscureNew;
  final bool obscureConfirm;
  final bool saving;
  final VoidCallback onToggleCurrent;
  final VoidCallback onToggleNew;
  final VoidCallback onToggleConfirm;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final newValue = newPassword.text;
    final hint = newValue.isEmpty
        ? i18n.t('profile.passwordHint')
        : newValue.length < 8
            ? i18n.t('auth.passwordShort')
            : i18n.t('profile.passwordOk');
    final hintColor = newValue.isNotEmpty && newValue.length < 8
        ? AppColors.danger
        : newValue.length >= 8
            ? AppColors.success
            : AppColors.muted;

    return ProfilePanel(
      icon: Icons.lock_outline,
      title: i18n.t('profile.password'),
      hint: i18n.t('profile.passwordSectionHint'),
      child: AutofillGroup(
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PasswordStrengthBar(value: newValue),
              const SizedBox(height: 8),
              Text(
                hint,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: hintColor, height: 1.4),
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: i18n.t('profile.currentPassword'),
                controller: currentPassword,
                obscureText: obscureCurrent,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.password],
                suffix: passwordVisibilityToggle(
                  i18n: i18n,
                  obscure: obscureCurrent,
                  onToggle: onToggleCurrent,
                ),
                validator: (value) => value == null || value.isEmpty
                    ? i18n.t('auth.passwordRequired')
                    : null,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: i18n.t('profile.newPassword'),
                controller: newPassword,
                obscureText: obscureNew,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                suffix: passwordVisibilityToggle(
                  i18n: i18n,
                  obscure: obscureNew,
                  onToggle: onToggleNew,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return i18n.t('auth.passwordRequired');
                  }
                  if (value.length < 8) return i18n.t('auth.passwordShort');
                  return null;
                },
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: i18n.t('profile.confirmPassword'),
                controller: confirmPassword,
                obscureText: obscureConfirm,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                suffix: passwordVisibilityToggle(
                  i18n: i18n,
                  obscure: obscureConfirm,
                  onToggle: onToggleConfirm,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return i18n.t('auth.passwordRequired');
                  }
                  if (value != newPassword.text) {
                    return i18n.t('auth.passwordMismatch');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: AppButton(
                  label: i18n.t('profile.updatePassword'),
                  icon: Icons.lock_reset_outlined,
                  variant: AppButtonVariant.secondary,
                  loading: saving,
                  expanded: context.isMobile,
                  onPressed: onSave,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileOrganizationSection extends StatelessWidget {
  const ProfileOrganizationSection({
    super.key,
    required this.i18n,
    required this.organization,
  });

  final I18nBundle i18n;
  final Organization? organization;

  @override
  Widget build(BuildContext context) {
    final locale = i18n.locale.languageCode;
    final org = organization;
    final location = [
      if (org?.city != null && org!.city!.trim().isNotEmpty) org.city!.trim(),
      if (org?.country != null && org!.country!.trim().isNotEmpty)
        org.country!.trim(),
    ].join(' · ');

    return ProfilePanel(
      icon: Icons.apartment_outlined,
      title: i18n.t('profile.organization'),
      hint: org == null ? null : i18n.t('profile.orgHint'),
      trailing: org?.status == null
          ? null
          : StatusBadge(
              status: org!.status ?? '',
              label: i18n.status(org.status),
            ),
      child: org == null
          ? _EmptyOrganization(message: i18n.t('profile.noOrganization'))
          : ProfileDetailsGroup(
              children: [
                ProfileDetailTile(
                  i18n: i18n,
                  icon: Icons.apartment_outlined,
                  label: i18n.t('common.name'),
                  value: org.displayName(locale),
                ),
                ProfileDetailTile(
                  i18n: i18n,
                  icon: org.accountType == 'company'
                      ? Icons.business_outlined
                      : Icons.person_outline,
                  label: i18n.t('profile.accountType'),
                  value: accountTypeLabel(i18n, org.accountType),
                ),
                ProfileDetailTile(
                  i18n: i18n,
                  icon: Icons.badge_outlined,
                  label: i18n.t('profile.cr'),
                  value: org.commercialRegister ?? '',
                  copyable: true,
                ),
                ProfileDetailTile(
                  i18n: i18n,
                  icon: Icons.receipt_long_outlined,
                  label: i18n.t('profile.tax'),
                  value: org.taxNumber ?? '',
                  copyable: true,
                ),
                ProfileDetailTile(
                  i18n: i18n,
                  icon: Icons.mail_outline,
                  label: i18n.t('common.email'),
                  value: org.email ?? '',
                  copyable: true,
                ),
                ProfileDetailTile(
                  i18n: i18n,
                  icon: Icons.phone_outlined,
                  label: i18n.t('common.phone'),
                  value: org.phone ?? '',
                  copyable: true,
                  ltr: true,
                ),
                if (location.isNotEmpty)
                  ProfileDetailTile(
                    i18n: i18n,
                    icon: Icons.place_outlined,
                    label: i18n.t('profile.location'),
                    value: location,
                  ),
                if (org.address != null && org.address!.trim().isNotEmpty)
                  ProfileDetailTile(
                    i18n: i18n,
                    icon: Icons.home_outlined,
                    label: i18n.t('common.address'),
                    value: org.address!.trim(),
                    copyable: true,
                  ),
              ],
            ),
    );
  }
}

class _EmptyOrganization extends StatelessWidget {
  const _EmptyOrganization({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Row(
          children: [
            const Icon(Icons.domain_disabled_outlined, color: AppColors.muted),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.muted,
                      height: 1.4,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileLanguageSection extends StatelessWidget {
  const ProfileLanguageSection({
    super.key,
    required this.i18n,
    required this.selected,
    required this.onSelected,
  });

  final I18nBundle i18n;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return ProfilePanel(
      icon: Icons.translate_outlined,
      title: i18n.t('profile.preferences'),
      hint: i18n.t('profile.languageHint'),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked = constraints.maxWidth < 360;
          final english = _LanguageOption(
            code: 'EN',
            title: i18n.t('profile.englishNative'),
            subtitle: i18n.t('profile.englishHint'),
            selected: selected == 'en',
            onTap: () => onSelected('en'),
          );
          final arabic = _LanguageOption(
            code: 'AR',
            title: i18n.t('profile.arabicNative'),
            subtitle: i18n.t('profile.arabicHint'),
            selected: selected == 'ar',
            onTap: () => onSelected('ar'),
          );
          if (stacked) {
            return Column(
              children: [english, const SizedBox(height: 10), arabic],
            );
          }
          return Row(
            children: [
              Expanded(child: english),
              const SizedBox(width: 10),
              Expanded(child: arabic),
            ],
          );
        },
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.code,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String code;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: title,
      child: Material(
        color: selected ? AppColors.amberSoft : AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radius),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radius),
              border: Border.all(
                color: selected ? AppColors.amber : AppColors.border,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.navy : AppColors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    border: selected
                        ? null
                        : Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    code,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: selected ? AppColors.white : AppColors.navy,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.navy,
                            ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: AppColors.muted, height: 1.3),
                      ),
                    ],
                  ),
                ),
                Icon(
                  selected ? Icons.check_circle : Icons.circle_outlined,
                  size: 20,
                  color: selected ? AppColors.amber : AppColors.border,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileSessionSection extends StatelessWidget {
  const ProfileSessionSection({
    super.key,
    required this.i18n,
    required this.onLogout,
  });

  final I18nBundle i18n;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final compact = context.isMobile;
    final text = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.dangerSoft,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: const Icon(
                    Icons.logout,
                    size: 18,
                    color: AppColors.danger,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          i18n.t('profile.session'),
                          style: text.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.navy,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          i18n.t('profile.sessionHint'),
                          style: text.bodySmall?.copyWith(
                            color: AppColors.muted,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (!compact) ...[
                  const SizedBox(width: 12),
                  AppButton(
                    label: i18n.t('common.logout'),
                    icon: Icons.logout,
                    variant: AppButtonVariant.danger,
                    onPressed: onLogout,
                  ),
                ],
              ],
            ),
            if (compact) ...[
              const SizedBox(height: 14),
              AppButton(
                label: i18n.t('common.logout'),
                icon: Icons.logout,
                variant: AppButtonVariant.danger,
                expanded: true,
                onPressed: onLogout,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
