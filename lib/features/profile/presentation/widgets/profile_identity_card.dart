import 'package:flutter/material.dart';

import '../../../../core/i18n/i18n_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/breakpoints.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/models/user.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../profile_helpers.dart';

class ProfileIdentityCard extends StatelessWidget {
  const ProfileIdentityCard({
    super.key,
    required this.i18n,
    required this.user,
  });

  final I18nBundle i18n;
  final UserAccount user;

  @override
  Widget build(BuildContext context) {
    final organization = user.organization;
    final locale = i18n.locale.languageCode;
    final accountStatus = user.isActive ? 'active' : 'inactive';
    final phone = user.phone?.trim() ?? '';
    final organizationName = organization?.displayName(locale);
    final lastLogin = user.lastLoginAt == null
        ? null
        : formatDateTime(user.lastLoginAt, locale: locale);

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ColoredBox(
            color: AppColors.amber,
            child: SizedBox(height: 3),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Avatar(name: user.name),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _IdentityText(
                        i18n: i18n,
                        name: user.name,
                        organizationName: organizationName,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    StatusBadge(
                      status: accountStatus,
                      label: i18n.status(accountStatus),
                    ),
                    if (organization?.accountType != null)
                      ProfileMetaChip(
                        icon: organization!.accountType == 'company'
                            ? Icons.apartment_outlined
                            : Icons.person_outline,
                        label: accountTypeLabel(i18n, organization.accountType),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: _ContactFacts(
              i18n: i18n,
              email: user.email,
              phone: phone.isEmpty ? i18n.t('profile.noPhone') : phone,
              phoneCopyable: phone.isNotEmpty,
              lastLogin: lastLogin,
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.navy,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.amber, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        initialsFor(name),
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
      ),
    );
  }
}

class _IdentityText extends StatelessWidget {
  const _IdentityText({
    required this.i18n,
    required this.name,
    required this.organizationName,
  });

  final I18nBundle i18n;
  final String name;
  final String? organizationName;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name.isEmpty ? i18n.t('profile.title') : name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: text.titleMedium?.copyWith(
              color: AppColors.navy,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
          if (organizationName != null && organizationName!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              organizationName!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: text.bodyMedium?.copyWith(
                color: AppColors.muted,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ContactFacts extends StatelessWidget {
  const _ContactFacts({
    required this.i18n,
    required this.email,
    required this.phone,
    required this.phoneCopyable,
    required this.lastLogin,
  });

  final I18nBundle i18n;
  final String email;
  final String phone;
  final bool phoneCopyable;
  final String? lastLogin;

  @override
  Widget build(BuildContext context) {
    final emailFact = _Fact(
      i18n: i18n,
      icon: Icons.mail_outline,
      label: i18n.t('common.email'),
      value: email,
      copyable: true,
    );
    final phoneFact = _Fact(
      i18n: i18n,
      icon: Icons.phone_outlined,
      label: i18n.t('common.phone'),
      value: phone,
      copyable: phoneCopyable,
      ltr: phoneCopyable,
    );
    final loginFact = lastLogin == null
        ? null
        : _Fact(
            i18n: i18n,
            icon: Icons.schedule_outlined,
            label: i18n.t('profile.lastSignIn'),
            value: lastLogin!,
          );

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = !context.isMobile && constraints.maxWidth >= 560;
        final facts = [
          emailFact,
          phoneFact,
          ?loginFact,
        ];

        return DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppTheme.radius),
            border: Border.all(color: AppColors.border),
          ),
          child: wide
              ? IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var index = 0; index < facts.length; index++) ...[
                        if (index > 0)
                          const VerticalDivider(width: 1, thickness: 1),
                        Expanded(child: facts[index]),
                      ],
                    ],
                  ),
                )
              : Column(
                  children: [
                    for (var index = 0; index < facts.length; index++) ...[
                      facts[index],
                      if (index < facts.length - 1) const Divider(height: 1),
                    ],
                  ],
                ),
        );
      },
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({
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

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.navy),
          const SizedBox(width: 10),
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
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textDirection: ltr ? TextDirection.ltr : null,
                  style: text.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          if (copyable)
            IconButton(
              tooltip: i18n.t('profile.copy'),
              visualDensity: VisualDensity.compact,
              onPressed: () => copyProfileValue(context, i18n, value),
              icon: const Icon(
                Icons.copy_outlined,
                size: 16,
                color: AppColors.muted,
              ),
            ),
        ],
      ),
    );
  }
}
