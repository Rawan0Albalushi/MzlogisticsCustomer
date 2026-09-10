import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class AppListCard extends StatelessWidget {
  const AppListCard({
    super.key,
    required this.title,
    this.subtitle,
    this.meta,
    this.trailing,
    this.leading,
    this.onTap,
    this.highlighted = false,
  });

  final String title;
  final String? subtitle;
  final String? meta;
  final Widget? trailing;
  final Widget? leading;
  final VoidCallback? onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      color: highlighted ? AppColors.amberSoft : AppColors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        subtitle!,
                        style: text.bodyMedium?.copyWith(color: AppColors.muted, height: 1.35),
                      ),
                    ],
                    if (meta != null && meta!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        meta!,
                        style: text.labelMedium?.copyWith(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 12),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class AppIconWell extends StatelessWidget {
  const AppIconWell({
    super.key,
    required this.icon,
    this.color = AppColors.navy,
    this.background = AppColors.mist,
  });

  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
