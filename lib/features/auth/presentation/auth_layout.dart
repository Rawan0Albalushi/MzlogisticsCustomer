import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/i18n_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../shared/widgets/brand_mark.dart';

class AuthLayout extends ConsumerWidget {
  const AuthLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n = ref.i18n;
    final localeCode = i18n.locale.languageCode;
    final form = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 440),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.muted,
                      height: 1.45,
                    ),
              ),
              const SizedBox(height: 28),
              child,
            ],
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  const BrandMark(size: 36),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      i18n.t('app.name'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.navy,
                          ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SegmentedButton<String>(
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(
                        value: 'en',
                        label: Text(
                          context.isMobile
                              ? i18n.t('common.englishShort')
                              : i18n.t('common.english'),
                        ),
                      ),
                      ButtonSegment(
                        value: 'ar',
                        label: Text(
                          context.isMobile
                              ? i18n.t('common.arabicShort')
                              : i18n.t('common.arabic'),
                        ),
                      ),
                    ],
                    selected: {localeCode},
                    onSelectionChanged: (value) {
                      ref.read(i18nControllerProvider.notifier).setLocale(value.first);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: context.isDesktop
                  ? Row(
                      children: [
                        SizedBox(
                          width: (context.screenWidth * 0.38).clamp(400.0, 560.0),
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: AppColors.navyDeep,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(48),
                                child: Align(
                                  alignment: AlignmentDirectional.centerStart,
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 420),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const BrandMark(size: 56, light: true),
                                        const SizedBox(height: 28),
                                        Text(
                                          i18n.t('app.name'),
                                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.white,
                                              ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          i18n.t('app.tagline'),
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                color: AppColors.navyMuted,
                                                height: 1.4,
                                              ),
                                        ),
                                        const SizedBox(height: 24),
                                        Container(width: 40, height: 2, color: AppColors.amber),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(32),
                              child: form,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: form,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
