import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.showBack,
  });

  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool? showBack;

  static const double _toolbar = 64;
  static const double _toolbarWithSubtitle = 78;
  static const double _accent = 10;
  static const double _bottomRadius = 28;

  double get _toolbarHeight => subtitle == null ? _toolbar : _toolbarWithSubtitle;

  @override
  Size get preferredSize => Size.fromHeight(_toolbarHeight + _accent);

  @override
  Widget build(BuildContext context) {
    final back = showBack ?? context.canPop();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Material(
        color: Colors.transparent,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(_bottomRadius),
            ),
            gradient: LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
              colors: [
                Color(0xFF07141C),
                AppColors.navyDeep,
                Color(0xFF173E4F),
              ],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: _toolbarHeight + _accent,
              child: Column(
                children: [
                  SizedBox(
                    height: _toolbarHeight,
                    child: Row(
                      children: [
                        if (back)
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            color: AppColors.white,
                            onPressed: () => context.pop(),
                          )
                        else
                          const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              if (subtitle != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  subtitle!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.navyMuted,
                                      ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        IconTheme(
                          data: const IconThemeData(color: AppColors.white),
                          child: DefaultTextStyle.merge(
                            style: const TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ...?actions,
                                const SizedBox(width: 8),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 7),
                    child: SizedBox(
                      height: 3,
                      width: double.infinity,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          gradient: LinearGradient(
                            begin: AlignmentDirectional.centerStart,
                            end: AlignmentDirectional.centerEnd,
                            colors: [
                              AppColors.amber,
                              Color(0x66C9892C),
                              Color(0x00C9892C),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
